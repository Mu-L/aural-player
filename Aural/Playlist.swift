/*
 Encapsulates all track information of a playlist. Contains logic to determine playback order for different modes (repeat, shuffle, etc).
 */

import Foundation
import AVFoundation

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

class Playlist {
    
    fileprivate var tracks: [Track] = [Track]()
    fileprivate var tracksByFilename: [String: Track] = [String: Track]()
    
    // Indexes of tracks that have already been shuffled (played) ... don't repeat these
    // Used with RepeatMode.OFF
    fileprivate var shuffleTracks: [Int] = [Int]()
    
    // The next track in the sequence if continuePlaying() is called
//    fileprivate var continuePlayingTrackIndex: Int?
//    
//    // The next track in the sequence if next() is called
//    fileprivate var nextTrackIndex: Int?
    
    // Singleton instance
    fileprivate static var singleton: Playlist = Playlist()
    
    fileprivate init() {}
    
    static func instance() -> Playlist {
        return singleton
    }
    
    // Resets the sequence of shuffle tracks (when some setting is changed, thus invalidating the shuffle sequence, e.g. when the shuffle mode is turned OFF and ON again)
    func clearShuffleSequence() {
        shuffleTracks.removeAll()
//        nextTrackIndex = nil
//        continuePlayingTrackIndex = nil
    }
    
    func isEmpty() -> Bool {
        return tracks.count == 0
    }
    
    func size() -> Int {
        return tracks.count
    }
    
    func totalDuration() -> Double {
        
        var totalDuration: Double = 0
        
        for track in tracks {
            totalDuration += track.duration!
        }
        
        return totalDuration
    }
    
    func getTrackAt(_ index: Int) -> Track? {
        return tracks[index]
    }
    
    // Add a track to this playlist and return its index
    func addTrack(_ file: URL) -> Int {
        
        let track: Track? = TrackIO.loadTrack(file)
        
        if (track != nil && !trackExists(file.path)) {
            tracks.append(track!)
            tracksByFilename[file.path] = track
            clearShuffleSequence()
            return tracks.count - 1
        }
        
        // This means nothing was added
        return -1
    }
    
    func trackExists(_ filename: String) -> Bool {
        return tracksByFilename[filename] != nil
    }
    
    // Add a saved playlist (all its tracks) to this current playlist
    // Calls into a callback function upon adding each new track in the saved playlist, so that observers may perform necessary updates
    func addPlaylist(_ savedPlaylist: SavedPlaylist, _ trackAddedCallback: (_ trackIndex: Int) -> Void) {
        
        for trackFile in savedPlaylist.trackFiles {
            if (!trackExists(trackFile.path)) {
                let trackIndex = addTrack(trackFile)
                if (trackIndex >= 0) {
                    trackAddedCallback(trackIndex)
                }
            }
        }
        
        clearShuffleSequence()
    }
    
    func removeTrack(_ index: Int) {
        let track: Track? = tracks[index]
        
        if (track != nil) {
            tracksByFilename.removeValue(forKey: track!.file!.path)
            tracks.remove(at: index)
            
            clearShuffleSequence()
        }
    }
    
