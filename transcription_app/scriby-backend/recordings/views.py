from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from .models import Recording, Transcription, Analysis
from .serializers import RecordingSerializer, TranscriptionSerializer
from .tasks import process_transcription

class RecordingViewSet(viewsets.ModelViewSet):
    serializer_class = RecordingSerializer
    permission_classes = [AllowAny]  # Temporarily allow public access for testing
    
    def get_queryset(self):
        # For testing - return all recordings, later filter by user when auth is implemented
        return Recording.objects.all()
    
    def perform_create(self, serializer):
        # For testing - save without user, later add user when auth is implemented
        recording = serializer.save()
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
