"""
Transcriptions models for Eskriba backend.
"""
import uuid
from django.db import models
from recordings.models import Recording


class Transcription(models.Model):
    """
    Model for storing transcription data from audio recordings.
    """
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]
    
    LANGUAGE_CHOICES = [
        ('en', 'English'),
        ('es', 'Spanish'),
        ('pt', 'Portuguese'),
        ('fr', 'French'),
        ('de', 'German'),
        ('it', 'Italian'),
        ('auto', 'Auto-detect'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    recording = models.ForeignKey(
        Recording, 
        on_delete=models.CASCADE, 
        related_name='transcriptions'
    )
    text = models.TextField(blank=True, null=True)
    language = models.CharField(
        max_length=10, 
        choices=LANGUAGE_CHOICES, 
        default='auto'
    )
    confidence_score = models.FloatField(null=True, blank=True)
    status = models.CharField(
        max_length=20, 
        choices=STATUS_CHOICES, 
        default='pending'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Transcription'
        verbose_name_plural = 'Transcriptions'

    def __str__(self):
        return f"Transcription {self.id} - {self.status}"
