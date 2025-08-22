import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/transcription_model.dart';

/// Transcription State Management - Bot 3: Mobile Flutter Developer
/// Handles all transcription-related state and API calls

// Transcription State
class TranscriptionState {
  final List<TranscriptionModel> transcriptions;
  final bool isLoading;
  final bool isUploading;
  final String? error;
  final TranscriptionModel? currentTranscription;
  final double uploadProgress;

  const TranscriptionState({
    this.transcriptions = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.error,
    this.currentTranscription,
    this.uploadProgress = 0.0,
  });

  TranscriptionState copyWith({
    List<TranscriptionModel>? transcriptions,
    bool? isLoading,
    bool? isUploading,
    String? error,
    TranscriptionModel? currentTranscription,
    double? uploadProgress,
  }) {
    return TranscriptionState(
      transcriptions: transcriptions ?? this.transcriptions,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      currentTranscription: currentTranscription ?? this.currentTranscription,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

// Transcription Notifier
class TranscriptionNotifier extends StateNotifier<TranscriptionState> {
  final ApiClient _apiClient;

  TranscriptionNotifier(this._apiClient) : super(const TranscriptionState());

  // Load all transcriptions
  Future<void> loadTranscriptions() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final transcriptionsData = await _apiClient.getTranscriptions();
      final transcriptions = transcriptionsData
          .map((data) => TranscriptionModel.fromJson(data))
          .toList();
      
      state = state.copyWith(
        transcriptions: transcriptions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load transcriptions: ${e.toString()}',
      );
    }
  }

  // Upload audio file for transcription
  Future<TranscriptionModel?> uploadAudio(String filePath) async {
    state = state.copyWith(isUploading: true, uploadProgress: 0.0, error: null);
    
    try {
      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        state = state.copyWith(uploadProgress: i / 100);
      }
      
      final transcriptionData = await _apiClient.uploadAudio(filePath);
      final transcription = TranscriptionModel.fromJson(transcriptionData);
      
      // Add to local list
      final updatedTranscriptions = [transcription, ...state.transcriptions];
      
      state = state.copyWith(
        transcriptions: updatedTranscriptions,
        isUploading: false,
        currentTranscription: transcription,
        uploadProgress: 1.0,
      );
      
      // Start polling for transcription status
      _pollTranscriptionStatus(transcription.id);
      
      return transcription;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        uploadProgress: 0.0,
        error: 'Failed to upload audio: ${e.toString()}',
      );
      return null;
    }
  }

  // Poll transcription status
  Future<void> _pollTranscriptionStatus(String transcriptionId) async {
    while (true) {
      try {
        final statusData = await _apiClient.getTranscriptionStatus(transcriptionId);
        final updatedTranscription = TranscriptionModel.fromJson(statusData);
        
        // Update transcription in list
        final updatedTranscriptions = state.transcriptions.map((t) {
          return t.id == transcriptionId ? updatedTranscription : t;
        }).toList();
        
        state = state.copyWith(
          transcriptions: updatedTranscriptions,
          currentTranscription: state.currentTranscription?.id == transcriptionId 
              ? updatedTranscription 
              : state.currentTranscription,
        );
        
        // Stop polling if completed or failed
        if (updatedTranscription.status == TranscriptionStatus.completed ||
            updatedTranscription.status == TranscriptionStatus.failed) {
          break;
        }
        
        // Wait before next poll
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        print('Error polling transcription status: $e');
        break;
      }
    }
  }

  // Refresh single transcription
  Future<void> refreshTranscription(String transcriptionId) async {
    try {
      final transcriptionData = await _apiClient.getTranscriptionStatus(transcriptionId);
      final updatedTranscription = TranscriptionModel.fromJson(transcriptionData);
      
      final updatedTranscriptions = state.transcriptions.map((t) {
        return t.id == transcriptionId ? updatedTranscription : t;
      }).toList();
      
      state = state.copyWith(transcriptions: updatedTranscriptions);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to refresh transcription: ${e.toString()}',
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Set current transcription
  void setCurrentTranscription(TranscriptionModel transcription) {
    state = state.copyWith(currentTranscription: transcription);
  }
}

// Providers
final transcriptionProvider = StateNotifierProvider<TranscriptionNotifier, TranscriptionState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TranscriptionNotifier(apiClient);
});

// Computed providers
final completedTranscriptionsProvider = Provider<List<TranscriptionModel>>((ref) {
  final state = ref.watch(transcriptionProvider);
  return state.transcriptions
      .where((t) => t.status == TranscriptionStatus.completed)
      .toList();
});

final processingTranscriptionsProvider = Provider<List<TranscriptionModel>>((ref) {
  final state = ref.watch(transcriptionProvider);
  return state.transcriptions
      .where((t) => t.status == TranscriptionStatus.processing)
      .toList();
});

final recentTranscriptionsProvider = Provider<List<TranscriptionModel>>((ref) {
  final state = ref.watch(transcriptionProvider);
  return state.transcriptions.take(5).toList();
});
