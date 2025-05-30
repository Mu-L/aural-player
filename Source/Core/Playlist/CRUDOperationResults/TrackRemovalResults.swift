//
//  TrackRemovalResults.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Contains the aggregated results of removing a set of tracks / groups from each of the playlist types.
///
struct TrackRemovalResults {
    
    static let empty: TrackRemovalResults = .init(tracks: [], indices: .empty)
    
    /// The tracks that were removed from the playlist.
    let tracks: [Track]
    
    /// Result from the flat playlist (indexes)
    let indices: IndexSet
    
    /// Results from each of the grouping playlists (grouping info)
//    let groupingPlaylistResults: [GroupType: [GroupedItemRemovalResult]]
}
