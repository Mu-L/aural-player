//
// DiscretePlayer+State.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class DiscretePlayer: PlayerProtocol {
    
    let playerNode: AuralPlayerNode
    
    // Helper used for actual scheduling and playback
    var scheduler: PlaybackSchedulerProtocol!
    
    let avfScheduler: PlaybackSchedulerProtocol
    let ffmpegScheduler: PlaybackSchedulerProtocol
    
    // "Chain of responsibility" chains that are used to perform a sequence of actions when changing tracks
    var startPlaybackChain: StartPlaybackChain!
    var stopPlaybackChain: StopPlaybackChain!
    var trackPlaybackCompletedChain: TrackPlaybackCompletedChain!
    
    var cachedSeekPosition: TimeInterval?
    
    private(set) lazy var messenger = Messenger(for: self)
    
    init(playerNode: AuralPlayerNode) {
        
        self.playerNode = playerNode
        
        self.avfScheduler = AVFScheduler(playerNode: playerNode)
        self.ffmpegScheduler = FFmpegScheduler(playerNode: playerNode)
        
        self.startPlaybackChain = StartPlaybackChain(playerPlayFunction: self.doPlay(track:params:),
                                                     playerStopFunction: self.doStop,
                                                     playQueue: playQueue,
                                                     trackReader: trackReader,
                                                     preferences.playbackPreferences)
        
        self.stopPlaybackChain = StopPlaybackChain(playerStopFunction: self.doStop,
                                                   playQueue: playQueue,
                                                   preferences: preferences.playbackPreferences)
        
        self.trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain)
        
        // Subscribe to notifications
        messenger.subscribeAsync(to: .Player.trackPlaybackCompleted, handler: trackPlaybackCompleted(_:))
//        messenger.subscribeAsync(to: .Player.gaplessTrackPlaybackCompleted, handler: gaplessTrackPlaybackCompleted(_:))
        messenger.subscribe(to: .PlayQueue.playingTrackRemoved, handler: initiateStop(_:))
        
        messenger.subscribeAsync(to: .AudioGraph.outputDeviceChanged, handler: audioOutputDeviceChanged)
        messenger.subscribeAsync(to: .AudioGraph.preGraphChange, handler: preAudioGraphChange(_:))
        messenger.subscribeAsync(to: .AudioGraph.graphChanged, handler: audioGraphChanged(_:))
        
        // Commands
        messenger.subscribeAsync(to: .Player.autoplay, handler: autoplay(_:))
        
        messenger.subscribe(to: .Application.reopened, handler: appReopened(_:))
        
        playQueue.registerObserver(AutoplayPlayQueueObserver())
    }
    
    // MARK: Variables that indicate the current player state
    
    var state: PlaybackState = .stopped {

        didSet {
            messenger.publish(.Player.playbackStateChanged)
        }
    }
    
    var isPlaying: Bool {
        state.isPlaying
    }
    
    var seekPosition: PlaybackPosition {
        
        guard let track = playingTrack else {return .zero}
        
        let elapsedTime: TimeInterval = playerPosition
        let duration: TimeInterval = track.duration
        
        return PlaybackPosition(timeElapsed: elapsedTime, percentageElapsed: elapsedTime * 100 / duration, trackDuration: duration)
    }
    
    var playerPosition: TimeInterval {
        
        if let cachedSeekPosition {return cachedSeekPosition}
        
        guard state.isPlayingOrPaused, let session = PlaybackSession.currentSession else {return 0}
        
        // Prevent seekPosition from overruning the track duration (or loop start/end times)
        // to prevent weird incorrect UI displays of seek time
            
        // Check for a segment loop
        if let loop = session.loop {
            
            if let loopEndTime = loop.endTime {
                return min(max(loop.startTime, playerNode.seekPosition), loopEndTime)
                
            } else {
                
                // Incomplete loop (start time only)
                return min(max(loop.startTime, playerNode.seekPosition), session.track.duration)
            }
            
        } else {    // No loop
            return min(max(0, playerNode.seekPosition), session.track.duration)
        }
    }
    
    var playingTrack: Track? {
        playQueue.currentTrack
    }
    
    var hasPlayingTrack: Bool {
        playingTrack != nil
    }
    
    var playingTrackStartTime: TimeInterval? {
        PlaybackSession.currentSession?.timestamp
    }
}
