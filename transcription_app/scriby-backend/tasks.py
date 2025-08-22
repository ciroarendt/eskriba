"""
Scriby - Production-Ready Celery Tasks
Enterprise-grade async task processing for AI transcription platform
"""

import os
import json
import time
import logging
import tempfile
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
from decimal import Decimal
from pathlib import Path

import requests
import openai
from celery import shared_task, current_task
from celery.exceptions import Retry, MaxRetriesExceededError
from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils import timezone
from django.db import transaction
from django.core.files.storage import default_storage
from django.core.cache import cache

# Audio processing libraries
import librosa
import soundfile as sf
import numpy as np
from pydub import AudioSegment
from pydub.effects import normalize, compress_dynamic_range

# AI and ML libraries
import whisper
from transformers import pipeline

# Internal imports
from .models import (
    Recording, Transcription, Analysis, User, Subscription,
    UsageMetrics, BillingRecord, NotificationTemplate
)

# Configure logging
logger = logging.getLogger(__name__)

# Constants
MAX_RETRIES = 3
RETRY_DELAY = 60  # seconds
CHUNK_SIZE = 25 * 1024 * 1024  # 25MB chunks
SUPPORTED_FORMATS = ['.mp3', '.wav', '.m4a', '.flac', '.ogg', '.aac']
WHISPER_MODEL_SIZE = 'base'  # base, small, medium, large
GPT_MODEL = 'gpt-4o-mini'
MAX_AUDIO_DURATION = 3600  # 1 hour limit


class TaskError(Exception):
    """Custom exception for task errors"""
    pass


class AudioProcessingError(TaskError):
    """Audio processing specific errors"""
    pass


class TranscriptionError(TaskError):
    """Transcription specific errors"""
    pass


class AnalysisError(TaskError):
    """Analysis specific errors"""
    pass


def update_task_progress(progress: int, message: str = ""):
    """Update task progress with detailed status"""
    if current_task:
        current_task.update_state(
            state='PROGRESS',
            meta={
                'current': progress,
                'total': 100,
                'message': message,
                'timestamp': timezone.now().isoformat()
            }
        )


def exponential_backoff(attempt: int, base_delay: int = 1, max_delay: int = 300) -> int:
    """Calculate exponential backoff with jitter"""
    import random
    delay = min(base_delay * (2 ** attempt), max_delay)
    jitter = random.uniform(0.1, 0.3) * delay
    return int(delay + jitter)


# =============================================================================
# AUDIO PROCESSING PIPELINE
# =============================================================================

@shared_task(bind=True, max_retries=MAX_RETRIES, default_retry_delay=RETRY_DELAY)
def process_audio_file(self, recording_id: int) -> Dict[str, Any]:
    """Complete audio processing pipeline with validation, enhancement, and optimization"""
    try:
        update_task_progress(0, "Starting audio processing...")
        
        # Get recording object
        recording = Recording.objects.get(id=recording_id)
        recording.status = 'processing'
        recording.save()
        
        logger.info(f"Processing audio file for recording {recording_id}")
        
        # Step 1: File validation and format detection
        update_task_progress(10, "Validating audio file...")
        audio_info = validate_audio_file(recording.audio_file.path)
        
        # Step 2: Format conversion if needed
        update_task_progress(25, "Converting audio format...")
        processed_path = convert_audio_format(recording.audio_file.path, target_format='wav')
        
        # Step 3: Audio enhancement
        update_task_progress(50, "Enhancing audio quality...")
        enhanced_path = enhance_audio_quality(processed_path)
        
        # Step 4: Metadata extraction
        update_task_progress(75, "Extracting metadata...")
        metadata = extract_audio_metadata(enhanced_path)
        
        # Step 5: Update recording with processed data
        update_task_progress(90, "Saving processed audio...")
        
        # Save enhanced audio file
        with open(enhanced_path, 'rb') as f:
            recording.processed_audio_file.save(
                f"processed_{recording.id}.wav",
                f,
                save=True
            )
        
        # Update metadata
        recording.duration = metadata['duration']
        recording.sample_rate = metadata['sample_rate']
        recording.channels = metadata['channels']
        recording.bitrate = metadata['bitrate']
        recording.file_size = metadata['file_size']
        recording.status = 'processed'
        recording.processed_at = timezone.now()
        recording.save()
        
        # Cleanup temporary files
        cleanup_temp_files([processed_path, enhanced_path])
        
        update_task_progress(100, "Audio processing completed!")
        
        # Trigger transcription task
        transcribe_audio.delay(recording_id)
        
        logger.info(f"Audio processing completed for recording {recording_id}")
        
        return {
            'status': 'success',
            'recording_id': recording_id,
            'metadata': metadata,
            'message': 'Audio processing completed successfully'
        }
        
    except Recording.DoesNotExist:
        logger.error(f"Recording {recording_id} not found")
        raise TaskError(f"Recording {recording_id} not found")
        
    except Exception as exc:
        logger.error(f"Audio processing failed for recording {recording_id}: {str(exc)}")
        
        # Update recording status
        try:
            recording = Recording.objects.get(id=recording_id)
            recording.status = 'failed'
            recording.error_message = str(exc)
            recording.save()
        except:
            pass
        
        # Retry with exponential backoff
        if self.request.retries < MAX_RETRIES:
            delay = exponential_backoff(self.request.retries)
            logger.info(f"Retrying audio processing in {delay} seconds...")
            raise self.retry(countdown=delay, exc=exc)
        
        raise AudioProcessingError(f"Audio processing failed after {MAX_RETRIES} retries: {str(exc)}")


