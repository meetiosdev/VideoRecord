//
//  VideoRecorder.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import UIKit
import AVFoundation
import Photos
import Combine

enum VideoRecorderError: Error {
    case cameraNotAvailable
    case permissionDenied
    case recordingFailed
    case recordingTooShort
    case recordingTooLong
    case unknown
}

class VideoRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordedVideoURL: URL?
    @Published var errorMessage: String?
    @Published var recordingDuration: TimeInterval = 0
    @Published var canStopRecording = false
    
    private var completionHandler: ((Result<URL, VideoRecorderError>) -> Void)?
    private var recordingStartTime: Date?
    private var recordingTimer: Timer?
    
    // Recording time limits
    private let minRecordingTime: TimeInterval = 5.0
    private let maxRecordingTime: TimeInterval = 60.0
    
    override init() {
        super.init()
    }
    
    func startRecording(from viewController: UIViewController, completion: @escaping (Result<URL, VideoRecorderError>) -> Void) {
        self.completionHandler = completion
        
        // Check camera availability
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(.failure(.cameraNotAvailable))
            return
        }
        
        // Check camera permission
        checkCameraPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.openNativeCamera(from: viewController)
                } else {
                    completion(.failure(.permissionDenied))
                }
            }
        }
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func openNativeCamera(from viewController: UIViewController) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.videoQuality = .typeHigh
        imagePicker.videoMaximumDuration = maxRecordingTime
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen
        viewController.present(imagePicker, animated: true)
    }
    
    private func validateRecordingDuration(_ duration: TimeInterval) -> Bool {
        return duration >= minRecordingTime && duration <= maxRecordingTime
    }
}

// MARK: - UIImagePickerControllerDelegate
extension VideoRecorder: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
                            if let mediaURL = info[.mediaURL] as? URL {
                    // Get video duration
                    let asset = AVURLAsset(url: mediaURL)
                    let duration = CMTimeGetSeconds(asset.duration)
                
                if self.validateRecordingDuration(duration) {
                    self.recordedVideoURL = mediaURL
                    self.completionHandler?(.success(mediaURL))
                } else {
                    // Delete invalid recording
                    try? FileManager.default.removeItem(at: mediaURL)
                    
                    if duration < self.minRecordingTime {
                        self.completionHandler?(.failure(.recordingTooShort))
                    } else {
                        self.completionHandler?(.failure(.recordingTooLong))
                    }
                }
            } else {
                self.completionHandler?(.failure(.recordingFailed))
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.completionHandler?(.failure(.unknown))
        }
    }
} 