//
//  VideoRecorderView.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import SwiftUI
import UIKit

struct VideoRecorderView: UIViewControllerRepresentable {
    @ObservedObject var videoRecorder: VideoRecorder
    let completion: (Result<URL, VideoRecorderError>) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        // Start recording immediately when the view appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            context.coordinator.startRecording(from: viewController)
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // This method is called when the SwiftUI view updates
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: VideoRecorderView
        
        init(_ parent: VideoRecorderView) {
            self.parent = parent
        }
        
        func startRecording(from viewController: UIViewController) {
            parent.videoRecorder.startRecording(from: viewController) { result in
                DispatchQueue.main.async {
                    self.parent.completion(result)
                }
            }
        }
    }
}

// SwiftUI View Modifier for Video Recording
struct VideoRecordingModifier: ViewModifier {
    @StateObject private var videoRecorder = VideoRecorder()
    @State private var showingVideoRecorder = false
    let onVideoRecorded: (URL) -> Void
    let onError: (VideoRecorderError) -> Void
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                showingVideoRecorder = true
            }
            .sheet(isPresented: $showingVideoRecorder) {
                VideoRecorderView(videoRecorder: videoRecorder) { result in
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

extension View {
    func videoRecording(
        onVideoRecorded: @escaping (URL) -> Void,
        onError: @escaping (VideoRecorderError) -> Void
    ) -> some View {
        self.modifier(VideoRecordingModifier(
            onVideoRecorded: onVideoRecorded,
            onError: onError
        ))
    }
} 