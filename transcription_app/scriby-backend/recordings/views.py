from rest_framework import viewsets, status
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
