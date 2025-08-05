//
//  VideoPicker.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import UIKit
import AVFoundation
import Photos

/// Pure Swift 5 UIKit shared class for video picking
final class VideoPicker: NSObject {
    
    /// Shared instance for singleton access
    static let shared = VideoPicker()
    
    /// Completion handler for video selection
    private var completionHandler: ((URL?) -> Void)?
    
    /// Current view controller presenting the picker
    private weak var presentingViewController: UIViewController?
    
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
        
        // Find the top view controller to present from
        guard let topViewController = findTopViewController() else {
            print("❌ VideoPicker: Could not find top view controller")
            completion(nil)
            return
        }
        
        presentingViewController = topViewController
        
        // Present picker
        topViewController.present(picker, animated: true) {
            print("📹 VideoPicker: Picker presented successfully")
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
}

// MARK: - UIImagePickerControllerDelegate

extension VideoPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("📹 VideoPicker: User finished picking video")
        
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
                completionHandler?(copyURL)
            } catch {
                print("📹 VideoPicker: Error copying video: \(error)")
                completionHandler?(mediaURL) // Fallback to original URL
            }
        } else {
            print("📹 VideoPicker: No media URL found in info")
            completionHandler?(nil)
        }
        
        // Dismiss picker
        presentingViewController?.dismiss(animated: true) {
            print("📹 VideoPicker: Picker dismissed")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("📹 VideoPicker: User cancelled")
        
        // Call completion handler with nil
        completionHandler?(nil)
        
        // Dismiss picker
        presentingViewController?.dismiss(animated: true) {
            print("📹 VideoPicker: Picker dismissed after cancellation")
        }
    }
} 