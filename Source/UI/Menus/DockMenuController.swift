//
//  DockMenuController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Provides actions for the dock menu. These are a handful of simple essential functions that would typically be performed by a user running the app in the background.
 
    NOTE:
 
        - No actions are directly handled by this class. Command notifications are published to other app components that are responsible for these functions.
 
        - Since the dock menu runs outside the Aural Player process, it does not respond to menu delegate callbacks. For this reason, it needs to listen for model updates and be updated eagerly. It cannot be updated lazily, just in time, as the menu is about to open.
 */
class DockMenuController: NSObject, NSMenuDelegate {
    
    // Menu items whose states are toggled when they (or others) are clicked
    
    // Playback repeat modes
    @IBOutlet weak var repeatOffMenuItem: NSMenuItem!
    @IBOutlet weak var repeatOneMenuItem: NSMenuItem!
    @IBOutlet weak var repeatAllMenuItem: NSMenuItem!
    
    // Playback shuffle modes
    @IBOutlet weak var shuffleOffMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleOnMenuItem: NSMenuItem!
    
    // Favorites menu item (needs to be toggled)
    @IBOutlet weak var favoritesMenuItem: ToggleMenuItem!
    
    // Sub-menu that displays recently played tracks. Clicking on any of these items will result in the corresponding track being played.
    @IBOutlet weak var recentlyPlayedMenu: NSMenu!
    
    // Sub-menu that displays tracks marked "favorites". Clicking on any of these items will result in the corresponding track being played.
    @IBOutlet weak var favoritesMenu: NSMenu!
    
    // Sub-menu that displays bookmarks. Clicking on any of these items will result in the corresponding track being played.
    @IBOutlet weak var bookmarksMenu: NSMenu!
    
    // Delegate that performs CRUD on the history model
    private lazy var messenger = Messenger(for: self)
    