    // Determines the next track to play when playback of a (previous) track has completed and no user input has been provided to select the next track to play
    func continuePlaying(_ playingTrack: Track?, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) -> Track? {
        
        if (tracks.isEmpty) {
            return nil
        }
        
        // The next track in the sequence should already have been determined and stored in continuePlayingTrackIndex. If it has, just use that index to return the next track to play. Otherwise, compute the next track.
//        if (continuePlayingTrackIndex != nil) {
//            
//            if (repeatMode == .off && shuffleMode == .on) {
//                
//                // Need to modify the shuffle sequence state
//                
//                // If the sequence is complete (all tracks played), reset it
//                if (shuffleTracks.count == tracks.count) {
//                    clearShuffleSequence()
//                } else {
//                    shuffleTracks.append(continuePlayingTrackIndex!)
//                }
//            }
//            return tracks[continuePlayingTrackIndex!]
//        }
        
        // Compute the next track
        let index = tracks.index(where: {$0 == playingTrack})
        
        if (repeatMode == .off) {
            
            if (shuffleMode == .off) {
                
                // Next track sequentially
                if (index != nil && index < (tracks.count - 1)) {
                    
                    // Has more tracks, pick the next one
                    return tracks[index! + 1]
                    
                } else if (playingTrack == nil) {
                    
                    // Nothing playing, return the first one
                    return tracks.first
                    
                } else {
                    
                    // Last track reached, nothing further to play
                    return nil
                }
                
            } else {
                
                // If the sequence is complete (all tracks played), reset it
                if (shuffleTracks.count == tracks.count) {
                    clearShuffleSequence()
                    return nil
                }
                
                // Pick a track that's not already been played (every track once)
                var random = Int(arc4random_uniform(UInt32(tracks.count)))
                while (shuffleTracks.contains(random)) {
                    random = Int(arc4random_uniform(UInt32(tracks.count)))
                }
                
                // Found a new random track, play it
                shuffleTracks.append(random)
                return tracks[random]
            }
            
        } else if (repeatMode == .one) {
            
            // Easy, just play the same thing, regardless of shuffleMode
            
            if (playingTrack == nil) {
                return tracks.first
            } else {
                return playingTrack
            }
            
        } else if (repeatMode == RepeatMode.all) {
            
            // If only one track exists, repeat it
            if (tracks.count == 1) {
                return tracks.first
            }
            
            if (shuffleMode == .off) {
                // Similar to repeat OFF, just don't stop at the end
                
                // Next track sequentially
                if (index != nil && index < (tracks.count - 1)) {
                    
                    // Has more tracks, pick the next one
                    return tracks[index! + 1]
                    
                } else if (playingTrack == nil) {
                    
                    // Nothing playing, return the first one
                    return tracks.first
                    
                } else {
                    
                    // Last track reached, restart with the first track
                    return tracks.first
                }
            } else {
                
                // Pick any track (just not the one currently playing)
                var random = Int(arc4random_uniform(UInt32(tracks.count)))
                
                if (playingTrack != nil) {
                    while (random == tracks.index(of: playingTrack!)) {
                        random = Int(arc4random_uniform(UInt32(tracks.count)))
                    }
                }
                
                // Found a new random track, play it
                return tracks[random]
            }
        }
        
        return nil
    }
    
    // Determines the next track to play when the user has requested the next track
    func next(_ playingTrack: Track?, repeatMode: RepeatMode, shuffleMode: ShuffleMode) -> Track? {
        
        // There is no next track if no track is currently playing
        if (tracks.isEmpty || playingTrack == nil) {
            return nil
        }
        
        // The next track in the sequence should already have been determined and stored in nextTrackIndex. If it has, just use that index to return the next track to play. Otherwise, compute the next track.
//        if (nextTrackIndex != nil) {
//            
//            if (repeatMode == .off && shuffleMode == .on) {
//                
//                // Need to modify the shuffle sequence state
//                
//                // If the sequence is complete (all tracks played), reset it
//                if (shuffleTracks.count == tracks.count) {
//                    clearShuffleSequence()
//                } else {
//                    shuffleTracks.append(nextTrackIndex!)
//                }
//            }
//            
//            return tracks[nextTrackIndex!]
//        }
        
        // Compute the next track
        let index = tracks.index(where: {$0 == playingTrack})
        
        if (repeatMode == .off) {
            
            if (shuffleMode == .off) {
                
                // Next track sequentially
                if (index != nil && index < (tracks.count - 1)) {
                    
                    // Has more tracks, pick the next one
                    return tracks[index! + 1]
                    
                } else if (playingTrack == nil) {
                    
                    // Nothing playing, return the first one
                    return tracks.first
                    
                } else {
                    
                    // Last track reached, nothing further to play
                    return nil
                }
                
            } else {
                
                // If the sequence is complete (all tracks played), reset it
                if (shuffleTracks.count == tracks.count) {
                    clearShuffleSequence()
                    return nil
                }
                
                // Pick a track that's not already been played (every track once)
                var random = Int(arc4random_uniform(UInt32(tracks.count)))
                while (shuffleTracks.contains(random)) {
                    random = Int(arc4random_uniform(UInt32(tracks.count)))
                }
                
                // Found a new random track, play it
                shuffleTracks.append(random)
                return tracks[random]
            }
            
        } else if (repeatMode == .one) {
            
            // NOTE - Here, we can assume that shuffleMode = OFF
            
            // Next track sequentially
            if (index != nil && index < (tracks.count - 1)) {
                
                // Has more tracks, pick the next one
                return tracks[index! + 1]
                
            } else {
                // Last track reached, repeat same track
                return nil
            }
            
        } else if (repeatMode == RepeatMode.all) {
            
            // If only one track exists, repeat it
            if (tracks.count == 1) {
                return tracks.first
            }
            
            if (shuffleMode == .off) {
                // Similar to repeat OFF, just don't stop at the end
                
                // Next track sequentially
                if (index != nil && index < (tracks.count - 1)) {
                    
                    // Has more tracks, pick the next one
                    return tracks[index! + 1]
                    
                } else if (playingTrack == nil) {
                    
                    // Nothing playing, return the first one
                    return tracks.first
                    
                } else {
                    
                    // Last track reached, restart with the first track
                    return tracks.first
                }
            } else {
                
                // Pick any track (just not the one currently playing)
                var random = Int(arc4random_uniform(UInt32(tracks.count)))
                
                if (playingTrack != nil) {
                    while (random == tracks.index(of: playingTrack!)) {
                        random = Int(arc4random_uniform(UInt32(tracks.count)))
                    }
                }
                
                // Found a new random track, play it
                return tracks[random]
            }
        }
        
        return nil
    }
    
