from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.authentication import TokenAuthentication
from .models import Recording, Transcription, Analysis
from .serializers import RecordingSerializer, TranscriptionSerializer, AnalysisSerializer
from .tasks import process_transcription

class RecordingViewSet(viewsets.ModelViewSet):
    serializer_class = RecordingSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Return recordings for the authenticated user only
        return Recording.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        # Automatically associate recording with authenticated user
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


class UploadRecordingView(APIView):
    """
    API view for uploading audio recordings.
    """
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        serializer = RecordingSerializer(data=request.data)
        if serializer.is_valid():
            recording = serializer.save(user=request.user)
            # Trigger async transcription task
            process_transcription.delay(recording.id)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class TranscribeRecordingView(APIView):
    """
    API view for transcribing a specific recording.
    """
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    
    def post(self, request, pk):
        try:
            recording = Recording.objects.get(pk=pk, user=request.user)
            # Trigger async transcription task
            process_transcription.delay(recording.id)
            return Response({'status': 'transcription started'}, status=status.HTTP_202_ACCEPTED)
        except Recording.DoesNotExist:
            return Response({'error': 'Recording not found'}, status=status.HTTP_404_NOT_FOUND)
