//
//  AVFMappedMetadata.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// A "metadata map" that organizes a natively supported (by **AVFoundation**) track's metadata based on
/// metadata format (ID3, iTunes, etc).
///
/// It functions as an efficient data structure for repeated lookups by metadata parsers.
///
struct AVFMappedMetadata {
    
    ///
    /// The file whose metadata is held in this object.
    ///
    let file: URL
    
    ///
    /// The AVFoundation asset object from which metadata is obtained.
    ///
    let avAsset: AVURLAsset
    
    ///
    /// The AVFoundation audio track object that contains track-level information (such as bit rate).
    ///
    let audioTrack: AVAssetTrack
    
    let audioFormat: AVAudioFormat
    
    ///
    /// The following dictionaries contain mappings of key -> AVMetadataItem for each of the supported metadata key spaces.
    /// Metadata parsers can use these maps to quickly look up items having specific keys (e.g. "title" or "artist").
    ///
    var common: [String: AVMetadataItem] = [:]
    var id3: [String: AVMetadataItem] = [:]
    var iTunes: [String: AVMetadataItem] = [:]
    var audioToolbox: [String: AVMetadataItem] = [:]
    
    ///
    /// A collection of all the key spaces for which this track contains any metadata.
    /// Used to determine which parsers are needed to load metadata for this particular track.
    ///
    var keySpaces: [AVMetadataKeySpace] = []
    
    init?(file: URL) {
        
        self.file = file
        self.avAsset = AVURLAsset(url: file, options: nil)
        
        guard let audioTrack = avAsset.tracks.first(where: {$0.mediaType == .audio}) else {return nil}
        
        self.audioTrack = audioTrack
        self.audioFormat = .init(cmAudioFormatDescription: audioTrack.formatDescription)
        
        // Iterate through all metadata items, and group them based on
        // key space.
        
        let allMetadata = avAsset.metadata + avAsset.commonMetadata + audioTrack.commonMetadata
        
        for item in allMetadata {
            
            // Determine key space for this item
            guard let keySpace = item.keySpace, let key = item.keyAsString else {continue}
            
            // Put the item in its appropriate dictionary.
            
            switch keySpace {
            
            case .id3:
                
                id3[key] = item
                
            case .iTunes:
                
                iTunes[key] = item
                
            case .common:
                
                common[key] = item
                
            default:
                
                // iTunes long format
                
                if keySpace.rawValue.lowercased() == ITunesSpec.longForm_keySpaceID {
                    iTunes[key] = item
                    
                } else if keySpace == .audioFile {
                    audioToolbox[key] = item
                }
            }
        }
        
        // Determine which key spaces we have any metadata for.
        
        if !common.isEmpty {
            keySpaces.append(.common)
        }
        
        let fileExt = file.lowerCasedExtension
        
        switch fileExt {
            
        case "m4a", "m4b", "aac", "alac":
            
            // These files will commonly have iTunes metadata
            
            keySpaces.append(.iTunes)
            
            // ... and ID3 metadata, if present
            if !id3.isEmpty {
                keySpaces.append(.id3)
            }
            
        default:
            
            // Assume ID3 metadata is present (it's a common format)
            keySpaces.append(.id3)
            
            // ... and iTunes metadata, if present
            if !iTunes.isEmpty {
                keySpaces.append(.iTunes)
            }
        }
    }
}
