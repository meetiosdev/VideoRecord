//
//  VideoRecorderView.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import SwiftUI
import UIKit

/// SwiftUI wrapper for native video recording functionality
struct VideoRecorderView: UIViewControllerRepresentable {
    /// The recording service to use
    let recordingService: VideoRecordingService
    
    /// Completion handler for recording results
    let completion: (Result<URL, VideoRecordingError>) -> Void
    
    /// Creates the UIViewController
    /// - Parameter context: The context for the representable
    /// - Returns: A UIViewController that handles video recording
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Start recording immediately when the view appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            context.coordinator.startRecording(from: viewController)
        }
        
        return viewController
    }
    
    /// Updates the UIViewController
    /// - Parameters:
    ///   - uiViewController: The view controller to update
    ///   - context: The context for the representable
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed for this implementation
    }
    
    /// Creates the coordinator for this representable
    /// - Returns: A coordinator instance
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Coordinator class to handle the bridge between SwiftUI and UIKit
    final class Coordinator: NSObject {
        /// Reference to the parent view
        let parent: VideoRecorderView
        
        /// Initializes the coordinator
        /// - Parameter parent: The parent view
        init(_ parent: VideoRecorderView) {
            self.parent = parent
        }
        
        /// Starts the recording process
        /// - Parameter viewController: The view controller to present from
        @MainActor
        func startRecording(from viewController: UIViewController) {
            parent.recordingService.startRecording(from: viewController) { result in
                DispatchQueue.main.async {
                    self.parent.completion(result)
                }
            }
        }
    }
}

/// SwiftUI View Modifier for Video Recording
struct VideoRecordingModifier: ViewModifier {
    /// The recording service
    @State private var recordingService = VideoRecordingService()
    
    /// Whether to show the video recorder
    @State private var showingVideoRecorder = false
    
    /// Callback for successful video recording
    let onVideoRecorded: (URL) -> Void
    
    /// Callback for recording errors
    let onError: (VideoRecordingError) -> Void
    
    /// The body of the modifier
    /// - Parameter content: The content to modify
    /// - Returns: The modified view
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                showingVideoRecorder = true
            }
            .sheet(isPresented: $showingVideoRecorder) {
                VideoRecorderView(recordingService: recordingService) { result in
                    showingVideoRecorder = false
                    switch result {
                    case .success(let url):
                        onVideoRecorded(url)
                    case .failure(let error):
                        onError(error)
                    }
                }
            }
    }
}

/// Extension to add video recording functionality to any view
extension View {
    /// Adds video recording functionality to a view
    /// - Parameters:
    ///   - onVideoRecorded: Callback for successful recording
    ///   - onError: Callback for recording errors
    /// - Returns: A view with video recording capability
    func videoRecording(
        onVideoRecorded: @escaping (URL) -> Void,
        onError: @escaping (VideoRecordingError) -> Void
    ) -> some View {
        self.modifier(VideoRecordingModifier(
            onVideoRecorded: onVideoRecorded,
            onError: onError
        ))
    }
} 