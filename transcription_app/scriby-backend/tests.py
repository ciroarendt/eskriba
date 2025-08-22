"""
Scriby - Production-Ready Test Suite
Comprehensive tests for Django backend
"""

import json
import tempfile
from decimal import Decimal
from unittest.mock import patch, Mock

from django.test import TestCase, TransactionTestCase
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from django.utils import timezone

from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from .models import (
    Recording, Transcription, Analysis, Subscription, 
    UsageMetrics, Organization
)
from .tasks import (
    process_audio_file, transcribe_audio, analyze_content,
    calculate_usage_metrics
)

User = get_user_model()


# =============================================================================
# MODEL TESTS
# =============================================================================

class UserModelTest(TestCase):
    """Test User model functionality"""
    
    def setUp(self):
        self.user_data = {
            'email': 'test@scriby.com',
            'first_name': 'John',
            'last_name': 'Doe',
            'password': 'testpass123'
        }
    
    def test_create_user(self):
        """Test user creation with valid data"""
        user = User.objects.create_user(**self.user_data)
        self.assertEqual(user.email, self.user_data['email'])
        self.assertTrue(user.check_password(self.user_data['password']))
        self.assertTrue(user.is_active)
        self.assertFalse(user.is_staff)
    
    def test_email_normalization(self):
        """Test email normalization"""
        user = User.objects.create_user(
            email='Test@SCRIBY.COM',
            password='testpass123'
        )
        self.assertEqual(user.email, 'test@scriby.com')
    
    def test_user_str_representation(self):
        """Test user string representation"""
        user = User.objects.create_user(**self.user_data)
        self.assertEqual(str(user), self.user_data['email'])


class RecordingModelTest(TestCase):
    """Test Recording model functionality"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@scriby.com',
            password='testpass123'
        )
        self.organization = Organization.objects.create(
            name='Test Org',
            owner=self.user
        )
        
        self.audio_file = SimpleUploadedFile(
            "test_audio.wav",
            b'fake audio content',
            content_type="audio/wav"
        )
    
    def test_create_recording(self):
        """Test recording creation"""
        recording = Recording.objects.create(
            user=self.user,
            organization=self.organization,
            title='Test Recording',
            audio_file=self.audio_file,
            duration=120.5,
            file_size=1024
        )
        
        self.assertEqual(recording.user, self.user)
        self.assertEqual(recording.title, 'Test Recording')
        self.assertEqual(recording.duration, 120.5)
        self.assertEqual(recording.status, 'uploaded')
        self.assertIsNotNone(recording.created_at)
    
    def test_recording_status_choices(self):
        """Test recording status validation"""
        recording = Recording.objects.create(
            user=self.user,
            organization=self.organization,
            title='Test Recording',
            audio_file=self.audio_file
        )
        
        valid_statuses = ['uploaded', 'processing', 'processed', 'transcribing', 'completed', 'failed']
        for status in valid_statuses:
            recording.status = status
            recording.save()
            self.assertEqual(recording.status, status)


class TranscriptionModelTest(TestCase):
    """Test Transcription model functionality"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@scriby.com',
            password='testpass123'
        )
        self.organization = Organization.objects.create(
            name='Test Org',
            owner=self.user
        )
        
        audio_file = SimpleUploadedFile(
            "test_audio.wav",
            b'fake audio content',
            content_type="audio/wav"
        )
        
        self.recording = Recording.objects.create(
            user=self.user,
            organization=self.organization,
            title='Test Recording',
            audio_file=audio_file
        )
    
    def test_create_transcription(self):
        """Test transcription creation"""
        transcription = Transcription.objects.create(
            recording=self.recording,
            content='This is a test transcription.',
            language='en',
            confidence=0.95
        )
        
        self.assertEqual(transcription.recording, self.recording)
        self.assertEqual(transcription.content, 'This is a test transcription.')
        self.assertEqual(transcription.language, 'en')
        self.assertEqual(transcription.confidence, 0.95)
        self.assertEqual(transcription.status, 'pending')
    
    def test_transcription_segments(self):
        """Test transcription segments JSON field"""
        segments = [
            {'start': 0.0, 'end': 5.0, 'text': 'Hello world'},
            {'start': 5.0, 'end': 10.0, 'text': 'This is a test'}
        ]
        
        transcription = Transcription.objects.create(
            recording=self.recording,
            content='Hello world This is a test',
            segments=segments
        )
        
        self.assertEqual(len(transcription.segments), 2)
        self.assertEqual(transcription.segments[0]['text'], 'Hello world')