@shared_task(bind=True, max_retries=MAX_RETRIES, default_retry_delay=RETRY_DELAY)
def transcribe_audio(self, recording_id: int) -> Dict[str, Any]:
    """AI transcription using OpenAI Whisper with progress tracking"""
    try:
        update_task_progress(0, "Starting transcription...")
        
        # Get recording
        recording = Recording.objects.get(id=recording_id)
        
        # Create transcription record
        transcription = Transcription.objects.create(
            recording=recording,
            status='processing',
            started_at=timezone.now()
        )
        
        logger.info(f"Starting transcription for recording {recording_id}")
        
        # Step 1: Prepare audio file
        update_task_progress(10, "Preparing audio for transcription...")
        audio_path = recording.processed_audio_file.path if recording.processed_audio_file else recording.audio_file.path
        
        # Step 2: Transcribe with Whisper
        update_task_progress(30, "Transcribing audio...")
        result = transcribe_with_whisper(audio_path)
        
        # Step 3: Process transcription result
        update_task_progress(80, "Processing transcription result...")
        
        # Save transcription
        transcription.content = result['text']
        transcription.language = result.get('language', 'en')
        transcription.confidence = result.get('confidence', 0.0)
        transcription.segments = result.get('segments', [])
        transcription.status = 'completed'
        transcription.completed_at = timezone.now()
        transcription.save()
        
        # Update recording
        recording.transcription_status = 'completed'
        recording.save()
        
        update_task_progress(100, "Transcription completed!")
        
        # Trigger analysis task
        analyze_content.delay(transcription.id)
        
        logger.info(f"Transcription completed for recording {recording_id}")
        
        return {
            'status': 'success',
            'transcription_id': transcription.id,
            'text_length': len(result['text']),
            'language': result.get('language'),
            'confidence': result.get('confidence'),
            'message': 'Transcription completed successfully'
        }
        
    except Exception as exc:
        logger.error(f"Transcription failed for recording {recording_id}: {str(exc)}")
        
        # Retry with exponential backoff
        if self.request.retries < MAX_RETRIES:
            delay = exponential_backoff(self.request.retries)
            logger.info(f"Retrying transcription in {delay} seconds...")
            raise self.retry(countdown=delay, exc=exc)
        
        raise TranscriptionError(f"Transcription failed after {MAX_RETRIES} retries: {str(exc)}")


