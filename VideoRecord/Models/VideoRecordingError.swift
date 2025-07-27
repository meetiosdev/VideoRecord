//
//  VideoRecordingError.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import Foundation

/// Errors that can occur during video recording operations
enum VideoRecordingError: LocalizedError {
    case cameraNotAvailable
    case permissionDenied
    case recordingFailed
    case recordingTooShort
    case recordingTooLong
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .cameraNotAvailable:
            return "Camera is not available on this device"
        case .permissionDenied:
            return "Camera permission is required. Please enable it in Settings"
        case .recordingFailed:
            return "Failed to record video. Please try again"
        case .recordingTooShort:
            return "Recording too short! Please record for at least 5 seconds"
        case .recordingTooLong:
            return "Recording too long! Maximum duration is 60 seconds"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 