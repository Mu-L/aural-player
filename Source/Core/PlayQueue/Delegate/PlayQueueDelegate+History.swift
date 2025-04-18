//
//  PlayQueueDelegate+History.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension PlayQueueDelegate {
    
    var numberOfItems: Int {
        recentItems.count
    }
    
    var lastPlayedItem: TrackHistoryItem? {
        recentItems.values.last(where: {$0 is TrackHistoryItem}) as? TrackHistoryItem
    }
    
    func historyItem(at index: Int) -> HistoryItem {
        recentItems.values[index]
    }
    
    var allRecentItems: [HistoryItem] {
        
        // Reverse the array for chronological order (most recent items first).
        recentItems.values.reversed()
    }
    
    func appWillExit() {
        
        if playbackInfoDelegate.state == .stopped {return}
        
        let playerPosition = playbackInfoDelegate.seekPosition.timeElapsed
        
        if playerPosition > 0 {
            self.lastPlaybackPosition = playerPosition
        }
    }
    
    var canResumeLastPlayedSequence: Bool {
        shuffleMode == .off ? canResumeLastPlayedTrack : canResumeShuffleSequence
    }
    
    func resumeLastPlayedSequence() {
        shuffleMode == .off ? resumeLastPlayedTrack() : resumeShuffleSequence()
    }
    
    var canResumeLastPlayedTrack: Bool {
        (lastPlayedItem != nil) && (lastPlaybackPosition > 0)
    }
    
    func resumeLastPlayedTrack() {
        
        if let lastPlayedItem = self.lastPlayedItem, lastPlaybackPosition > 0 {
            playTrackItem(lastPlayedItem, fromPosition: lastPlaybackPosition)
        }
    }
    
    var canResumeShuffleSequence: Bool {
        
        if let lastPlayedItem = lastPlayedItem,
           let playingTrack = shuffleSequence.playingTrack, playingTrack == lastPlayedItem.track {

            return true
        }
        
        return false
    }
    
    func resumeShuffleSequence() {
        
        if let lastPlayedItem = lastPlayedItem,
           let playingTrack = shuffleSequence.playingTrack, playingTrack == lastPlayedItem.track {
            
            playbackDelegate.resumeShuffleSequence(with: playingTrack,
                                                   atPosition: lastPlaybackPosition)
        }
    }
    
    func trackItem(forTrack track: Track) -> TrackHistoryItem? {
        
        let trackKey = TrackHistoryItem.key(forTrack: track)
        return recentItems[trackKey] as? TrackHistoryItem
    }
    
    func playCount(forTrack track: Track) -> Int {
        trackItem(forTrack: track)?.playCount.eventCount ?? 0
    }
    
    func lastPlayedTime(forTrack track: Track) -> Date? {
        trackItem(forTrack: track)?.playCount.lastEventTime
    }
    
    // MARK: Event handling for Tracks ---------------------------------------------------------------
    
    func itemsLoadedFromFileSystem(notif: HistoryItemsAddedNotification) {
        
        for url in notif.itemURLs {
            
            if url.isSupportedAudioFile {
                
                if let track = self.findTrack(forFile: url) {
                    markAddEventForTrack(track)
                }
                
            } else if url.isDirectory {
                markAddEventForFolder(url)
                
            } else if url.isSupportedPlaylistFile {
                markAddEventForPlaylistFile(url)
            }
        }
    }
    
    // Whenever a track is played by the player, add an entry in the "Recently played" list
    func trackPlayed(_ notification: PreTrackPlaybackNotification) {
        
        if let newTrack = notification.newTrack {
            
            markPlayEventForTrack(newTrack)
            messenger.publish(.History.updated)
        }
    }
    
    func tracksEnqueued(_ tracks: [Track]) {
        
        for track in tracks {
            markAddEventForTrack(track)
        }
        
        messenger.publish(.History.updated)
    }
    
    fileprivate func markAddEventForTrack(_ track: Track) {
        
        let trackKey = TrackHistoryItem.key(forTrack: track)
        
        if let existingHistoryItem: TrackHistoryItem = recentItems[trackKey] as? TrackHistoryItem {
            markNewAddEvent(forItem: existingHistoryItem)
            
        } else {
            
            recentItems[trackKey] = TrackHistoryItem(track: track, addCount: .createWithFirstEvent(), playCount: .init())
            maintainListSize()
        }
    }
    
    fileprivate func markPlayEventForTrack(_ track: Track) {
        
        let trackKey = TrackHistoryItem.key(forTrack: track)
        
        if let existingHistoryItem: TrackHistoryItem = recentItems[trackKey] as? TrackHistoryItem {
            markNewPlayEvent(forItem: existingHistoryItem)
            
        } else {
            
            recentItems[trackKey] = TrackHistoryItem(track: track, addCount: .init(), playCount: .createWithFirstEvent())
            maintainListSize()
        }
    }
    
    // MARK: Event handling for FileSystemItems ---------------------------------------------------------------
    