@shared_task(bind=True, max_retries=MAX_RETRIES, default_retry_delay=RETRY_DELAY)
def analyze_content(self, transcription_id: int) -> Dict[str, Any]:
    """Comprehensive content analysis using GPT-4 and other AI models"""
    try:
        update_task_progress(0, "Starting content analysis...")
        
        # Get transcription
        transcription = Transcription.objects.get(id=transcription_id)
        
        # Create analysis record
        analysis = Analysis.objects.create(
            transcription=transcription,
            status='processing',
            started_at=timezone.now()
        )
        
        logger.info(f"Starting analysis for transcription {transcription_id}")
        
        # Step 1: Generate summary
        update_task_progress(20, "Generating summary...")
        summary_result = generate_summary(transcription.content)
        
        # Step 2: Extract topics
        update_task_progress(40, "Extracting topics...")
        topics_result = extract_topics(transcription.content)
        
        # Step 3: Identify action items
        update_task_progress(60, "Identifying action items...")
        action_items_result = extract_action_items(transcription.content)
        
        # Step 4: Sentiment analysis
        update_task_progress(80, "Analyzing sentiment...")
        sentiment_result = analyze_sentiment(transcription.content)
        
        # Step 5: Save analysis results
        update_task_progress(90, "Saving analysis results...")
        
        analysis.summary = summary_result['summary']
        analysis.key_points = summary_result['key_points']
        analysis.topics = topics_result['topics']
        analysis.action_items = action_items_result['action_items']
        analysis.sentiment_score = sentiment_result['sentiment_score']
        analysis.sentiment_label = sentiment_result['sentiment_label']
        analysis.entities = sentiment_result.get('entities', [])
        analysis.confidence = 0.85  # Simplified confidence calculation
        analysis.status = 'completed'
        analysis.completed_at = timezone.now()
        analysis.save()
        
        # Update transcription
        transcription.analysis_status = 'completed'
        transcription.save()
        
        update_task_progress(100, "Content analysis completed!")
        
        logger.info(f"Content analysis completed for transcription {transcription_id}")
        
        return {
            'status': 'success',
            'analysis_id': analysis.id,
            'summary_length': len(summary_result['summary']),
            'topics_count': len(topics_result['topics']),
            'action_items_count': len(action_items_result['action_items']),
            'sentiment': sentiment_result['sentiment_label'],
            'confidence': analysis.confidence,
            'message': 'Content analysis completed successfully'
        }
        
    except Exception as exc:
        logger.error(f"Content analysis failed for transcription {transcription_id}: {str(exc)}")
        
        # Retry with exponential backoff
        if self.request.retries < MAX_RETRIES:
            delay = exponential_backoff(self.request.retries)
            logger.info(f"Retrying content analysis in {delay} seconds...")
            raise self.retry(countdown=delay, exc=exc)
        
        raise AnalysisError(f"Content analysis failed after {MAX_RETRIES} retries: {str(exc)}")


# =============================================================================
# BUSINESS OPERATIONS
# =============================================================================

@shared_task(bind=True, max_retries=MAX_RETRIES)
def calculate_usage_metrics(self, user_id: int, date: str = None) -> Dict[str, Any]:
    """Calculate and update usage metrics for a user"""
    try:
        user = User.objects.get(id=user_id)
        target_date = datetime.fromisoformat(date) if date else timezone.now().date()
        
        # Calculate metrics for the day
        recordings_count = Recording.objects.filter(
            user=user,
            created_at__date=target_date
        ).count()
        
        transcriptions_count = Transcription.objects.filter(
            recording__user=user,
            created_at__date=target_date,
            status='completed'
        ).count()
        
        # Calculate costs (simplified)
        transcription_cost = transcriptions_count * Decimal('0.006')  # $0.006 per minute
        analysis_cost = transcriptions_count * Decimal('0.002')  # $0.002 per analysis
        total_cost = transcription_cost + analysis_cost
        
        # Update or create usage metrics
        metrics, created = UsageMetrics.objects.update_or_create(
            user=user,
            date=target_date,
            defaults={
                'recordings_count': recordings_count,
                'transcriptions_count': transcriptions_count,
                'api_calls': transcriptions_count,
                'cost': total_cost,
                'updated_at': timezone.now()
            }
        )
        
        logger.info(f"Usage metrics calculated for user {user_id} on {target_date}")
        
        return {
            'status': 'success',
            'user_id': user_id,
            'date': str(target_date),
            'recordings_count': recordings_count,
            'transcriptions_count': transcriptions_count,
            'total_cost': float(total_cost),
            'message': 'Usage metrics calculated successfully'
        }
        
    except Exception as exc:
        logger.error(f"Usage metrics calculation failed for user {user_id}: {str(exc)}")
        raise TaskError(f"Usage metrics calculation failed: {str(exc)}")


