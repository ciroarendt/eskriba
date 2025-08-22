"""
Recordings URLs for Eskriba backend.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'recordings', views.RecordingViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('upload/', views.UploadRecordingView.as_view(), name='upload-recording'),
    path('<uuid:pk>/transcribe/', views.TranscribeRecordingView.as_view(), name='transcribe-recording'),
]