//    func fileSystemItemsEnqueued(_ fileSystemItems: [FileSystemItem]) {
//        
//        for fileSystemItem in fileSystemItems {
//            
//            if fileSystemItem.isTrack, let trackItem = fileSystemItem as? FileSystemTrackItem {
//                markAddEventForTrack(trackItem.track)
//                
//            } else if fileSystemItem.isDirectory {
//                markAddEventForFolder(fileSystemItem.url)
//                
//            } else {
//                markAddEventForPlaylistFile(fileSystemItem.url)
//            }
//        }
//        
//        messenger.publish(.History.updated)
//    }
    
    fileprivate func markAddEventForFolder(_ folder: URL) {
        
        let folderKey = FolderHistoryItem.key(forFolder: folder)
        
        if let existingHistoryItem: FolderHistoryItem = recentItems[folderKey] as? FolderHistoryItem {
            markNewAddEvent(forItem: existingHistoryItem)
            
        } else {
            
            recentItems[folderKey] = FolderHistoryItem(folder: folder, addCount: .createWithFirstEvent(), playCount: .init())
            maintainListSize()
        }
    }
    
    func playlistFilesAndTracksEnqueued(playlistFiles: [ImportedPlaylist], tracks: [Track]) {
        
        let deDupedTracks: [Track] = tracks.filter {track in
            !playlistFiles.contains(where: {$0.hasTrack(forFile: track.file)})
        }
        
        for playlistFile in playlistFiles {
            markAddEventForPlaylistFile(playlistFile.file)
        }
        
        tracksEnqueued(deDupedTracks)
        
        messenger.publish(.History.updated)
    }
    
    fileprivate func markAddEventForPlaylistFile(_ playlistFile: URL) {
        
        let playlistFileKey = PlaylistFileHistoryItem.key(forPlaylistFile: playlistFile)
        
        if let existingHistoryItem: PlaylistFileHistoryItem = recentItems[playlistFileKey] as? PlaylistFileHistoryItem {
            markNewAddEvent(forItem: existingHistoryItem)
            
        } else {
            
            recentItems[playlistFileKey] = PlaylistFileHistoryItem(playlistFile: playlistFile,
                                                                   addCount: .createWithFirstEvent(), playCount: .init())
            maintainListSize()
        }
    }
    
    // MARK: Event handling for Groups ---------------------------------------------------------------
    
//    func groupsAndTracksEnqueued(groups: [Group], tracks: [Track]) {
//        
//        let deDupedTracks: [Track] = tracks.filter {track in
//            !groups.contains(where: {$0.hasTrack(forFile: track.file)})
//        }
//        
//        for group in groups {
//            markAddEventForGroup(group)
//        }
//        
//        tracksEnqueued(deDupedTracks)
//        
//        messenger.publish(.History.updated)
//    }
//    
//    fileprivate func markAddEventForGroup(_ group: Group) {
//        
//        let groupKey = GroupHistoryItem.key(forGroupName: group.name, andType: group.type)
//        
//        if let existingHistoryItem: GroupHistoryItem = recentItems[groupKey] as? GroupHistoryItem {
//            markNewEvent(forItem: existingHistoryItem)
//            
//        } else {
//            
//            recentItems[groupKey] = GroupHistoryItem(groupName: group.name, groupType: group.type, lastEventTime: Date())
//            maintainListSize()
//        }
//    }
    
    // MARK: Event handling for Playlists ---------------------------------------------------------------
    
