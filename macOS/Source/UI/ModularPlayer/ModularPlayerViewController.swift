//
//  ModularPlayerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class ModularPlayerViewController: PlayerViewController {
    
    override var nibName: NSNib.Name? {"ModularPlayer"}
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var functionsButton: NSPopUpButton!
    @IBOutlet weak var functionsMenuItem: TintedIconMenuItem!
    @IBOutlet weak var functionsMenuDelegate: PlayingTrackFunctionsMenuDelegate!
    
    override var shouldEnableSeekTimer: Bool {
        
        if playbackDelegate.state != .playing {
            return false
        }
        
        // Check if we need to update seek slider position
        if playerUIState.showControls {
            return true
        }
        
        // Assume controls are hidden
        
        // Check if we need to update track time
        if playerUIState.showTrackTime && playerUIState.trackTimeDisplayType != .duration {
            return true
        }
        
        // Assume no need to update track time
        
        // Check if we need to check current chapter (i.e. seekTimerTaskQueue)
        if seekTimerTaskQueue.hasTasks {
            return true
        }
        
        return false
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        startTrackingView(options: [.activeAlways, .mouseEnteredAndExited])
    }
    
    override func updateTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        updateMultilineTrackTextView(for: track, playingChapterTitle: playingChapterTitle)
    }
    
    override func updateTrackTextViewFonts() {
        updateMultilineTrackTextViewFonts()
    }
    
    override func updateTrackTextViewColors() {
        updateMultilineTrackTextViewColors()
    }
    
    override func updateMultilineTrackTextViewColors() {
        
        super.updateMultilineTrackTextViewColors()
        
        infoBox.fillColor = systemColorScheme.backgroundColor
        controlsBox.fillColor = systemColorScheme.backgroundColor
        
        functionsMenuItem.colorChanged(systemColorScheme.buttonColor)
    }
    
    override func updateTrackTextViewFontsAndColors() {
        updateMultilineTrackTextViewFontsAndColors()
    }
    
    override func updateMultilineTrackTextViewFontsAndColors() {
        
        super.updateMultilineTrackTextViewFontsAndColors()
        
        infoBox.fillColor = systemColorScheme.backgroundColor
        controlsBox.fillColor = systemColorScheme.backgroundColor
        
        functionsMenuItem.colorChanged(systemColorScheme.buttonColor)
    }
    
    override func updateTrackInfo(for track: Track?, playingChapterTitle: String? = nil) {
        
        super.updateTrackInfo(for: track, playingChapterTitle: playingChapterTitle)
        
        artView.showIf(playerUIState.showAlbumArt)
        functionsButton.showIf(track != nil)
    }
    
    override func showTrackInfoView() {
        
        if windowLayoutsManager.isWindowLoaded(withId: .trackInfo) {
            messenger.publish(.Player.trackInfo_refresh)
        }
        
        windowLayoutsManager.showWindow(withId: .trackInfo)
    }
    
    override func setUpColorSchemePropertyObservation() {
        
        super.setUpColorSchemePropertyObservation()
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceivers: [infoBox, controlsBox])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: multilineTrackTextView.backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor], changeReceiver: multilineTrackTextView)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: artViewTintColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: functionsMenuItem)
    }
    
    override func trackChanged(to newTrack: Track?) {
        
        super.trackChanged(to: newTrack)
        
        // If playback stopped, hide/dismiss the functions menu.
        if newTrack == nil {
            
            functionsButton.hide()
            functionsButton.menu?.cancelTracking()
        }
    }
    
    override func destroy() {
        
        super.destroy()
        functionsMenuDelegate.destroy()
    }
}
