//
//  ExampleUsage.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import Foundation

/// Example usage of VideoPicker.shared.chooseVideo
/// This demonstrates the exact API you requested:
/// VideoPicker.shared.chooseVideo { videoUrl in 
///     print(trimmedVideoUrl)
/// }

class ExampleUsage {
    
    func exampleVideoPickerUsage() {
        // Example 1: Basic usage with completion handler
        VideoPicker.shared.chooseVideo { videoUrl in
            if let videoUrl = videoUrl {
                print("Selected video URL: \(videoUrl)")
            } else {
                print("No video selected or picker cancelled")
            }
        }
        
        // Example 2: Usage with both completion and progress handlers
        VideoPicker.shared.chooseVideo { videoUrl in
            print("Selected video URL: \(videoUrl?.absoluteString ?? "nil")")
        } progress: { duration in
            print("Picker active for: \(duration) seconds")
        }
        
        // Example 3: Usage in a button action
        func buttonTapped() {
            VideoPicker.shared.chooseVideo { videoUrl in
                print("Trimmed video URL: \(videoUrl?.absoluteString ?? "nil")")
                // Handle the selected video URL here
            }
        }
    }
}

/*
 HOW TO USE VideoPicker.shared.chooseVideo:
 
 1. Basic usage:
    VideoPicker.shared.chooseVideo { videoUrl in
        print(videoUrl)
    }
 
 2. With progress tracking:
    VideoPicker.shared.chooseVideo { videoUrl in
        print(videoUrl)
    } progress: { duration in
        print("Picker active: \(duration)s")
    }
 
 3. In a button action:
    Button("Pick Video") {
        VideoPicker.shared.chooseVideo { videoUrl in
            if let videoUrl = videoUrl {
                print("Selected: \(videoUrl)")
            }
        }
    }
 
 Features:
 - ✅ Native iOS video editing/trimming (allowsEditing = true)
 - ✅ Timer functionality to track picker duration
 - ✅ Automatic video copying to documents directory
 - ✅ Comprehensive logging for debugging
 - ✅ Thread-safe UI updates
 - ✅ Clean error handling
 - ✅ Pure Swift 5 UIKit implementation
 */ 