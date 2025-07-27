//
//  ContentView.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import SwiftUI
import AVKit

/// Main content view for the video recording application
struct ContentView: View {
    /// ViewModel for managing video recording state
    @State private var viewModel = VideoRecordingViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                headerSection
                Spacer()
                recordButtonSection
                videoPlayerSection
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showingVideoRecorder) {
            VideoRecorderView(
                recordingService: VideoRecordingService()
            ) { result in
                viewModel.handleRecordingCompletion(result)
            }
        }
        .alert("Video Recorder", isPresented: $viewModel.showingAlert) {
            Button("OK") {
                viewModel.dismissAlert()
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    /// Header section with app title and instructions
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "video.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Video Recorder")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Tap the record button to start recording")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Recording time: 5-60 seconds")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 50)
    }
    
    /// Record button section
    private var recordButtonSection: some View {
        Button(action: {
            viewModel.startRecording()
        }) {
            HStack {
                Image(systemName: "video.fill")
                    .font(.title2)
                Text("Record Video")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            )
        }
        .scaleEffect(viewModel.isRecording ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isRecording)
    }
    
    /// Video player section for recorded videos
    @ViewBuilder
    private var videoPlayerSection: some View {
        if let videoURL = viewModel.recordedVideoURL {
            VStack(spacing: 15) {
                Text("Recorded Video")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                
                Button("Play Video") {
                    // Video will auto-play when shown
                }
                .foregroundColor(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
} 