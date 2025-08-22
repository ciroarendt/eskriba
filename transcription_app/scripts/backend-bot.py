#!/usr/bin/env python3
"""
Backend Bot - Automated Django Backend Development
Develops and maintains the Scriby backend using Django, Celery, Redis, PostgreSQL
"""

import os
import subprocess
import time
from pathlib import Path
import argparse
import sys

# Add scripts directory to path for bot_logger import
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from bot_logger import create_bot_logger
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('BackendBot')

class BackendBot:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.backend_path = self.project_path / 'scriby-backend'
        self.logger = create_bot_logger('backend', str(self.project_path))
        
    def setup_django_project(self):
        """Create Django project structure"""
        logger.info("🔧 Setting up Django project...")
        
        # Check if Django project already exists
        manage_py_path = self.backend_path / 'manage.py'
        if manage_py_path.exists():
            logger.info("✅ Django project already exists, skipping creation")
        else:
            # Create Django project
            subprocess.run([
                'django-admin', 'startproject', 'scriby_backend', '.'
            ], cwd=self.backend_path, check=True)
            logger.info("✅ Django project created")
        
        # Create apps if they don't exist
        auth_app_path = self.backend_path / 'authentication'
        recordings_app_path = self.backend_path / 'recordings'
        
        if not auth_app_path.exists():
            subprocess.run(['python3', 'manage.py', 'startapp', 'authentication'], 
                         cwd=self.backend_path, check=True)
            logger.info("✅ Authentication app created")
        else:
            logger.info("✅ Authentication app already exists")
            
        if not recordings_app_path.exists():
            subprocess.run(['python3', 'manage.py', 'startapp', 'recordings'], 
                         cwd=self.backend_path, check=True)
            logger.info("✅ Recordings app created")
        else:
            logger.info("✅ Recordings app already exists")
        
        transcriptions_app_path = self.backend_path / 'transcriptions'
        analytics_app_path = self.backend_path / 'analytics'
        
        if not transcriptions_app_path.exists():
            subprocess.run(['python3', 'manage.py', 'startapp', 'transcriptions'], 
                         cwd=self.backend_path, check=True)
            logger.info("✅ Transcriptions app created")
        else:
            logger.info("✅ Transcriptions app already exists")
            
        if not analytics_app_path.exists():
            subprocess.run(['python3', 'manage.py', 'startapp', 'analytics'], 
                         cwd=self.backend_path, check=True)
            logger.info("✅ Analytics app created")
        else:
            logger.info("✅ Analytics app already exists")
        
        logger.info("✅ Django project structure created")
        
    def create_models(self):
        """Create Django models"""
        logger.info("🔧 Creating Django models...")
        
        # User model
        user_model = '''from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    email = models.EmailField(unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    subscription_plan = models.CharField(max_length=20, default='free')
    api_usage_count = models.IntegerField(default=0)
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']
'''
        
        # Recording model
        recording_model = '''from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Recording(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    audio_file = models.FileField(upload_to='recordings/')
    duration = models.DurationField()
    created_at = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, default='uploaded')
    
class Transcription(models.Model):
    recording = models.OneToOneField(Recording, on_delete=models.CASCADE)
    text = models.TextField()
    confidence_score = models.FloatField()
    processing_time = models.DurationField()
    created_at = models.DateTimeField(auto_now_add=True)
    
class Analysis(models.Model):
    transcription = models.OneToOneField(Transcription, on_delete=models.CASCADE)
    summary = models.TextField()
    key_topics = models.JSONField()
    action_items = models.JSONField()
    sentiment_score = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)
'''
        
        # Write models
        with open(self.backend_path / 'authentication/models.py', 'w') as f:
            f.write(user_model)
            
        with open(self.backend_path / 'recordings/models.py', 'w') as f:
            f.write(recording_model)
            
        logger.info("✅ Django models created")
        
    def create_api_endpoints(self):
        """Create REST API endpoints"""
        logger.info("🔧 Creating API endpoints...")
        
        # API views
        api_views = '''from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Recording, Transcription, Analysis
from .serializers import RecordingSerializer, TranscriptionSerializer
from .tasks import process_transcription

class RecordingViewSet(viewsets.ModelViewSet):
    serializer_class = RecordingSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Recording.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        recording = serializer.save(user=self.request.user)
        # Trigger async transcription
        process_transcription.delay(recording.id)
    
    @action(detail=True, methods=['get'])
    def transcription(self, request, pk=None):
        recording = self.get_object()
        try:
            transcription = recording.transcription
            serializer = TranscriptionSerializer(transcription)
            return Response(serializer.data)
        except Transcription.DoesNotExist:
            return Response({'status': 'processing'}, status=status.HTTP_202_ACCEPTED)
'''
        
        with open(self.backend_path / 'recordings/views.py', 'w') as f:
            f.write(api_views)
            
        logger.info("✅ API endpoints created")
        
    def setup_celery(self):
        """Setup Celery for async processing"""
        logger.info("🔧 Setting up Celery...")
        
        celery_config = '''import os
from celery import Celery

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'scriby_backend.settings')

app = Celery('scriby_backend')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()
'''
        
        celery_tasks = '''from celery import shared_task
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
'''
        
        with open(self.backend_path / 'config/celery.py', 'w') as f:
            f.write(celery_config)
            
        with open(self.backend_path / 'recordings/tasks.py', 'w') as f:
            f.write(celery_tasks)
            
        logger.info("✅ Celery setup completed")
        
    def create_requirements(self):
        """Create requirements.txt"""
        requirements = '''Django==4.2.7
djangorestframework==3.14.0
celery==5.3.4
redis==5.0.1
psycopg2-binary==2.9.9
openai==1.3.5
python-keycloak==3.7.0
django-cors-headers==4.3.1
pillow==10.1.0
python-decouple==3.8
gunicorn==21.2.0
'''
        
        with open(self.backend_path / 'requirements.txt', 'w') as f:
            f.write(requirements)
            
        logger.info("✅ Requirements.txt created")

