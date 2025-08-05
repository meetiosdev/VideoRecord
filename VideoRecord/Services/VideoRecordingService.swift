//
//  VideoRecordingService.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import UIKit
import AVFoundation
import Photos

/// Service responsible for handling video recording operations
@MainActor
final class VideoRecordingService: NSObject, ObservableObject {
    /// Current recording state
    @Published var isRecording = false
    
    /// URL of the recorded video
    @Published var recordedVideoURL: URL?
    
    /// Error message if recording fails
    @Published var errorMessage: String?
    
    /// Duration of the current recording
    @Published var recordingDuration: TimeInterval = 0
    
    /// Whether recording can be stopped
    @Published var canStopRecording = false
    
    /// Minimum recording duration in seconds
    private let minRecordingTime: TimeInterval = 5.0
    
    /// Maximum recording duration in seconds
    private let maxRecordingTime: TimeInterval = 60.0
    
    /// Completion handler for recording operations
    private var completionHandler: ((Result<URL, VideoRecordingError>) -> Void)?
    
    /// Start time of the current recording
    private var recordingStartTime: Date?
    
    /// Timer for tracking recording duration
    private var recordingTimer: Timer?
    
    override init() {
        super.init()
    }
    
    /// Starts video recording using native camera
    /// - Parameters:
    ///   - viewController: The view controller to present the camera from
    ///   - completion: Completion handler called with the result
    func startRecording(
        from viewController: UIViewController,
        completion: @escaping (Result<URL, VideoRecordingError>) -> Void
    ) {
        self.completionHandler = completion
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(.failure(.cameraNotAvailable))
            return
        }
        
        checkCameraPermission { [weak self] granted in
            Task { @MainActor in
                if granted {
                    self?.openNativeCamera(from: viewController)
                } else {
                    completion(.failure(.permissionDenied))
                }
            }
        }
    }
    
    /// Checks camera permission status
    /// - Parameter completion: Completion handler with permission result
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
    
    /// Opens the native camera interface
    /// - Parameter viewController: The view controller to present from
    private func openNativeCamera(from viewController: UIViewController) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.videoQuality = .typeHigh
        imagePicker.allowsEditing = true
        imagePicker.videoMaximumDuration = maxRecordingTime
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen
        viewController.present(imagePicker, animated: true)
    }
    
    /// Validates the recording duration against constraints
    /// - Parameter duration: The duration to validate
    /// - Returns: Whether the duration is valid
    private func validateRecordingDuration(_ duration: TimeInterval) -> Bool {
        return duration >= minRecordingTime && duration <= maxRecordingTime
    }
}

// MARK: - UIImagePickerControllerDelegate
extension VideoRecordingService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            if let mediaURL = info[.mediaURL] as? URL {
                let asset = AVURLAsset(url: mediaURL)
                let duration = CMTimeGetSeconds(asset.duration) // Using deprecated API for compatibility
                
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
        picker.dismiss(animated: true) { [weak self] in
            self?.completionHandler?(.failure(.unknown))
        }
    }
}