# =============================================================================
# API TESTS
# =============================================================================

class AuthenticationAPITest(APITestCase):
    """Test authentication endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        self.user_data = {
            'email': 'test@scriby.com',
            'password': 'testpass123',
            'first_name': 'John',
            'last_name': 'Doe'
        }
        self.user = User.objects.create_user(**self.user_data)
    
    def test_user_registration(self):
        """Test user registration endpoint"""
        url = reverse('user-register')
        data = {
            'email': 'newuser@scriby.com',
            'password': 'newpass123',
            'first_name': 'New',
            'last_name': 'User'
        }
        
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(User.objects.filter(email=data['email']).exists())
    
    def test_user_login(self):
        """Test user login endpoint"""
        url = reverse('token_obtain_pair')
        data = {
            'email': self.user_data['email'],
            'password': self.user_data['password']
        }
        
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)


class RecordingAPITest(APITestCase):
    """Test Recording API endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='test@scriby.com',
            password='testpass123'
        )
        self.organization = Organization.objects.create(
            name='Test Org',
            owner=self.user
        )
        
        # Authenticate user
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        
        self.audio_file = SimpleUploadedFile(
            "test_audio.wav",
            b'fake audio content',
            content_type="audio/wav"
        )
    
    def test_create_recording(self):
        """Test creating a new recording"""
        url = reverse('recording-list')
        data = {
            'title': 'Test Recording',
            'description': 'Test description',
            'audio_file': self.audio_file,
            'organization': self.organization.id
        }
        
        response = self.client.post(url, data, format='multipart')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Recording.objects.count(), 1)
        
        recording = Recording.objects.first()
        self.assertEqual(recording.title, 'Test Recording')
        self.assertEqual(recording.user, self.user)
    
    def test_list_recordings(self):
        """Test listing user's recordings"""
        Recording.objects.create(
            user=self.user,
            organization=self.organization,
            title='Recording 1',
            audio_file=self.audio_file
        )
        Recording.objects.create(
            user=self.user,
            organization=self.organization,
            title='Recording 2',
            audio_file=self.audio_file
        )
        
        url = reverse('recording-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 2)


# =============================================================================
# TASK TESTS
# =============================================================================

class AudioProcessingTaskTest(TestCase):
    """Test audio processing Celery tasks"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@scriby.com',
            password='testpass123'
        )
        self.organization = Organization.objects.create(
            name='Test Org',
            owner=self.user
        )
        
        audio_file = SimpleUploadedFile(
            "test_audio.wav",
            b'fake audio content',
            content_type="audio/wav"
        )
        
        self.recording = Recording.objects.create(
            user=self.user,
            organization=self.organization,
            title='Test Recording',
            audio_file=audio_file
        )
    
    @patch('scriby_backend.tasks.validate_audio_file')
    @patch('scriby_backend.tasks.convert_audio_format')
    @patch('scriby_backend.tasks.enhance_audio_quality')
    @patch('scriby_backend.tasks.extract_audio_metadata')
    def test_process_audio_file_task(self, mock_metadata, mock_enhance, mock_convert, mock_validate):
        """Test audio processing task"""
        # Mock return values
        mock_validate.return_value = {'valid': True, 'duration': 120.0}
        mock_convert.return_value = '/tmp/converted.wav'
        mock_enhance.return_value = '/tmp/enhanced.wav'
        mock_metadata.return_value = {
            'duration': 120.0,
            'sample_rate': 16000,
            'channels': 1,
            'bitrate': 128000,
            'file_size': 1024
        }
        
        # Execute task
        result = process_audio_file(self.recording.id)
        
        # Verify results
        self.assertEqual(result['status'], 'success')
        self.assertEqual(result['recording_id'], self.recording.id)
        
        # Verify recording was updated
        self.recording.refresh_from_db()
        self.assertEqual(self.recording.status, 'processed')


class TranscriptionTaskTest(TestCase):
    """Test transcription Celery tasks"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@scriby.com',
            password='testpass123'
        )
        self.organization = Organization.objects.create(
            name='Test Org',
            owner=self.user
        )
        
        audio_file = SimpleUploadedFile(
            "test_audio.wav",
            b'fake audio content',
            content_type="audio/wav"
        )
        
        self.recording = Recording.objects.create(
            user=self.user,
            organization=self.organization,
            title='Test Recording',
            audio_file=audio_file,
            status='processed'
        )
    
    @patch('scriby_backend.tasks.transcribe_with_whisper')
    def test_transcribe_audio_task(self, mock_whisper):
        """Test audio transcription task"""
        # Mock Whisper response
        mock_whisper.return_value = {
            'text': 'This is a test transcription.',
            'language': 'en',
            'confidence': 0.95,
            'segments': [
                {'start': 0.0, 'end': 5.0, 'text': 'This is a test transcription.'}
            ]
        }
        
        # Execute task
        result = transcribe_audio(self.recording.id)
        
        # Verify results
        self.assertEqual(result['status'], 'success')
        self.assertIn('transcription_id', result)
        
        # Verify transcription was created
        transcription = Transcription.objects.get(recording=self.recording)
        self.assertEqual(transcription.content, 'This is a test transcription.')
        self.assertEqual(transcription.language, 'en')