    // Determines the next track to play when the user has requested the previous track
    func previous(_ playingTrack: Track?, repeatMode: RepeatMode, shuffleMode: ShuffleMode) -> Track? {
        
        if (tracks.isEmpty || playingTrack == nil || shuffleMode == ShuffleMode.on) {
            return nil
        }
        
        let index = tracks.index(where: {$0 == playingTrack})
        
        if (repeatMode == RepeatMode.off) {
            
            // Previous track sequentially
            if (index != nil && index! > 0) {
                
                // Has more tracks, pick the previous one
                return tracks[index! - 1]
                
            } else {
                
                // First track reached, nothing further to play
                return nil
            }
            
        } else if (repeatMode == RepeatMode.one) {
            
            // Previous track sequentially
            if (index != nil && index! > 0) {
                
                // Has more tracks, pick the previous one
                return tracks[index! - 1]
                
            } else {
                
                // First track reached, keep playing the same thing
                return nil
            }
            
        } else if (repeatMode == RepeatMode.all) {
            
            // Similar to repeat OFF, just don't stop at the end
            
            // Previous track sequentially
            if (index != nil && index! > 0) {
                
                // Has more tracks, pick the next one
                return tracks[index! - 1]
                
            } else {
                
                // Last track reached, cycle back to the last track
                return tracks.last
            }
        }
        
        return nil
    }
    
    func indexOf(_ track: Track) -> Int?  {
        return tracks.index(where: {$0 == track})
    }
    
    func clear() {
        tracks.removeAll()
        tracksByFilename.removeAll()
        clearShuffleSequence()
    }
    
    func getTracks() -> [Track] {
        return tracks
    }
    
    // Shifts a single track up in the playlist order
    func shiftTrackUp(_ track: Track) {
        
        let index: Int = tracks.index(of: track)!
        
        if (index > 0) {
            let upIndex = index - 1
            swapTracks(index, trackIndex2: upIndex)
            clearShuffleSequence()
        }
    }
    
    // Shifts a single track down in the playlist order
    func shiftTrackDown(_ track: Track) {
        
        let index: Int = tracks.index(of: track)!
        
        if (index < (tracks.count - 1)) {
            let downIndex = index + 1
            swapTracks(index, trackIndex2: downIndex)
            clearShuffleSequence()
        }
    }
    
    // Swaps two tracks in the array of tracks
    fileprivate func swapTracks(_ trackIndex1: Int, trackIndex2: Int) {
        swap(&tracks[trackIndex1], &tracks[trackIndex2])
    }
    
    // Searches the playlist for all tracks matching the specified criteria, and returns a set of results
    func searchPlaylist(searchQuery: SearchQuery) -> SearchResults {
        
        var results: [SearchResult] = [SearchResult]()
        
        for i in 0...tracks.count - 1 {
            
            let track = tracks[i]
            let match = trackMatchesQuery(track: track, searchQuery: searchQuery)
            
            if (match.matched) {
                results.append(SearchResult(index: i, match: (match.matchedField!, match.matchedFieldValue!)))
            }
        }
        
        return SearchResults(results: results)
    }
    