    // One-time setup. When the menu is loaded for the first time, update the menu item states per the current playback modes
    override func awakeFromNib() {
        
        favoritesMenuItem.off()
        
        messenger.subscribeAsync(to: .Favorites.itemAdded, handler: trackAddedToFavorites(_:))
        messenger.subscribeAsync(to: .Favorites.itemsRemoved, handler: tracksRemovedFromFavorites(_:))
        
        messenger.subscribeAsync(to: .Bookmarks.added, handler: trackAddedToBookmarks(_:))
        messenger.subscribeAsync(to: .Bookmarks.removed, handler: tracksRemovedFromBookmarks(_:))
        
        messenger.subscribeAsync(to: .History.updated, handler: recreateHistoryMenus)
        
        // Subscribe to notifications
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged})
        
        messenger.subscribeAsync(to: .Application.launched, handler: appLaunched(_:))
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // TODO: Recreate history and favorites menus here ???
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: Any) {
        messenger.publish(.Favorites.addOrRemove)
    }
    
    // Responds to a notification that a track has been added to the Favorites list, by updating the Favorites menu.
    func trackAddedToFavorites(_ favorite: Favorite) {
        
        // Add it to the menu
        let item = FavoritesMenuItem(title: favorite.name, action: #selector(self.playSelectedFavoriteAction(_:)))
        item.target = self
        item.favorite = favorite
        
        favoritesMenu.insertItem(item, at: 0)
        
        // Update the toggle menu item
//        if let plTrack = playbackInfo.playingTrack, plTrack.file == favorite.file {
//            favoritesMenuItem.on()
//        }
    }
    
    // Responds to a notification that a track has been removed from the Favorites list, by updating the Favorites menu.
    func tracksRemovedFromFavorites(_ removedFavorites: Set<Favorite>) {
        
        let itemsToRemove = favoritesMenu.items.compactMap {$0 as? FavoritesMenuItem}.filter {removedFavorites.contains($0.favorite)}
        itemsToRemove.forEach {favoritesMenu.removeItem($0)}
        
        // Update the toggle menu item
//        let removedFavoritesFiles = Set(removedFavorites.map {$0.file})
//        if let plTrack = playbackInfo.playingTrack, removedFavoritesFiles.contains(plTrack.file) {
//            favoritesMenuItem.off()
//        }
    }
    
    // Responds to a notification that a track has been added to the Bookmarks list, by updating the Bookmarks menu.
    func trackAddedToBookmarks(_ bookmark: Bookmark) {
        
        // Add it to the menu
        let item = BookmarksMenuItem(title: bookmark.name, action: #selector(self.playSelectedBookmarkAction(_:)))
        item.target = self
        item.bookmark = bookmark
        
        bookmarksMenu.insertItem(item, at: 0)
    }
    
    // Responds to a notification that a track has been removed from the Bookmarks list, by updating the Bookmarks menu.
    func tracksRemovedFromBookmarks(_ removedBookmarks: Set<Bookmark>) {
        
        let itemsToRemove = bookmarksMenu.items.compactMap {$0 as? BookmarksMenuItem}.filter {removedBookmarks.contains($0.bookmark)}
        itemsToRemove.forEach {bookmarksMenu.removeItem($0)}
    }
    
    // When a "Recently played" or "Favorites" menu item is clicked, the item is played
    @IBAction func playSelectedHistoryItemAction(_ sender: HistoryMenuItem) {
        
        guard let item = sender.historyItem else {return}
        history.playItem(item)
    }
    
    @IBAction func playSelectedFavoriteAction(_ sender: FavoritesMenuItem) {
        
        guard let favorite = sender.favorite else {return}
        favorites.playFavorite(favorite)
    }
    
    @IBAction func playSelectedBookmarkAction(_ sender: BookmarksMenuItem) {
        
        guard let bookmark = sender.bookmark else {return}
        
        do {
            
            try bookmarks.playBookmark(bookmark)
            
        } catch {
            
            if let fnfError = error as? FileNotFoundError {
                
                // This needs to be done async. Otherwise, other open dialogs could hang.
                DispatchQueue.main.async {
                    
                    // Position and display an alert with error info
                    _ = DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove bookmark").showModal()
                    bookmarks.deleteBookmarkWithName(sender.bookmark.name)
                }
            }
        }
    }
    
    // Pauses or resumes playback
    @IBAction func playOrPauseAction(_ sender: AnyObject) {
        messenger.publish(.Player.playOrPause)
    }
    
    @IBAction func stopAction(_ sender: AnyObject) {
        messenger.publish(.Player.stop)
    }
    
    // Replays the currently playing track from the beginning, if there is one
    @IBAction func replayTrackAction(_ sender: AnyObject) {
        messenger.publish(.Player.replayTrack)
    }
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        messenger.publish(.Player.previousTrack)
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        messenger.publish(.Player.nextTrack)
    }
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        messenger.publish(.Player.seekBackward, payload: UserInputMode.discrete)
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        messenger.publish(.Player.seekForward, payload: UserInputMode.discrete)
    }
    
    // Sets the repeat mode to "Off"
    @IBAction func repeatOffAction(_ sender: AnyObject) {
        messenger.publish(.Player.setRepeatMode, payload: RepeatMode.off)
    }
    
    // Sets the repeat mode to "Repeat One"
    @IBAction func repeatOneAction(_ sender: AnyObject) {
        messenger.publish(.Player.setRepeatMode, payload: RepeatMode.one)
    }
    
    // Sets the repeat mode to "Repeat All"
    @IBAction func repeatAllAction(_ sender: AnyObject) {
        messenger.publish(.Player.setRepeatMode, payload: RepeatMode.all)
    }
    
    // Sets the shuffle mode to "Off"
    @IBAction func shuffleOffAction(_ sender: AnyObject) {
        messenger.publish(.Player.setShuffleMode, payload: ShuffleMode.off)
    }
    
    // Sets the shuffle mode to "On"
    @IBAction func shuffleOnAction(_ sender: AnyObject) {
        messenger.publish(.Player.setShuffleMode, payload: ShuffleMode.on)
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        messenger.publish(.Player.muteOrUnmute)
    }
    
    // Decreases the volume by a certain preset decrement
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        messenger.publish(.Player.decreaseVolume, payload: UserInputMode.discrete)
    }
    
    // Increases the volume by a certain preset increment
    @IBAction func increaseVolumeAction(_ sender: Any) {
        messenger.publish(.Player.increaseVolume, payload: UserInputMode.discrete)
    }
    
    // Updates the menu item states per the current playback modes
    private func updateRepeatAndShuffleMenuItemStates() {
        
        let modes = playQueue.repeatAndShuffleModes

        shuffleOffMenuItem.onIf(modes.shuffleMode == .off)
        shuffleOnMenuItem.onIf(modes.shuffleMode == .on)

        switch modes.repeatMode {

        case .off:

            repeatOffMenuItem.on()
            [repeatOneMenuItem, repeatAllMenuItem].forEach {$0?.off()}

        case .one:

            repeatOneMenuItem.on()
            [repeatOffMenuItem, repeatAllMenuItem].forEach {$0?.off()}

        case .all:

            repeatAllMenuItem.on()
            [repeatOffMenuItem, repeatOneMenuItem].forEach {$0?.off()}
        }
    }
    
    // Re-creates the History menus from the model
    private func recreateHistoryMenus() {
        
        // Clear the menus
        recentlyPlayedMenu.removeAllItems()
        
        // Retrieve the model and re-create all sub-menu items
        history.allRecentItems.forEach {
            recentlyPlayedMenu.addItem(createHistoryMenuItem($0))
        }
    }
    
    // Factory method to create a single menu item, given a model object (HistoryItem)
    private func createHistoryMenuItem(_ item: HistoryItem) -> NSMenuItem {
        
        let menuItem = HistoryMenuItem(title: "  " + item.displayName, action: #selector(self.playSelectedHistoryItemAction(_:)))
        menuItem.target = self
        menuItem.historyItem = item
        
        return menuItem
    }
    
    // MARK: Notification handling ---------------------------------------------------------------
    
    func appLaunched(_ filesToOpen: [URL]) {
        
//        recreateHistoryMenus()
//        
//        // Favorites menu
//        favorites.allFavorites.reversed().forEach {
//            
//            let item = FavoritesMenuItem(title: $0.name, action: #selector(self.playSelectedFavoriteAction(_:)))
//            item.target = self
//            item.favorite = $0
//            favoritesMenu.addItem(item)
//        }
//        
//        bookmarks.allBookmarks.reversed().forEach {
//            
//            let item = BookmarksMenuItem(title: $0.name, action: #selector(self.playSelectedBookmarkAction(_:)))
//            item.target = self
//            item.bookmark = $0
//            bookmarksMenu.addItem(item)
//        }
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
//        if let track = notification.endTrack {
//            
//            favoritesMenuItem.enable()
//            favoritesMenuItem.onIf(favorites.favoriteTrackExists(track))
//            
//        } else {
//            
//            // No track playing
//            favoritesMenuItem.off()
//            favoritesMenuItem.disable()
//        }
    }
}
