//
//  ContentView.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject private var videoRecorder = VideoRecorder()
    @State private var recordedVideoURL: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingVideoRecorder = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
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
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Record Button
                Button(action: {
                    showingVideoRecorder = true
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
                .scaleEffect(videoRecorder.isRecording ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: videoRecorder.isRecording)
                
                // Video Player
                if let videoURL = recordedVideoURL {
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
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingVideoRecorder) {
            VideoRecorderView(videoRecorder: videoRecorder) { result in
                showingVideoRecorder = false
                switch result {
                case .success(let url):
                    recordedVideoURL = url
                    alertMessage = "Video recorded successfully!"
                    showingAlert = true
                case .failure(let error):
                    switch error {
                    case .cameraNotAvailable:
                        alertMessage = "Camera is not available on this device."
                    case .permissionDenied:
                        alertMessage = "Camera permission is required. Please enable it in Settings."
                    case .recordingFailed:
                        alertMessage = "Failed to record video. Please try again."
                    case .unknown:
                        alertMessage = "An unknown error occurred."
                    }
                    showingAlert = true
                }
            }
        }
        .alert("Video Recorder", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
}

#Preview {
    ContentView()
}
