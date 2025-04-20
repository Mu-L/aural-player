//
//  StopPlaybackChain.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A chain of responsibility that initiates the stopping of playback of the currently playing track.
///
/// It is composed of several actions that perform any required
/// pre / post-processing or notifications.
///
class StopPlaybackChain: PlaybackChain {
    
    init(playerStopFunction: @escaping PlayerStopFunction,
         playQueue: PlayQueueProtocol,
         preferences: PlaybackPreferences) {
        
        super.init()
        
        _ = self.withAction(SavePlaybackProfileAction(preferences: preferences))
            .withAction(MarkLastPlaybackPositionAction())
            .withAction(HaltPlaybackAction(playerStopFunction: playerStopFunction))
            .withAction(EndPlaybackSequenceAction())
            .withAction(CloseFileHandlesAction())
            .withAction(LastFMScrobbleAction())
    }
}
