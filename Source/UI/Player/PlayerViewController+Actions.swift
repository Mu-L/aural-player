//
//  PlayerViewController+Actions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
        seekToPercentage(seekSlider.doubleValue)
    }
    
    func seekToPercentage(_ percentage: Double) {
        
        player.seekTo(percentage: percentage)
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
        
        playerUIState.playbackPositionDisplayType = playerUIState.playbackPositionDisplayType.toggleCase()
        setPlaybackPositionDisplayType(to: playerUIState.playbackPositionDisplayType)
    }
    
    @IBAction func volumeAction(_ sender: NSSlider) {
        
        audioGraph.scaledVolume = volumeSlider.floatValue
        volumeChanged(volume: audioGraph.scaledVolume, muted: audioGraph.muted, updateSlider: false)
    }
    
    @IBAction func muteOrUnmuteAction(_ sender: NSButton) {
        muteOrUnmute()
    }
    
    @IBAction func toggleRepeatModeAction(_ sender: NSButton) {
        toggleRepeatMode()
    }
    
    @IBAction func toggleShuffleModeAction(_ sender: NSButton) {
        
        guard !player.isInGaplessPlaybackMode else {
            
            NSAlert.showInfo(withTitle: "Function unavailable", andText: "Shuffling is not possible while in gapless playback mode.")
            return
        }
        
        toggleShuffleMode()
    }
}

extension AudioGraphProtocol {
    
    var scaledVolume: Float {
        
        get {round(volume * ValueConversions.volume_audioGraphToUI)}
        set {volume = newValue * ValueConversions.volume_UIToAudioGraph}
    }
}