@shared_task(bind=True, max_retries=MAX_RETRIES)
def send_notification_email(self, user_id: int, template_name: str, context: Dict[str, Any]) -> Dict[str, Any]:
    """Send notification email to user"""
    try:
        user = User.objects.get(id=user_id)
        
        # Get email template
        template = NotificationTemplate.objects.get(name=template_name, is_active=True)
        
        # Render email content
        subject = template.subject.format(**context)
        html_content = template.html_content.format(**context)
        text_content = template.text_content.format(**context) if template.text_content else None
        
        # Send email
        send_mail(
            subject=subject,
            message=text_content or html_content,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            html_message=html_content,
            fail_silently=False
        )
        
        logger.info(f"Notification email sent to user {user_id} using template {template_name}")
        
        return {
            'status': 'success',
            'user_id': user_id,
            'template_name': template_name,
            'message': 'Notification email sent successfully'
        }
        
    except Exception as exc:
        logger.error(f"Failed to send notification email to user {user_id}: {str(exc)}")
        raise TaskError(f"Email notification failed: {str(exc)}")


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def validate_audio_file(file_path: str) -> Dict[str, Any]:
    """Validate audio file format and basic properties"""
    try:
        # Check file extension
        file_ext = Path(file_path).suffix.lower()
        if file_ext not in SUPPORTED_FORMATS:
            raise AudioProcessingError(f"Unsupported audio format: {file_ext}")
        
        # Load audio with librosa for validation
        y, sr = librosa.load(file_path, sr=None)
        duration = librosa.get_duration(y=y, sr=sr)
        
        # Check duration limits
        if duration > MAX_AUDIO_DURATION:
            raise AudioProcessingError(f"Audio duration {duration}s exceeds maximum {MAX_AUDIO_DURATION}s")
        
        if duration < 1:
            raise AudioProcessingError("Audio duration too short (minimum 1 second)")
        
        return {
            'format': file_ext,
            'duration': duration,
            'sample_rate': sr,
            'channels': y.shape[0] if len(y.shape) > 1 else 1,
            'valid': True
        }
        
    except Exception as e:
        raise AudioProcessingError(f"Audio validation failed: {str(e)}")


def convert_audio_format(input_path: str, target_format: str = 'wav') -> str:
    """Convert audio to target format with optimal settings"""
    try:
        # Load audio with pydub
        audio = AudioSegment.from_file(input_path)
        
        # Optimize for speech recognition
        audio = audio.set_frame_rate(16000)  # Whisper optimal sample rate
        audio = audio.set_channels(1)  # Mono for transcription
        
        # Create temporary output file
        with tempfile.NamedTemporaryFile(suffix=f'.{target_format}', delete=False) as tmp_file:
            output_path = tmp_file.name
        
        # Export with optimal settings
        audio.export(
            output_path,
            format=target_format,
            parameters=["-ac", "1", "-ar", "16000"]  # Mono, 16kHz
        )
        
        return output_path
        
    except Exception as e:
        raise AudioProcessingError(f"Audio conversion failed: {str(e)}")


def enhance_audio_quality(input_path: str) -> str:
    """Enhance audio quality for better transcription"""
    try:
        # Load audio
        audio = AudioSegment.from_file(input_path)
        
        # Apply audio enhancements
        # 1. Normalize volume
        audio = normalize(audio)
        
        # 2. Apply dynamic range compression
        audio = compress_dynamic_range(audio)
        
        # 3. Apply noise reduction (simple high-pass filter)
        audio = audio.high_pass_filter(80)  # Remove low-frequency noise
        
        # Create temporary output file
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp_file:
            output_path = tmp_file.name
        
        # Export enhanced audio
        audio.export(output_path, format='wav')
        
        return output_path
        
    except Exception as e:
        raise AudioProcessingError(f"Audio enhancement failed: {str(e)}")


def extract_audio_metadata(file_path: str) -> Dict[str, Any]:
    """Extract comprehensive audio metadata"""
    try:
        # Load with librosa for detailed analysis
        y, sr = librosa.load(file_path, sr=None)
        
        # Calculate metadata
        duration = librosa.get_duration(y=y, sr=sr)
        file_size = os.path.getsize(file_path)
        
        # Audio analysis
        rms_energy = np.mean(librosa.feature.rms(y=y))
        spectral_centroid = np.mean(librosa.feature.spectral_centroid(y=y, sr=sr))
        
        return {
            'duration': round(duration, 2),
            'sample_rate': sr,
            'channels': y.shape[0] if len(y.shape) > 1 else 1,
            'file_size': file_size,
            'bitrate': int((file_size * 8) / duration) if duration > 0 else 0,
            'rms_energy': float(rms_energy),
            'spectral_centroid': float(spectral_centroid),
            'format': 'wav'
        }
        
    except Exception as e:
        raise AudioProcessingError(f"Metadata extraction failed: {str(e)}")