class AnalysisTaskTest(TestCase):
    """Test content analysis Celery tasks"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@scriby.com',
            password='testpass123'
        )
        self.organization = Organization.objects.create(
            name='Test Org',
            owner=self.user
        )
        
        audio_file = SimpleUploadedFile(
            "test_audio.wav",
            b'fake audio content',
            content_type="audio/wav"
        )
        
        self.recording = Recording.objects.create(
            user=self.user,
            organization=self.organization,
            title='Test Recording',
            audio_file=audio_file
        )
        
        self.transcription = Transcription.objects.create(
            recording=self.recording,
            content='This is a test transcription for analysis.',
            status='completed'
        )
    
    @patch('scriby_backend.tasks.generate_summary')
    @patch('scriby_backend.tasks.extract_topics')
    @patch('scriby_backend.tasks.extract_action_items')
    @patch('scriby_backend.tasks.analyze_sentiment')
    def test_analyze_content_task(self, mock_sentiment, mock_actions, mock_topics, mock_summary):
        """Test content analysis task"""
        # Mock AI responses
        mock_summary.return_value = {
            'summary': 'This is a test summary.',
            'key_points': ['Point 1', 'Point 2']
        }
        mock_topics.return_value = {
            'topics': [{'name': 'Technology', 'relevance': 0.9}]
        }
        mock_actions.return_value = {
            'action_items': [{'task': 'Follow up', 'priority': 'high'}]
        }
        mock_sentiment.return_value = {
            'sentiment_score': 0.8,
            'sentiment_label': 'positive',
            'entities': []
        }
        
        # Execute task
        result = analyze_content(self.transcription.id)
        
        # Verify results
        self.assertEqual(result['status'], 'success')
        self.assertIn('analysis_id', result)
        
        # Verify analysis was created
        analysis = Analysis.objects.get(transcription=self.transcription)
        self.assertEqual(analysis.summary, 'This is a test summary.')
        self.assertEqual(analysis.sentiment_label, 'positive')


# =============================================================================
# INTEGRATION TESTS
# =============================================================================

class EndToEndWorkflowTest(TransactionTestCase):
    """Test complete end-to-end workflows"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='test@scriby.com',
            password='testpass123'
        )
        self.organization = Organization.objects.create(
            name='Test Org',
            owner=self.user
        )
        
        # Authenticate user
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    
    @patch('scriby_backend.tasks.process_audio_file.delay')
    def test_recording_upload_workflow(self, mock_task):
        """Test complete recording upload and processing workflow"""
        # Mock task result
        mock_task.return_value = Mock(id='task-123')
        
        # Create audio file
        audio_file = SimpleUploadedFile(
            "test_audio.wav",
            b'fake audio content',
            content_type="audio/wav"
        )
        
        # Upload recording
        url = reverse('recording-list')
        data = {
            'title': 'Integration Test Recording',
            'description': 'Test description',
            'audio_file': audio_file,
            'organization': self.organization.id
        }
        
        response = self.client.post(url, data, format='multipart')
        
        # Verify upload success
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Recording.objects.count(), 1)
        
        recording = Recording.objects.first()
        self.assertEqual(recording.title, 'Integration Test Recording')
        self.assertEqual(recording.status, 'uploaded')
        
        # Verify task was triggered
        mock_task.assert_called_once_with(recording.id)


