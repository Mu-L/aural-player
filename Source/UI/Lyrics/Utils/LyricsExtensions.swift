//
// LyricsExtensions.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import LyricsCore
import LyricsXCore

extension LyricsCore.Lyrics {
    
    var offset: TimeInterval {
        
        if let offsetTag = self.idTags[.offset], let theOffset = TimeInterval(offsetTag) {
            return theOffset
        }
        
        return 0
    }
    
    /// Saves lyrics to the lyrics directory with .lrcx format.
    func persistToFile(_ fileName: String) {
        
        let url = FilesAndPaths.lyricsDir.appendingPathComponent(fileName + ".lrcx")
        persistLyrics(self, to: url)
    }
    
    func maxPosition(ofLineAtIndex index: Int, maxPossiblePosition: TimeInterval) -> TimeInterval {
        
        let line = lines[index]
        
        if let timeTagDuration = line.timeTags.last?.time, timeTagDuration > 0 {
            return line.position + timeTagDuration
        }
        
        if index < self.lastIndex {
            return lines[index + 1].position - 0.001
        }
        
        return maxPossiblePosition
    }

    /// Persists lyrics content to a file
    ///
    /// - Parameters:
    ///   - lyrics: The lyrics to save
    ///   - url: The destination URL
    ///
    private func persistLyrics(_ lyrics: LyricsCore.Lyrics, to url: URL) {
        
        url.parentDir.createDirectory()

        do {
            try lyrics.description.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write lyrics to \(url.path): \(error.localizedDescription)")
        }
    }
}

extension LyricsLine {

    var timeTags: [Attachments.InlineTimeTag.Tag] {
        attachments.timetag?.tags ?? []
    }

    var timeTagDuration: TimeInterval {
        timeTags.last?.time ?? 0
    }
}

enum LyricsLineRelativePosition {
    
    case match
    case left
    case right
}

extension Track {

    
}
