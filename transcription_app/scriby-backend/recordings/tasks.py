from celery import shared_task
from django.conf import settings
import openai
import json
import logging
from datetime import datetime
from .models import Recording, Transcription, Analysis

logger = logging.getLogger(__name__)

@shared_task
def process_transcription(recording_id):
    try:
        recording = Recording.objects.get(id=recording_id)
        logger.info(f"Processing transcription for recording {recording_id}")
        
        # Configure OpenAI client
        client = openai.OpenAI(api_key=settings.OPENAI_API_KEY)
        
        # OpenAI Whisper transcription
        with open(recording.audio_file.path, 'rb') as audio_file:
            transcript = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                response_format="json"
            )
        
        # Save transcription
        transcription = Transcription.objects.create(
            recording=recording,
            text=transcript.text,
            confidence_score=0.95,  # Whisper doesn't provide confidence scores
            processing_time=None  # We'll calculate this if needed
        )
        
        logger.info(f"Transcription created for recording {recording_id}")
        
        # Trigger analysis
        analyze_transcription.delay(transcription.id)
        
        return f"Transcription completed for recording {recording_id}"
        
    except Recording.DoesNotExist:
        logger.error(f"Recording {recording_id} not found")
        return f"Recording {recording_id} not found"
    except Exception as e:
        logger.error(f"Error processing transcription for recording {recording_id}: {str(e)}")
        return f"Error: {str(e)}"

@shared_task
def analyze_transcription(transcription_id):
    try:
        transcription = Transcription.objects.get(id=transcription_id)
        logger.info(f"Analyzing transcription {transcription_id}")
        
        # Configure OpenAI client
        client = openai.OpenAI(api_key=settings.OPENAI_API_KEY)
        
        # GPT-4 analysis
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[{
                "role": "system",
                "content": "You are an AI assistant that analyzes transcriptions. Provide a structured analysis with summary, key topics, and action items in JSON format."
            }, {
                "role": "user",
                "content": f"""Analyze this transcription and provide:
1. A concise summary
2. Key topics (list of strings)
3. Action items (list of strings)
4. Sentiment score (0.0 to 1.0, where 0.5 is neutral)

Transcription: {transcription.text}

Return the response as valid JSON with keys: summary, key_topics, action_items, sentiment_score"""
            }]
        )
        
        # Parse analysis response
        try:
            analysis_data = json.loads(response.choices[0].message.content)
            
            Analysis.objects.create(
                transcription=transcription,
                summary=analysis_data.get('summary', 'Analysis completed'),
                key_topics=analysis_data.get('key_topics', []),
                action_items=analysis_data.get('action_items', []),
                sentiment_score=analysis_data.get('sentiment_score', 0.5)
            )
            
            logger.info(f"Analysis completed for transcription {transcription_id}")
            return f"Analysis completed for transcription {transcription_id}"
            
        except json.JSONDecodeError:
            # Fallback if JSON parsing fails
            Analysis.objects.create(
                transcription=transcription,
                summary=response.choices[0].message.content[:500],  # Truncate if needed
                key_topics=[],
                action_items=[],
                sentiment_score=0.5
            )
            logger.warning(f"Analysis completed with fallback for transcription {transcription_id}")
            return f"Analysis completed (fallback) for transcription {transcription_id}"
            
    except Transcription.DoesNotExist:
        logger.error(f"Transcription {transcription_id} not found")
        return f"Transcription {transcription_id} not found"
    except Exception as e:
        logger.error(f"Error analyzing transcription {transcription_id}: {str(e)}")
        return f"Error: {str(e)}"