def transcribe_with_whisper(audio_path: str) -> Dict[str, Any]:
    """Transcribe audio using OpenAI Whisper API"""
    try:
        # Initialize OpenAI client
        client = openai.OpenAI(api_key=settings.OPENAI_API_KEY)
        
        # Open audio file
        with open(audio_path, 'rb') as audio_file:
            # Call Whisper API
            response = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                response_format="verbose_json",
                timestamp_granularities=["segment"]
            )
        
        # Process response
        result = {
            'text': response.text,
            'language': response.language,
            'duration': response.duration,
            'segments': []
        }
        
        # Process segments
        if hasattr(response, 'segments'):
            for segment in response.segments:
                result['segments'].append({
                    'start': segment.start,
                    'end': segment.end,
                    'text': segment.text,
                    'confidence': getattr(segment, 'avg_logprob', 0.0)
                })
        
        # Calculate overall confidence
        if result['segments']:
            confidences = [seg.get('confidence', 0.0) for seg in result['segments']]
            result['confidence'] = sum(confidences) / len(confidences)
        else:
            result['confidence'] = 0.8  # Default confidence
        
        return result
        
    except Exception as e:
        raise TranscriptionError(f"Whisper transcription failed: {str(e)}")


def generate_summary(content: str) -> Dict[str, Any]:
    """Generate summary using GPT-4"""
    try:
        client = openai.OpenAI(api_key=settings.OPENAI_API_KEY)
        
        prompt = f"""
        Analyze the following transcription and provide:
        1. A concise summary (2-3 paragraphs)
        2. Key points (bullet list, max 10 points)
        
        Transcription:
        {content[:4000]}  # Limit content to avoid token limits
        
        Respond in JSON format:
        {{
            "summary": "...",
            "key_points": ["point1", "point2", ...]
        }}
        """
        
        response = client.chat.completions.create(
            model=GPT_MODEL,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=1000
        )
        
        result = json.loads(response.choices[0].message.content)
        return result
        
    except Exception as e:
        logger.error(f"Summary generation failed: {str(e)}")
        return {
            "summary": "Summary generation failed",
            "key_points": []
        }


def extract_topics(content: str) -> Dict[str, Any]:
    """Extract topics and themes"""
    try:
        client = openai.OpenAI(api_key=settings.OPENAI_API_KEY)
        
        prompt = f"""
        Extract the main topics and themes from this transcription.
        Provide topics with relevance scores (0-1).
        
        Transcription:
        {content[:4000]}
        
        Respond in JSON format:
        {{
            "topics": [
                {{"name": "topic_name", "relevance": 0.9, "description": "brief description"}},
                ...
            ]
        }}
        """
        
        response = client.chat.completions.create(
            model=GPT_MODEL,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=800
        )
        
        result = json.loads(response.choices[0].message.content)
        return result
        
    except Exception as e:
        logger.error(f"Topic extraction failed: {str(e)}")
        return {"topics": []}


def extract_action_items(content: str) -> Dict[str, Any]:
    """Extract action items and tasks"""
    try:
        client = openai.OpenAI(api_key=settings.OPENAI_API_KEY)
        
        prompt = f"""
        Identify action items, tasks, and follow-ups from this transcription.
        Include assignee if mentioned, priority level, and due date if specified.
        
        Transcription:
        {content[:4000]}
        
        Respond in JSON format:
        {{
            "action_items": [
                {{
                    "task": "description",
                    "assignee": "person or null",
                    "priority": "high/medium/low",
                    "due_date": "date or null",
                    "category": "category"
                }},
                ...
            ]
        }}
        """
        
        response = client.chat.completions.create(
            model=GPT_MODEL,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=800
        )
        
        result = json.loads(response.choices[0].message.content)
        return result
        
    except Exception as e:
        logger.error(f"Action items extraction failed: {str(e)}")
        return {"action_items": []}


def analyze_sentiment(content: str) -> Dict[str, Any]:
    """Analyze sentiment and extract entities"""
    try:
        # Use transformers for sentiment analysis
        sentiment_pipeline = pipeline("sentiment-analysis")
        sentiment_result = sentiment_pipeline(content[:512])  # Limit text length
        
        # Convert to our format
        sentiment_score = sentiment_result[0]['score']
        sentiment_label = sentiment_result[0]['label'].lower()
        
        return {
            'sentiment_score': sentiment_score,
            'sentiment_label': sentiment_label,
            'entities': []
        }
        
    except Exception as e:
        logger.error(f"Sentiment analysis failed: {str(e)}")
        return {
            'sentiment_score': 0.5,
            'sentiment_label': 'neutral',
            'entities': []
        }


def cleanup_temp_files(file_paths: List[str]):
    """Clean up temporary files"""
    for file_path in file_paths:
        try:
            if os.path.exists(file_path):
                os.unlink(file_path)
        except Exception as e:
            logger.warning(f"Failed to cleanup temp file {file_path}: {str(e)}")
