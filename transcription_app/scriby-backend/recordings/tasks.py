from celery import shared_task
import openai
from .models import Recording, Transcription, Analysis

@shared_task
def process_transcription(recording_id):
    recording = Recording.objects.get(id=recording_id)
    
    # OpenAI Whisper transcription
    with open(recording.audio_file.path, 'rb') as audio_file:
        transcript = openai.Audio.transcribe("whisper-1", audio_file)
    
    # Save transcription
    transcription = Transcription.objects.create(
        recording=recording,
        text=transcript.text,
        confidence_score=0.95,  # Placeholder
        processing_time=transcript.get('processing_time', 0)
    )
    
    # Trigger analysis
    analyze_transcription.delay(transcription.id)
    
@shared_task
def analyze_transcription(transcription_id):
    transcription = Transcription.objects.get(id=transcription_id)
    
    # GPT-4 analysis
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{
            "role": "user",
            "content": f"Analyze this transcription and provide summary, key topics, and action items: {transcription.text}"
        }]
    )
    
    # Parse and save analysis
    analysis_data = response.choices[0].message.content
    Analysis.objects.create(
        transcription=transcription,
        summary=analysis_data,  # Would parse this properly
        key_topics=[],
        action_items=[],
        sentiment_score=0.5
    )
