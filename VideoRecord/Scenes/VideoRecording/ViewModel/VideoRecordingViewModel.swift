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
@Observable
final class VideoRecordingViewModel {
    /// Current recording state
    var isRecording = false
    
    /// URL of the recorded video
    var recordedVideoURL: URL?
    
    /// Error message if recording fails
    var errorMessage: String?
    
    /// Whether to show the video recorder
    var showingVideoRecorder = false
    
    /// Whether to show an alert
    var showingAlert = false
    
    /// Alert message to display
    var alertMessage = ""
    
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