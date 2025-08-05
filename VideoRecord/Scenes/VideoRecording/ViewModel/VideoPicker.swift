//
//  VideoPicker.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import UIKit
import AVFoundation
import Photos
import AVKit

/// Pure Swift 5 UIKit shared class for video picking
@MainActor
final class VideoPicker: NSObject {
    
    /// Shared instance for singleton access
    static let shared = VideoPicker()
    
    /// Completion handler for video selection
    private var completionHandler: ((URL?) -> Void)?
    
    /// Current view controller presenting the picker
    private weak var presentingViewController: UIViewController?
    
    /// Video player for playing selected videos
    private var videoPlayer: AVPlayerViewController?
    
    private override init() {
        super.init()
    }
    
    /// Choose video with completion handler
    /// - Parameter completion: Completion handler with selected video URL
    func chooseVideo(completion: @escaping (URL?) -> Void) {
        self.completionHandler = completion
        
        // Create and configure picker
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        // Set presentation style to full screen
        picker.modalPresentationStyle = .fullScreen
        
        // Find the top view controller to present from
        guard let topViewController = findTopViewController() else {
            print("❌ VideoPicker: Could not find top view controller")
            completion(nil)
            return
        }
        
        presentingViewController = topViewController
        
        // Present picker in full screen
        topViewController.present(picker, animated: true) {
            print("📹 VideoPicker: Picker presented in full screen")
        }
    }
    
    /// Find the top view controller to present from
    private func findTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        var topViewController = window.rootViewController
        
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        
        return topViewController
    }
    
    /// Play video with AVPlayerViewController
    /// - Parameter videoURL: URL of the video to play
    private func playVideo(videoURL: URL) {
        print("📹 VideoPicker: Playing video: \(videoURL)")
        
        // Create AVPlayer
        let player = AVPlayer(url: videoURL)
        
        // Create AVPlayerViewController
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // Set presentation style to full screen
        playerViewController.modalPresentationStyle = .fullScreen
        
        // Store reference
        videoPlayer = playerViewController
        
        // Present video player
        presentingViewController?.present(playerViewController, animated: true) {
            print("📹 VideoPicker: Video player presented")
            // Start playing
            player.play()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension VideoPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("📹 VideoPicker: User finished picking video")
        
        // Dismiss picker first
        picker.dismiss(animated: true) {
            print("📹 VideoPicker: Picker dismissed")
            
            if let mediaURL = info[.mediaURL] as? URL {
                print("📹 VideoPicker: Got media URL: \(mediaURL)")
                
                // Copy the video to documents directory
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileName = "picked_video_\(Date().timeIntervalSince1970).mp4"
                let copyURL = documentsPath.appendingPathComponent(fileName)
                
                do {
                    if FileManager.default.fileExists(atPath: copyURL.path) {
                        try FileManager.default.removeItem(at: copyURL)
                    }
                    try FileManager.default.copyItem(at: mediaURL, to: copyURL)
                    print("📹 VideoPicker: Successfully copied video to: \(copyURL.path)")
                    
                    // Call completion handler
                    self.completionHandler?(copyURL)
                    
                    // Play the video
                    self.playVideo(videoURL: copyURL)
                    
                } catch {
                    print("📹 VideoPicker: Error copying video: \(error)")
                    
                    // Call completion handler with original URL
                    self.completionHandler?(mediaURL)
                    
                    // Play the original video
                    self.playVideo(videoURL: mediaURL)
                }
            } else {
                print("📹 VideoPicker: No media URL found in info")
                self.completionHandler?(nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("📹 VideoPicker: User cancelled")
        
        // Dismiss picker
        picker.dismiss(animated: true) {
            print("📹 VideoPicker: Picker dismissed after cancellation")
            
            // Call completion handler with nil
            self.completionHandler?(nil)
        }
    }
} 