    // Checks if a single track matches search criteria, returns information about the match, if there is one
    fileprivate func trackMatchesQuery(track: Track, searchQuery: SearchQuery) -> (matched: Bool, matchedField: String?, matchedFieldValue: String?) {
        
        let caseSensitive: Bool = searchQuery.options.caseSensitive
        
        let queryText: String = caseSensitive ? searchQuery.text : searchQuery.text.lowercased()
        
        // Actual track fields to compare to query text
        // FieldName -> (OriginalFieldValue, FieldValueForComparison)
        // FieldValueForComparison is used for the comparison (and may have different case than OriginalFieldValue), while OriginalFieldValue is returned in the result if there is a match
        var trackFields: [String: (original: String, compared: String)] = [String: (String, String)]()
        
        // Add name field if included in search
        if (searchQuery.fields.name) {
            
            // Check both the filename and the display name
            
            let lastPathComponent = track.file!.deletingPathExtension().lastPathComponent
            
            trackFields["Filename"] = (lastPathComponent, caseSensitive ? lastPathComponent : lastPathComponent.lowercased())
            
            let displayName = track.shortDisplayName!
            trackFields["Name"] = (displayName, caseSensitive ? displayName : displayName.lowercased())
        }
        
        // Add artist field if included in search
        if (searchQuery.fields.artist) {
            
            if let artist = track.metadata?.artist {
                trackFields["Artist"] = (artist, caseSensitive ? artist : artist.lowercased())
            }
        }
        
        // Add title field if included in search
        if (searchQuery.fields.title) {
            
            if let title = track.metadata?.title {
                trackFields["Title"] = (title, caseSensitive ? title : title.lowercased())
            }
        }
        
        // Add album field if included in search
        if (searchQuery.fields.album) {
            
            // Make sure album info has been loaded (it is loaded lazily)
            TrackIO.loadExtendedMetadataForSearch(track)
            
            if let album = track.extendedMetadata["albumName"] {
                trackFields["Album"] = (album, caseSensitive ? album : album.lowercased())
            }
        }
        
        // Check each field value against the search query text
        for (key: field, value: (original: original, compared: compared)) in trackFields {
            
            switch searchQuery.type {
                
            case .beginsWith: if compared.hasPrefix(queryText) {
                return (true, field, original)
                }
                
            case .endsWith: if compared.hasSuffix(queryText) {
                return (true, field, original)
                }
                
            case .equals: if compared == queryText {
                return (true, field, original)
                }
                
            case .contains: if compared.range(of: queryText) != nil {
                return (true, field, original)
                }
            }
        }
        
        // Didn't match
        return (false, nil, nil)
    }
    
    func sortPlaylist(sort: Sort) {
        
        switch sort.field {
            
        // Sort by name
        case .name: if sort.order == SortOrder.ascending {
            tracks.sort(by: compareTracks_ascendingByName)
        } else {
            tracks.sort(by: compareTracks_descendingByName)
            }
            
        // Sort by duration
        case .duration: if sort.order == SortOrder.ascending {
            tracks.sort(by: compareTracks_ascendingByDuration)
        } else {
            tracks.sort(by: compareTracks_descendingByDuration)
            }
        }
    }
    
    // Comparison functions for different sort criteria
    
    func compareTracks_ascendingByName(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.shortDisplayName?.compare(anotherTrack.shortDisplayName!) == ComparisonResult.orderedAscending
    }
    
    func compareTracks_descendingByName(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.shortDisplayName?.compare(anotherTrack.shortDisplayName!) == ComparisonResult.orderedDescending
    }
    
    func compareTracks_ascendingByDuration(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.duration! < anotherTrack.duration!
    }
    
    func compareTracks_descendingByDuration(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.duration! > anotherTrack.duration!
    }
    
