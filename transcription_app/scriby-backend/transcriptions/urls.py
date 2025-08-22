"""
Transcriptions URLs for Eskriba backend.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'transcriptions', views.TranscriptionViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('<uuid:pk>/analyze/', views.AnalyzeTranscriptionView.as_view(), name='analyze-transcription'),
    path('<uuid:pk>/export/', views.ExportTranscriptionView.as_view(), name='export-transcription'),
]