class UsageMetricsTest(TestCase):
    """Test usage metrics calculation"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@scriby.com',
            password='testpass123'
        )
    
    def test_calculate_usage_metrics(self):
        """Test usage metrics calculation task"""
        # Create test data
        organization = Organization.objects.create(
            name='Test Org',
            owner=self.user
        )
        
        audio_file = SimpleUploadedFile(
            "test_audio.wav",
            b'fake audio content',
            content_type="audio/wav"
        )
        
        recording = Recording.objects.create(
            user=self.user,
            organization=organization,
            title='Test Recording',
            audio_file=audio_file
        )
        
        transcription = Transcription.objects.create(
            recording=recording,
            content='Test transcription',
            status='completed'
        )
        
        # Execute task
        result = calculate_usage_metrics(self.user.id)
        
        # Verify results
        self.assertEqual(result['status'], 'success')
        self.assertEqual(result['recordings_count'], 1)
        self.assertEqual(result['transcriptions_count'], 1)
        
        # Verify metrics were created
        metrics = UsageMetrics.objects.get(user=self.user)
        self.assertEqual(metrics.recordings_count, 1)
        self.assertEqual(metrics.transcriptions_count, 1)


class PerformanceTest(TestCase):
    """Test performance and scalability"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@scriby.com',
            password='testpass123'
        )
        self.organization = Organization.objects.create(
            name='Test Org',
            owner=self.user
        )
    
    def test_bulk_recording_creation(self):
        """Test creating multiple recordings efficiently"""
        recordings = []
        for i in range(50):
            audio_file = SimpleUploadedFile(
                f"test_audio_{i}.wav",
                b'fake audio content',
                content_type="audio/wav"
            )
            recordings.append(Recording(
                user=self.user,
                organization=self.organization,
                title=f'Recording {i}',
                audio_file=audio_file
            ))
        
        # Bulk create
        Recording.objects.bulk_create(recordings)
        
        # Verify count
        self.assertEqual(Recording.objects.count(), 50)
    
    def test_query_optimization(self):
        """Test query optimization with select_related"""
        audio_file = SimpleUploadedFile(
            "test_audio.wav",
            b'fake audio content',
            content_type="audio/wav"
        )
        
        recording = Recording.objects.create(
            user=self.user,
            organization=self.organization,
            title='Test Recording',
            audio_file=audio_file
        )
        
        transcription = Transcription.objects.create(
            recording=recording,
            content='Test content'
        )
        
        Analysis.objects.create(
            transcription=transcription,
            summary='Test summary'
        )
        
        # Test optimized query
        recordings = Recording.objects.select_related('user', 'organization').prefetch_related(
            'transcriptions__analyses'
        ).all()
        
        # Verify data access
        for recording in recordings:
            self.assertIsNotNone(recording.user.email)
            self.assertIsNotNone(recording.organization.name)
