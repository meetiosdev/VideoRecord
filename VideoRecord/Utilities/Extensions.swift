//
//  Extensions.swift
//  VideoRecord
//
//  Created by Swarajmeet Singh on 25/07/25.
//

import SwiftUI
import AVFoundation

// MARK: - Color Extensions
extension Color {
    /// Creates a color with the specified hex value
    /// - Parameter hex: The hex color value (e.g., 0xFF0000 for red)
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}

// MARK: - View Extensions
extension View {
    /// Adds a shadow with the specified parameters
    /// - Parameters:
    ///   - color: The shadow color
    ///   - radius: The shadow radius
    ///   - x: The horizontal offset
    ///   - y: The vertical offset
    /// - Returns: A view with the applied shadow
    func customShadow(
        color: Color = .black,
        radius: CGFloat = 10,
        x: CGFloat = 0,
        y: CGFloat = 5
    ) -> some View {
        self.shadow(color: color.opacity(0.3), radius: radius, x: x, y: y)
    }
    
    /// Adds a rounded corner to specific corners
    /// - Parameters:
    ///   - radius: The corner radius
    ///   - corners: The corners to round
    /// - Returns: A view with rounded corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - URL Extensions
extension URL {
    /// Checks if the URL points to a valid video file
    /// - Returns: True if the URL is a valid video file
    var isVideoFile: Bool {
        let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv"]
        return videoExtensions.contains(self.pathExtension.lowercased())
    }
    
    /// Gets the file size in bytes
    /// - Returns: The file size in bytes, or nil if unavailable
    var fileSize: Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: self.path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
}

// MARK: - TimeInterval Extensions
extension TimeInterval {
    /// Formats the time interval as a readable string
    /// - Returns: A formatted time string (e.g., "1:30" for 90 seconds)
    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Checks if the time interval is within the specified range
    /// - Parameters:
    ///   - min: The minimum allowed time
    ///   - max: The maximum allowed time
    /// - Returns: True if the time is within the range
    func isWithinRange(min: TimeInterval, max: TimeInterval) -> Bool {
        return self >= min && self <= max
    }
}

// MARK: - Custom Shapes
/// A shape with rounded corners on specific sides
struct RoundedCorner: Shape {
    /// The corner radius
    let radius: CGFloat
    
    /// The corners to round
    let corners: UIRectCorner
    
    /// Creates the path for the rounded corner shape
    /// - Parameter rect: The rectangle to create the path for
    /// - Returns: A path with rounded corners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - AVAsset Extensions
extension AVAsset {
    /// Gets the duration of the asset in seconds
    /// - Returns: The duration in seconds
    var durationInSeconds: TimeInterval {
        return CMTimeGetSeconds(duration)
    }
    
    /// Checks if the asset is a valid video file
    /// - Returns: True if the asset contains video tracks
    var isVideo: Bool {
        return tracks(withMediaType: .video).count > 0
    }
} 