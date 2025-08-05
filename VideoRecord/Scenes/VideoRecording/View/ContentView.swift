//
//  ContentView.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import SwiftUI
import AVKit
import PhotosUI
import UIKit

/// Transferable type for handling video URLs from PhotosPicker
struct VideoTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "gallery_video_\(Date().timeIntervalSince1970).mp4")
            
            print("📹 Gallery Video Import: Starting import process")
            print("📹 Gallery Video Import: Original file path: \(received.file.path())")
            print("📹 Gallery Video Import: Copy file path: \(copy.path)")
            
            if FileManager.default.fileExists(atPath: copy.path) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: received.file, to: copy)
            print("📹 Gallery Video Import: Successfully copied video")
            
            return VideoTransferable(url: copy)
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = VideoRecordingViewModel()
    @State private var selectedGalleryItem: PhotosPickerItem? = nil
    @State private var galleryVideoURL: URL? = nil
    @State private var pickerDuration: TimeInterval = 0
    @State private var isPickerActive = false
    @State private var showingVideoPicker = false
    @State private var showingVideoPlayer = false
    @State private var selectedVideoForPlayback: URL? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header Section
                VStack(spacing: 10) {
                    Image(systemName: "video.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Video Recorder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Record or pick videos from your gallery")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Record Button Section
                VStack(spacing: 15) {
                    Button(action: {
                        print("📹 ContentView: Record button tapped")
                        viewModel.startRecording()
                    }) {
                        HStack {
                            Image(systemName: "record.circle")
                                .font(.title2)
                            Text("Record Video")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isRecording)
                    
                    if viewModel.isRecording {
                        Text("Recording: \(String(format: "%.1f", viewModel.recordingDuration))s")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Gallery Picker Section
                VStack(spacing: 15) {
                    Button(action: {
                        print("📹 ContentView: Gallery picker button tapped")
                        chooseVideoFromGallery()
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title2)
                            Text("Pick Video from Gallery")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    if isPickerActive {
                        Text("Picker Active: \(String(format: "%.1f", pickerDuration))s")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                // Video Player Section
                if let url = galleryVideoURL {
                    VStack(spacing: 10) {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        Button(action: {
                            selectedVideoForPlayback = url
                            showingVideoPlayer = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Play Video in Full Screen")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                
                // Recorded Video Section
                if let url = viewModel.recordedVideoURL {
                    VStack(spacing: 10) {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        Button(action: {
                            selectedVideoForPlayback = url
                            showingVideoPlayer = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Play Recorded Video in Full Screen")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Video Recorder")
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
            .fullScreenCover(isPresented: $showingVideoPlayer) {
                if let videoURL = selectedVideoForPlayback {
                    VideoPlayerView(videoURL: videoURL)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func chooseVideoFromGallery() {
        print("📹 ContentView: Starting video picker")
        
        VideoPicker.shared.chooseVideo { videoURL in
            DispatchQueue.main.async {
                self.isPickerActive = false
                self.pickerDuration = 0
                
                if let videoURL = videoURL {
                    print("📹 ContentView: Video selected: \(videoURL)")
                    self.galleryVideoURL = videoURL
                    
                    // Auto-play the video in full screen
                    self.selectedVideoForPlayback = videoURL
                    self.showingVideoPlayer = true
                } else {
                    print("📹 ContentView: No video selected or picker cancelled")
                }
            }
        } progress: { duration in
            DispatchQueue.main.async {
                self.isPickerActive = true
                self.pickerDuration = duration
            }
        }
    }
}

// MARK: - Video Player View

struct VideoPlayerView: View {
    let videoURL: URL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            VideoPlayer(player: AVPlayer(url: videoURL))
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Auto-play the video
            let player = AVPlayer(url: videoURL)
            player.play()
        }
    }
}

#Preview {
    ContentView()
} 
