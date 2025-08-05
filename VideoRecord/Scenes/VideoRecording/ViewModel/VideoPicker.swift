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
@MainActor
final class VideoPicker: NSObject {
    
    /// Shared instance for singleton access
    static let shared = VideoPicker()
    
    /// Completion handler for video selection
    private var completionHandler: ((URL?) -> Void)?
    
    /// Progress handler for timer updates
    private var progressHandler: ((TimeInterval) -> Void)?
    
    /// Current view controller presenting the picker
    private weak var presentingViewController: UIViewController?
    
    /// Timer for tracking picker duration
    private var pickerTimer: Timer?
    
    /// Current picker duration in seconds
    private var pickerDuration: TimeInterval = 0
    
    /// Timer view controller for full screen presentation
    private var timerViewController: UIViewController?
    
    private override init() {
        super.init()
    }
    
    /// Choose video with completion and progress handlers
    /// - Parameters:
    ///   - completion: Completion handler with selected video URL
    ///   - progress: Progress handler for timer updates (optional)
    func chooseVideo(completion: @escaping (URL?) -> Void, progress: ((TimeInterval) -> Void)? = nil) {
        print("📹 VideoPicker: Starting video picker")
        
        self.completionHandler = completion
        self.progressHandler = progress
        
        // Find the top view controller
        guard let topViewController = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() else {
            print("📹 VideoPicker: Could not find top view controller")
            completion(nil)
            return
        }
        
        self.presentingViewController = topViewController
        
        // Create and present image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.videoQuality = .typeHigh
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen
        
        // Start timer and present picker
        startTimer()
        topViewController.present(imagePicker, animated: true)
        
        print("📹 VideoPicker: Picker presented in full screen")
    }
    
    /// Start the picker timer
    private func startTimer() {
        pickerDuration = 0
        progressHandler?(pickerDuration)
        
        pickerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.pickerDuration += 1.0
                print("📹 VideoPicker: Timer - \(self.pickerDuration)s")
                self.progressHandler?(self.pickerDuration)
            }
        }
        
        print("📹 VideoPicker: Timer started")
    }
    
    /// Stop the picker timer
    private func stopTimer() {
        pickerTimer?.invalidate()
        pickerTimer = nil
        print("📹 VideoPicker: Timer stopped at \(pickerDuration)s")
    }
}

// MARK: - UIImagePickerControllerDelegate

extension VideoPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("📹 VideoPicker: User finished picking video")
        
        // Stop timer
        stopTimer()
        
        if let mediaURL = info[.mediaURL] as? URL {
            print("📹 VideoPicker: Got media URL: \(mediaURL)")
            
            // Copy the video to documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "gallery_video_\(Date().timeIntervalSince1970).mp4"
            let copyURL = documentsPath.appendingPathComponent(fileName)
            
            do {
                if FileManager.default.fileExists(atPath: copyURL.path) {
                    try FileManager.default.removeItem(at: copyURL)
                }
                try FileManager.default.copyItem(at: mediaURL, to: copyURL)
                print("📹 VideoPicker: Successfully copied video to: \(copyURL.path)")
                
                // Dismiss picker and call completion
                picker.dismiss(animated: true) {
                    self.completionHandler?(copyURL)
                }
            } catch {
                print("📹 VideoPicker: Error copying video: \(error)")
                
                // Dismiss picker and call completion with original URL
                picker.dismiss(animated: true) {
                    self.completionHandler?(mediaURL)
                }
            }
        } else {
            print("📹 VideoPicker: No media URL found in info")
            
            // Dismiss picker and call completion with nil
            picker.dismiss(animated: true) {
                self.completionHandler?(nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("📹 VideoPicker: User cancelled")
        
        // Stop timer
        stopTimer()
        
        // Dismiss picker and call completion with nil
        picker.dismiss(animated: true) {
            self.completionHandler?(nil)
        }
    }
}

// MARK: - UIViewController Extension

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
} 