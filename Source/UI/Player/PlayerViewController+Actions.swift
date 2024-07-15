//
//  PlayerViewController+Actions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension PlayerViewController {
    
    @IBAction func togglePlayPauseAction(_ sender: NSButton) {
        playOrPause()
    }
    
    @IBAction func previousTrackAction(_ sender: NSButton) {
        previousTrack()
    }
    
    @IBAction func nextTrackAction(_ sender: NSButton) {
        nextTrack()
    }
    
    @IBAction func seekSliderAction(_ sender: NSSlider) {
        
        playbackDelegate.seekToPercentage(seekSlider.doubleValue)
        updateSeekPosition()
    }
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardAction(_ sender: NSButton) {
        seekBackward(inputMode: .discrete)
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: NSButton) {
        seekForward(inputMode: .discrete)
    }
    
    @IBAction func toggleLoopAction(_ sender: NSButton) {
        toggleLoop()
    }
    
    @IBAction func togglePlaybackPositionDisplayTypeAction(_ sender: NSTextField) {
        
        playerUIState.playbackPositionDisplayType = playerUIState.playbackPositionDisplayType.toggle()
        setPlaybackPositionDisplayType(to: playerUIState.playbackPositionDisplayType)
    }
    
    @IBAction func volumeAction(_ sender: NSSlider) {
        
        audioGraphDelegate.volume = volumeSlider.floatValue
        volumeChanged(volume: audioGraphDelegate.volume, muted: audioGraphDelegate.muted, updateSlider: false)
    }
    
    @IBAction func muteOrUnmuteAction(_ sender: NSButton) {
        muteOrUnmute()
    }
    
    @IBAction func toggleRepeatModeAction(_ sender: NSButton) {
        toggleRepeatMode()
    }
    
    @IBAction func toggleShuffleModeAction(_ sender: NSButton) {
        toggleShuffleMode()
    }
}