def main():
    parser = argparse.ArgumentParser(description='Backend Bot - Django Development')
    parser.add_argument('--continuous', action='store_true', help='Run in continuous mode')
    args = parser.parse_args()
    
    bot = BackendBot("/Users/ciroarendt/CURSOR/APP_11me/transcription_app")
    
    print("🤖 Backend Bot - Starting Django Development")
    print("=" * 50)
    
    if args.continuous:
        print("🔄 Running in CONTINUOUS mode...")
        cycle = 0
        while True:
            try:
                cycle += 1
                print(f"\n🔄 Continuous cycle #{cycle}")
                
                # Run development tasks
                bot.setup_django_project()
                bot.create_models()
                bot.create_api_endpoints()
                bot.setup_celery()
                bot.create_requirements()
                
                print(f"✅ Cycle #{cycle} completed")
                time.sleep(30)  # Wait 30 seconds between cycles
                
            except KeyboardInterrupt:
                print("\n🛑 Continuous mode stopped")
                break
            except Exception as e:
                print(f"❌ Error in cycle #{cycle}: {e}")
                time.sleep(10)  # Wait before retry
    else:
        # Single run mode
        try:
            bot.setup_django_project()
            bot.create_models()
            bot.create_api_endpoints()
            bot.setup_celery()
            bot.create_requirements()
            
            print("🎉 Backend Bot completed successfully!")
            print("📋 Next steps:")
            print("  1. cd scriby-backend")
            print("  2. pip install -r requirements.txt")
            print("  3. python manage.py migrate")
            print("  4. python manage.py runserver")
            
        except Exception as e:
            logger.error(f"❌ Backend Bot failed: {e}")
            sys.exit(1)

if __name__ == "__main__":
    main()
