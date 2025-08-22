from rest_framework import serializers
from .models import Recording, Transcription, Analysis


class RecordingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Recording
        fields = ['id', 'title', 'audio_file', 'duration', 'created_at', 'status']
        read_only_fields = ['id', 'created_at', 'status']


class TranscriptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transcription
        fields = ['id', 'recording', 'text', 'confidence_score', 'language', 'created_at']
        read_only_fields = ['id', 'created_at']


class AnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = Analysis
        fields = ['id', 'transcription', 'summary', 'key_points', 'action_items', 'topics', 'created_at']
        read_only_fields = ['id', 'created_at']
