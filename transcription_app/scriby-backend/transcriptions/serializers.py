"""
Transcriptions serializers for Eskriba backend.
"""
from rest_framework import serializers
from .models import Transcription


class TranscriptionSerializer(serializers.ModelSerializer):
    """
    Serializer for Transcription model.
    """
    class Meta:
        model = Transcription
        fields = [
            'id',
            'recording',
            'text',
            'language',
            'confidence_score',
            'status',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_confidence_score(self, value):
        """
        Validate confidence score is between 0 and 1.
        """
        if value is not None and (value < 0 or value > 1):
            raise serializers.ValidationError("Confidence score must be between 0 and 1.")
        return value