    // Determines all possible tracks which might play next, based on the repeat/shuffle modes
   /* func determineNextTrack(_ playingTrack: Track?, repeatMode: RepeatMode, shuffleMode: ShuffleMode) -> [Track] {
        
        var nextTracks: [Track] = [Track]()
        
        if (tracks.isEmpty) {
            nextTrackIndex = nil
            continuePlayingTrackIndex = nil
            return nextTracks
        }
        
        // TODO: Make this more efficient
        let playingTrackIndex = tracks.index(where: {$0 == playingTrack})
        
        if (repeatMode == RepeatMode.off) {
            
            if (shuffleMode == .off) {
                
                // Next track sequentially
                if (playingTrackIndex != nil && playingTrackIndex < (tracks.count - 1)) {
                    
                    // Has more tracks, pick the next one
                    nextTrackIndex = playingTrackIndex! + 1
                    continuePlayingTrackIndex = nextTrackIndex
                } else {
                    
                    // Last track reached, nothing further to play
                    nextTrackIndex = nil
                    continuePlayingTrackIndex = nextTrackIndex
                }
            } else {
                
                // If the sequence is complete (all tracks played), end it
                if (shuffleTracks.count == tracks.count) {
                    nextTrackIndex = nil
                    continuePlayingTrackIndex = nextTrackIndex
                } else {
                    
                    // Pick a track that's not already been played (every track once)
                    var random = Int(arc4random_uniform(UInt32(tracks.count)))
                    while (shuffleTracks.contains(random)) {
                        random = Int(arc4random_uniform(UInt32(tracks.count)))
                    }
                    
                    // Found a new random track, choose it
                    nextTrackIndex = random
                    continuePlayingTrackIndex = nextTrackIndex
                }
            }
            
        } else if (repeatMode == RepeatMode.one) {
            
            if (playingTrack == nil) {
                
                continuePlayingTrackIndex = 0
                nextTrackIndex = nil
                
            } else {
                
                // Continue with same track
                continuePlayingTrackIndex = playingTrackIndex!
                
                // Next track sequentially
                if (playingTrackIndex != nil && playingTrackIndex < (tracks.count - 1)) {
                    
                    // Has more tracks, pick the next one
                    nextTrackIndex = playingTrackIndex! + 1
                    
                } else {
                    
                    // Last track reached, repeat same track
                    nextTrackIndex = nil
                }
            }
            
        } else if (repeatMode == RepeatMode.all) {
            
            if (shuffleMode == .off) {
                // Similar to repeat OFF, just don't stop at the end
                
                // Next track sequentially
                if (playingTrackIndex != nil && playingTrackIndex < (tracks.count - 1)) {
                    
                    // Has more tracks, pick the next one
                    nextTrackIndex = playingTrackIndex! + 1
                    continuePlayingTrackIndex = nextTrackIndex
                    
                } else {
                    
                    // Last track reached, cycle back to the first track
                    nextTrackIndex = 0
                    continuePlayingTrackIndex = nextTrackIndex
                }
            } else {
                
                // If only one track exists, repeat it
                if (tracks.count == 1) {
                    nextTrackIndex = 0
                    continuePlayingTrackIndex = nextTrackIndex
                } else {
                    
                    // Pick any track (just not the one currently playing)
                    var random = Int(arc4random_uniform(UInt32(tracks.count)))
                    
                    if (playingTrack != nil) {
                        while (random == playingTrackIndex!) {
                            random = Int(arc4random_uniform(UInt32(tracks.count)))
                        }
                    }
                    
                    // Found a new random track, choose it
                    nextTrackIndex = random
                    continuePlayingTrackIndex = nextTrackIndex
                }
            }
        }
        
        if (nextTrackIndex != nil) {
            nextTracks.append(tracks[nextTrackIndex!])
        }
        
        // Add continuePlayingTrackIndex only if it differs from nextTrackIndex
        if (continuePlayingTrackIndex != nil && !nilSafeIntEquals(int1: nextTrackIndex, int2: continuePlayingTrackIndex)) {
            nextTracks.append(tracks[continuePlayingTrackIndex!])
        }
        
        return nextTracks
    }
    
    private func nilSafeIntEquals(int1: Int?, int2: Int?) -> Bool {
        
        // Return true only if both are non-nil and equal in value
        if (int1 != nil && int2 != nil) {
            return int1! == int2!
        }
        
        return false
    }*/
}
