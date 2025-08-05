//
//  VideoRecordingViewModel.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import SwiftUI
import UIKit

/// ViewModel for video recording functionality
@MainActor
final class VideoRecordingViewModel: ObservableObject {
    /// Current recording state
    @Published var isRecording = false
    
    /// URL of the recorded video
    @Published var recordedVideoURL: URL?
    
    /// Error message if recording fails
    @Published var errorMessage: String?
    
    /// Recording duration in seconds
    @Published var recordingDuration: TimeInterval = 0
    
    /// Whether to show the video recorder
    @Published var showingVideoRecorder = false
    
    /// Whether to show an alert
    @Published var showingAlert = false
    
    /// Alert message to display
    @Published var alertMessage = ""
    
    /// Recording service instance
    private let recordingService: VideoRecordingService
    
    /// Initializes the ViewModel with a recording service
    /// - Parameter recordingService: The service to handle recording operations
    init(recordingService: VideoRecordingService = VideoRecordingService()) {
        self.recordingService = recordingService
    }
    
    /// Starts the video recording process
    func startRecording() {
        showingVideoRecorder = true
    }
    
    /// Stops the video recording process
    func stopRecording() {
        showingVideoRecorder = false
    }
    
    /// Handles the completion of video recording
    /// - Parameter result: The result of the recording operation
    func handleRecordingCompletion(_ result: Result<URL, VideoRecordingError>) {
        showingVideoRecorder = false
        
        switch result {
        case .success(let url):
            recordedVideoURL = url
            alertMessage = "Video recorded successfully!"
            showingAlert = true
        case .failure(let error):
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    /// Dismisses the alert
    func dismissAlert() {
        showingAlert = false
        alertMessage = ""
    }
} 