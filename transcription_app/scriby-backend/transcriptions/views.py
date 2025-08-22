"""
Transcriptions views for Eskriba backend.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.authentication import TokenAuthentication
from django.shortcuts import get_object_or_404
from .models import Transcription
from .serializers import TranscriptionSerializer


class TranscriptionViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing transcriptions.
    """
    serializer_class = TranscriptionSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Return transcriptions for recordings owned by the authenticated user
        return Transcription.objects.filter(recording__user=self.request.user)

    @action(detail=True, methods=['post'])
    def analyze(self, request, pk=None):
        """
        Trigger AI analysis for a transcription.
        """
        transcription = self.get_object()
        # TODO: Implement AI analysis logic
        return Response({
            'status': 'analysis_started',
            'transcription_id': str(transcription.id)
        })


class AnalyzeTranscriptionView(APIView):
    """
    API view for analyzing transcriptions with AI.
    """
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        """
        Start AI analysis for a specific transcription.
        """
        transcription = get_object_or_404(Transcription, pk=pk, recording__user=request.user)
        
        # TODO: Implement AI analysis logic
        # For now, return a placeholder response
        return Response({
            'status': 'success',
            'message': 'AI analysis started',
            'transcription_id': str(transcription.id)
        }, status=status.HTTP_200_OK)


class ExportTranscriptionView(APIView):
    """
    API view for exporting transcriptions in various formats.
    """
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        """
        Export a transcription in the requested format.
        """
        transcription = get_object_or_404(Transcription, pk=pk, recording__user=request.user)
        export_format = request.query_params.get('format', 'json')
        
        if export_format == 'json':
            serializer = TranscriptionSerializer(transcription)
            return Response(serializer.data)
        
        # TODO: Implement other export formats (PDF, DOCX, etc.)
        return Response({
            'status': 'success',
            'message': f'Export in {export_format} format',
            'transcription_id': str(transcription.id)
        }, status=status.HTTP_200_OK)
