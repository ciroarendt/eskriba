from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.views import APIView
from .models import Recording, Transcription, Analysis
from .serializers import RecordingSerializer, TranscriptionSerializer
from .tasks import process_transcription

class RecordingViewSet(viewsets.ModelViewSet):
    queryset = Recording.objects.all()  # Fix: Add queryset attribute for DRF router
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


class UploadRecordingView(APIView):
    """
    API view for uploading audio recordings.
    """
    permission_classes = [AllowAny]  # Temporarily allow public access for testing
    
    def post(self, request):
        serializer = RecordingSerializer(data=request.data)
        if serializer.is_valid():
            recording = serializer.save()
            # Trigger async transcription task
            process_transcription.delay(recording.id)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class TranscribeRecordingView(APIView):
    """
    API view for transcribing a specific recording.
    """
    permission_classes = [AllowAny]  # Temporarily allow public access for testing
    
    def post(self, request, pk):
        try:
            recording = Recording.objects.get(pk=pk)
            # Trigger async transcription task
            process_transcription.delay(recording.id)
            return Response({'status': 'transcription started'}, status=status.HTTP_202_ACCEPTED)
        except Recording.DoesNotExist:
            return Response({'error': 'Recording not found'}, status=status.HTTP_404_NOT_FOUND)
