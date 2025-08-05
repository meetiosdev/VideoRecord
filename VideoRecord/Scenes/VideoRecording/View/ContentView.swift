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
            print("📹 Gallery Video Import: Copy file path: \(copy.path())")
            
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: received.file, to: copy)
            print("📹 Gallery Video Import: Successfully copied video to: \(copy.path())")
            return Self.init(url: copy)
        }
    }
}

struct ContentView: View {
    /// ViewModel for managing video recording state
    @StateObject private var viewModel = VideoRecordingViewModel()
    @State private var selectedGalleryItem: PhotosPickerItem? = nil
    @State private var galleryVideoURL: URL? = nil
    @State private var pickerDuration: TimeInterval = 0
    @State private var isPickerActive = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                headerSection
                Spacer()
                recordButtonSection
                galleryPickerSection
                videoPlayerSection
                Spacer()
            }
            .padding()
            .navigationTitle("Video Recorder")
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "video.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Video Recorder")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Record or pick videos from your gallery")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var recordButtonSection: some View {
        VStack(spacing: 20) {
            Button(action: {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }) {
                HStack {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "record.circle")
                        .font(.title2)
                    Text(viewModel.isRecording ? "Stop Recording" : "Start Recording")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewModel.isRecording ? Color.red : Color.blue)
                .cornerRadius(12)
            }
            
            if viewModel.isRecording {
                Text("Recording: \(String(format: "%.1f", viewModel.recordingDuration))s")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var galleryPickerSection: some View {
        VStack(spacing: 15) {
            Button(action: {
                print("📹 Gallery Picker: Button tapped")
                chooseVideoFromGallery()
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                    Text("Pick Video from Gallery")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(12)
            }
            
            if isPickerActive {
                Text("Picker Active: \(String(format: "%.1f", pickerDuration))s")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            if let url = galleryVideoURL {
                Text("Selected: \(url.lastPathComponent)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }
    
    private var videoPlayerSection: some View {
        VStack(spacing: 15) {
            if let videoURL = viewModel.recordedVideoURL ?? galleryVideoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                HStack {
                    Button("Play") {
                        // VideoPlayer handles play automatically
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("Clear") {
                        viewModel.recordedVideoURL = nil
                        galleryVideoURL = nil
                    }
                    .foregroundColor(.red)
                }
                .padding(.horizontal)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "video.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No video selected")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func chooseVideoFromGallery() {
        print("📹 ContentView: Starting video picker")
        
        VideoPicker.shared.chooseVideo { videoURL in
            DispatchQueue.main.async {
                if let videoURL = videoURL {
                    print("📹 ContentView: Video selected: \(videoURL)")
                    self.galleryVideoURL = videoURL
                } else {
                    print("📹 ContentView: No video selected or picker cancelled")
                }
            }
        }
    }
}

#Preview {
    ContentView()
} 
