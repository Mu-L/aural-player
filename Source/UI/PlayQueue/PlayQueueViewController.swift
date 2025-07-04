//
//  PlayQueueViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueViewController: TrackListTableViewController {
    
    /// Override this !!!
    var playQueueView: PlayQueueView {
        .simple
    }
    
    override var isTrackListBeingModified: Bool {playQueue.isBeingModified}
    
    override var trackList: TrackListProtocol! {playQueue}
    
    // MARK: Menu items (for menu delegate)
    
    @IBOutlet weak var playNowMenuItem: NSMenuItem!
    @IBOutlet weak var playNextMenuItem: NSMenuItem!
    
    @IBOutlet weak var removeSelectedTracksMenuItem: NSMenuItem!
    @IBOutlet weak var cropSelectionMenuItem: NSMenuItem!
    
    @IBOutlet weak var viewChaptersListMenuItem: NSMenuItem!
    @IBOutlet weak var jumpToChapterMenuItem: NSMenuItem!
    @IBOutlet weak var chaptersMenu: NSMenu!
    
    @IBOutlet weak var favoriteMenu: NSMenu!
    @IBOutlet weak var favoriteMenuItem: NSMenuItem!
    
    @IBOutlet weak var favoriteTrackMenuItem: NSMenuItem!
    //    @IBOutlet weak var favoriteArtistMenuItem: NSMenuItem!
    //    @IBOutlet weak var favoriteAlbumMenuItem: NSMenuItem!
    //    @IBOutlet weak var favoriteGenreMenuItem: NSMenuItem!
    //    @IBOutlet weak var favoriteDecadeMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteFolderMenuItem: NSMenuItem!
    
    @IBOutlet weak var moveTracksUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksToBottomMenuItem: NSMenuItem!
    
    @IBOutlet weak var contextMenu: NSMenu!
    @IBOutlet weak var infoMenuItem: NSMenuItem!
    
    //    @IBOutlet weak var playlistNamesMenu: NSMenu!
    
    // Popup view that displays a brief notification when a selected track is added/removed to/from the Favorites list
    lazy var infoPopup: InfoPopupViewController = .instance
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.menu = contextMenu
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .PlayQueue.refresh, handler: tableView.reloadData, filter: {[weak self] (views: [PlayQueueView]) in
            
            guard let selfPQView = self?.playQueueView else {return false}
            return views.contains(selfPQView)
        })
        
        // OS-specific images
        moveTracksToTopMenuItem?.image = .imgMoveToTop
        moveTracksToBottomMenuItem?.image = .imgMoveToBottom
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        guard let contextMenu else {return}
        
        contextMenu.delegate = self
        
        //            for item in contextMenu.items + favoriteMenu.items + playlistNamesMenu.items {
        for item in contextMenu.items + favoriteMenu.items {
            item.target = self
        }
    }
    
    override func tracksMovedByDragDrop(minReloadIndex: Int, maxReloadIndex: Int) {
        messenger.publish(.PlayQueue.updateSummary)
    }
    
    override func notifyReloadTable() {
        messenger.publish(.PlayQueue.refresh, payload: PlayQueueView.allCases)
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // MARK: Commands --------------------------------------------------------------------------------------------------------
    
    @IBAction func playSelectedTrackAction(_ sender: Any) {
        playSelectedTrack()
    }
    
    func playSelectedTrack() {
        
        if let firstSelectedRow = selectedRows.min() {
            playbackOrch.playTrack(atIndex: firstSelectedRow)
        }
    }
    
    func showPlayingTrack() {
        
        if let indexOfPlayingTrack = playQueue.currentTrackIndex {
            selectTrack(at: indexOfPlayingTrack)
        }
    }
    
    // MARK: Notification / command handling ----------------------------------------------------------------------------------------
    
    func activeControlColorChanged(_ newColor: NSColor) {
        
        if let playingTrackIndex = playQueue.currentTrackIndex {
            tableView.reloadRows([playingTrackIndex])
        }
    }
    
//    func tracksAdded(_ notif: PlayQueueTracksAddedNotification) {
//        tracksAdded(at: notif.trackIndices)
//    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        let refreshIndexes: [Int] = Set([notification.beginTrack, notification.endTrack]
            .compactMap {$0})
            .compactMap {playQueue.indexOfTrack($0)}
        
        // If this is not done async, the row view could get garbled.
        // (because of other potential simultaneous updates - e.g. PlayingTrackInfoUpdated)
        DispatchQueue.main.async {
            self.tableView.reloadRows(refreshIndexes)
        }
    }
    
    // MARK: Data source functions
    
    @objc override func loadFinderTracks(from files: [URL]) {
        doLoadFinderTracks(from: files)
    }
    
    @objc override func loadFinderTracks(from files: [URL], atPosition row: Int) {
        doLoadFinderTracks(from: files, atPosition: row)
    }
    
    // TODO: Handle files that exist in PQ
    var shouldAutoplayAfterAdding: Bool {
        
        let autoplayAfterAdding: Bool = preferences.playbackPreferences.autoplay.autoplayAfterAddingTracks
        lazy var option: AutoplayPlaybackPreferences.AutoplayAfterAddingOption = preferences.playbackPreferences.autoplay.autoplayAfterAddingOption
        lazy var playerIsStopped: Bool = player.state.isStopped
        return autoplayAfterAdding && (option == .always || playerIsStopped)
    }
    
    func doLoadFinderTracks(from files: [URL], atPosition row: Int? = nil) {
        
        let addMode = preferences.playQueuePreferences.dragDropAddMode
        let clearQueue: Bool = addMode == .replace || (addMode == .hybrid && NSEvent.optionFlagSet)
        
        playQueue.loadTracks(from: files, atPosition: clearQueue ? nil : row, params: .init(clearQueue: clearQueue, autoplayFirstAddedTrack: shouldAutoplayAfterAdding))
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        playQueueUIState.selectedRows = self.selectedRows
    }
    
    // MARK: Method overrides --------------------------------------------------------------------------------
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    override func importFilesAndFolders() {
        
        if fileOpenDialog.runModal() == .OK {
            playQueue.loadTracks(from: fileOpenDialog.urls, params: .init(autoplayFirstAddedTrack: shouldAutoplayAfterAdding))
        }
    }
    
    /**
     The Play Queue needs to update the summary in the case when tracks were reordered, because, if a track
     is playing, it may have moved.
     */
    
    override func doMoveTracksUp() {
        
        if checkForGaplessMode() {return}
        
        super.doMoveTracksUp()
        updateSummary()
    }
    
    override func doMoveTracksDown() {
        
        if checkForGaplessMode() {return}
        
        super.doMoveTracksDown()
        updateSummary()
    }
    
    override func doMoveTracksToTop() {
        
        if checkForGaplessMode() {return}
        
        super.doMoveTracksToTop()
        updateSummary()
    }
    
    override func doMoveTracksToBottom() {
        
        if checkForGaplessMode() {return}
        
        super.doMoveTracksToBottom()
        updateSummary()
    }
    
    private func checkForGaplessMode() -> Bool {
        
        if player.isInGaplessPlaybackMode {
            
            DispatchQueue.main.async {
                
                NSAlert.showInfo(withTitle: "Function unavailable",
                                 andText: "Reordering of Play Queue tracks is not possible while in gapless playback mode.")
            }
            
            return true
        }
        
        return false
    }
    
    func tracksRemoved(firstRemovedRow: Int) {
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the track list.
        let lastRowAfterRemove = playQueue.size - 1
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        noteNumberOfRowsChanged()
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the track list.
        if firstRemovedRow <= lastRowAfterRemove {
            reloadTableRows(firstRemovedRow...lastRowAfterRemove)
        }
    }
    
    // MARK: TableViewDelegate functions
    
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        guard tableColumn?.identifier == .cid_trackName, 
                NSEvent.noModifiedFlagsSet,
                let displayName = (trackList[row])?.displayName else {return nil}
        
        if !(displayName.starts(with: "<") || displayName.starts(with: ">")) {
            return displayName
        }
        
        return nil
    }
}
