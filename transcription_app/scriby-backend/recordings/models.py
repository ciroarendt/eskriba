from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Recording(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)  # Allow null for testing
    title = models.CharField(max_length=200)
    audio_file = models.FileField(upload_to='recordings/')
    duration = models.DurationField(null=True, blank=True)  # Allow null for testing
    created_at = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, default='uploaded')
    
class Transcription(models.Model):
    recording = models.OneToOneField(Recording, on_delete=models.CASCADE)
    text = models.TextField()
    confidence_score = models.FloatField(null=True, blank=True)
    processing_time = models.DurationField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
class Analysis(models.Model):
    transcription = models.OneToOneField(Transcription, on_delete=models.CASCADE)
    summary = models.TextField()
    key_topics = models.JSONField(default=list)
    action_items = models.JSONField(default=list)
    sentiment_score = models.FloatField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