//    func playlistEnqueued(_ playlist: Playlist) {
//        
//        let playlistKey = PlaylistHistoryItem.key(forPlaylistNamed: playlist.name)
//        
//        if let existingHistoryItem: PlaylistHistoryItem = recentItems[playlistKey] as? PlaylistHistoryItem {
//            markNewEvent(forItem: existingHistoryItem)
//            
//        } else {
//            
//            recentItems[playlistKey] = PlaylistHistoryItem(playlistName: playlist.name, lastEventTime: Date())
//            maintainListSize()
//        }
//    }
    
    private func markNewAddEvent(forItem existingHistoryItem: HistoryItem) {
        
        existingHistoryItem.markAddEvent()
        
        // Move to bottom (i.e. most recent)
        recentItems.removeValue(forKey: existingHistoryItem.key)
        recentItems[existingHistoryItem.key] = existingHistoryItem
    }
    
    private func markNewPlayEvent(forItem existingHistoryItem: HistoryItem) {
        
        existingHistoryItem.markPlayEvent()
        
        // Move to bottom (i.e. most recent)
        recentItems.removeValue(forKey: existingHistoryItem.key)
        recentItems[existingHistoryItem.key] = existingHistoryItem
    }
    
    // MARK: Playback of items ---------------------------------------------------------------------------------------------------------
    
    func playItem(_ item: HistoryItem) {
        
        if let trackHistoryItem = item as? TrackHistoryItem {
            playTrackItem(trackHistoryItem)
            
        } else if let playlistFileHistoryItem = item as? PlaylistFileHistoryItem {
            playPlaylistFileItem(playlistFileHistoryItem)
            
        } else if let folderHistoryItem = item as? FolderHistoryItem {
            playFolderItem(folderHistoryItem)
//            
//        } else if let groupHistoryItem = item as? GroupHistoryItem {
//            playGroupItem(groupHistoryItem)
        }
    }
    
    private func playTrackItem(_ trackHistoryItem: TrackHistoryItem, fromPosition position: Double? = nil) {
        
        // TODO: Augment enqueueToPlayNow() with a PlaybackParams parm so you can pass in position.
        // Add it to the PQ
        enqueueToPlayLater(tracks: [trackHistoryItem.track])
        
        if let seekPosition = position {
            playbackDelegate.play(track: trackHistoryItem.track, PlaybackParams().withStartAndEndPosition(seekPosition))
        } else {
            playbackDelegate.play(track: trackHistoryItem.track)
        }
    }
    
    private func playPlaylistFileItem(_ playlistFileHistoryItem: PlaylistFileHistoryItem) {
        
//        // Add it to the PQ
//        if let importedPlaylist = libraryDelegate.findImportedPlaylist(atLocation: playlistFileHistoryItem.playlistFile) {
//            enqueueToPlayNow(playlistFile: importedPlaylist, clearQueue: false)
//            
//        } else {
            loadTracks(from: [playlistFileHistoryItem.playlistFile], params: .init(autoplayFirstAddedTrack: true))
            markNewPlayEvent(forItem: playlistFileHistoryItem)
//        }
    }
    
//    private func playGroupItem(_ groupHistoryItem: GroupHistoryItem) {
//        
////        guard let group = libraryDelegate.findGroup(named: groupHistoryItem.groupName, ofType: groupHistoryItem.groupType) else {return}
////        enqueueToPlayNow(group: group, clearQueue: false)
//    }
    
    private func playFolderItem(_ folderHistoryItem: FolderHistoryItem) {
        
//        if let fsFolderItem = libraryDelegate.findFileSystemFolder(atLocation: folder) {
//            enqueueToPlayNow(fileSystemItems: [fsFolderItem], clearQueue: false)
//            
//        } else {
        loadTracks(from: [folderHistoryItem.folder], params: .init(autoplayFirstAddedTrack: true))
        markNewPlayEvent(forItem: folderHistoryItem)
//        }
    }
    
    func markLastPlaybackPosition(_ position: Double) {
        self.lastPlaybackPosition = position
    }
    
    // MARK: Management of history (cleanup, resizing) ---------------------------------------------------------------------------------------------------------
    
    func deleteItem(_ item: HistoryItem) {
//        recentlyPlayedItems.remove(item)
    }
    
    func resizeRecentItemsList(to newListSize: Int) {
        
        guard recentItems.count > newListSize else {return}
        
        recentItems.removeFirst(recentItems.count - newListSize)
        messenger.publish(.History.updated)
    }
    
    private func maintainListSize() {
        
        if let maxListSize = preferences.historyPreferences.recentItemsListSize {
            resizeRecentItemsList(to: maxListSize)
        }
    }
    
    func clearAllHistory() {
        recentItems.removeAll()
    }
}
