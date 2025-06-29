//
//  NowPlayingInfoManager.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import AppKit
import MediaPlayer

///
/// Provides the macOS Now Playing Info Center with updated information about the current state of the player,
/// i.e. playback state, playback rate, track info, etc.
///
class NowPlayingInfoManager: NSObject {

    /// The underlying Now Playing Info Center.
    private let infoCenter = MPNowPlayingInfoCenter.default()
    
    /// Provides current player information (eg. which track is playing, playback state, playback position, etc).
    private let player: PlayerProtocol
    
    /// Provides current playback sequence information (eg. repeat / shuffle modes, how many tracks are in the playback queue, etc).
    private let playQueue: PlayQueueProtocol
    
    /// 50x50 is the size of the image view in macOS Control Center.
    private static let optimalArtworkSize: CGSize = CGSize(width: 50, height: 50)
    
    /// An image to display when the currently playing track does not have any associated cover art, resized to an optimal size for display in Control Center.
    private static let defaultArtwork: NSImage = .imgPlayingArt.copy(ofSize: optimalArtworkSize)
    
    /// A flag used to prevent unnecessary redundant updates.
    private var preTrackChange: Bool = false
    
    private var activated: Bool = false
    
    private lazy var messenger = Messenger(for: self)
    
    init(player: PlayerProtocol,
         playQueue: PlayQueueProtocol) {
        
        self.player = player
        self.playQueue = playQueue
        
        super.init()
    }
    
    func activate() {
        
        if activated {return}
        
        // Initialize the Now Playing Info Center with current info.
        
        infoCenter.nowPlayingInfo = [String: Any]()
        infoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        self.updateNowPlayingInfo()
        
        //
        // Subscribe to notifications about changes in the player's state, so that the Now Playing Info Center can be
        // updated in response to any of those changes.
        //
        messenger.subscribeAsync(to: .Player.preTrackChange, handler: handlePreTrackChange)
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackChanged)
        messenger.subscribeAsync(to: .Player.trackInfoUpdated, handler: trackInfoUpdated(_:))
        messenger.subscribeAsync(to: .Player.trackNotPlayed, handler: trackChanged)
        messenger.subscribeAsync(to: .Player.playbackStateChanged, handler: playbackStateChanged)
        messenger.subscribeAsync(to: .Player.seekPerformed, handler: seekPerformed)
        messenger.subscribeAsync(to: .Player.loopRestarted, handler: seekPerformed)
        messenger.subscribeAsync(to: .Effects.playbackRateChanged, handler: playbackRateChanged(_:))
        
        activated = true
    }
    
    func deactivate() {
        
        if !activated {return}
        
        infoCenter.playbackState = .stopped
        infoCenter.nowPlayingInfo?.removeAll()
        
        messenger.unsubscribeFromAll()
        
        activated = false
    }
    
    ///
    /// Updates the Now Playing Info Center with information about the currently playing track.
    ///
    private func updateNowPlayingInfo() {
        
        var nowPlayingInfo = infoCenter.nowPlayingInfo!
        let playingTrack = player.playingTrack
        
        // Metadata
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = playingTrack?.title ?? playingTrack?.defaultDisplayName
        nowPlayingInfo[MPMediaItemPropertyArtist] = playingTrack?.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = playingTrack?.album
        nowPlayingInfo[MPMediaItemPropertyGenre] = playingTrack?.genre
        
        nowPlayingInfo[MPMediaItemPropertyAlbumTrackNumber] = playingTrack?.trackNumber
        nowPlayingInfo[MPMediaItemPropertyAlbumTrackCount] = playingTrack?.totalTracks
        nowPlayingInfo[MPMediaItemPropertyDiscNumber] = playingTrack?.discNumber
        nowPlayingInfo[MPMediaItemPropertyDiscCount] = playingTrack?.totalDiscs
        
        // Cover art
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: Self.optimalArtworkSize, requestHandler: {size in playingTrack?.art?.originalOrDownscaledImage?.copy(ofSize: size) ?? Self.defaultArtwork})
        
        // Seek position and duration
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.seekPosition.timeElapsed
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playingTrack?.duration
        
        // Playback rate
        
//        let playbackRate: Double = player.isPlaying ? Double(soundOrch.timeStretchUnit.effectiveRate) : .zero
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
//        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = playbackRate
        
        // Playback sequence scope
        
        if let currentTrackIndex = playQueue.currentTrackIndex {
            
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueIndex] = UInt(currentTrackIndex)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueCount] = UInt(playQueue.size)
        }
        
        // Update the nowPlayingInfo dictionary in the Now Playing Info Center.
        
        infoCenter.playbackState = MPNowPlayingPlaybackState.fromPlaybackState(player.state)
        infoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: Notification handling --------------------------------------------------------
    
    ///
    /// Responds to a notification that the currently playing track is about to change.
    ///
    private func handlePreTrackChange() {
        preTrackChange = true
    }
    
    ///
    /// Responds to a change in the currently playing track. Updates the Now Playing Info Center with information
    /// about the new playing track.
    ///
    private func trackChanged() {
        
        updateNowPlayingInfo()
        preTrackChange = false
    }
    
    private func trackInfoUpdated(_ notif: TrackInfoUpdatedNotification) {
        updateNowPlayingInfo()
    }
    
    ///
    /// Responds to a change in the player's playback state. Updates the Now Playing Info Center with the new state.
    ///
    private func playbackStateChanged() {
        
        // If the currently playing track is about to change, don't respond to this notification
        // because another notification will be sent shortly.
        if preTrackChange {return}
        
        infoCenter.playbackState = MPNowPlayingPlaybackState.fromPlaybackState(player.state)
//        playbackRateChanged(soundOrch.timeStretchUnit.effectiveRate)
    }
    
    private func playbackRateChanged(_ newRate: Float) {
        
        var nowPlayingInfo = infoCenter.nowPlayingInfo!
        
        // Set playback rate
        let playbackRate: Double = player.isPlaying ? Double(newRate) : .zero
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = playbackRate
        
        // Set elapsed time
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.seekPosition.timeElapsed
        
        infoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    ///
    /// Responds to the player performing a seek to an arbitrary position. Updates the Now Playing Info Center with the new seek position.
    ///
    private func seekPerformed() {
        
        infoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.seekPosition.timeElapsed

        // This is a dirty hack to get the seek position to be updated properly when a seek occurs or a segment loop is restarted.
        // Without this hack, the Control Center's playback position sometimes goes out of sync with the actual playback position.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.infoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player.seekPosition.timeElapsed
        })
    }
}

extension MPNowPlayingPlaybackState {

    ///
    /// A convenience function to convert a **PlaybackState** enum to a **MPNowPlayingPlaybackState** that is
    /// required by the Now Playing Info Center.
    ///
    static func fromPlaybackState(_ state: PlaybackState) -> MPNowPlayingPlaybackState {
        
        switch state {
        
        case .stopped:  return .stopped
            
        case .playing:  return .playing
            
        case .paused:   return .paused
            
        }
    }
}
