//
//  VideoRecorder.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import UIKit
import AVFoundation
import Photos

enum VideoRecorderError: Error {
    case cameraNotAvailable
    case permissionDenied
    case recordingFailed
    case unknown
}

class VideoRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordedVideoURL: URL?
    @Published var errorMessage: String?
    
    private var imagePickerController: UIImagePickerController?
    private var completionHandler: ((Result<URL, VideoRecorderError>) -> Void)?
    
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
                    self?.openCamera(from: viewController)
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
    
    private func openCamera(from viewController: UIViewController) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.cameraCaptureMode = .video
        picker.videoQuality = .typeHigh
        picker.videoMaximumDuration = 60 // 60 seconds max
        picker.allowsEditing = false
        picker.delegate = self
        
        self.imagePickerController = picker
        viewController.present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension VideoRecorder: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let videoURL = info[.mediaURL] as? URL {
                self.recordedVideoURL = videoURL
                self.completionHandler?(.success(videoURL))
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