//
//  PlayQueueWindowController+GestureHandling.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension PlayQueueWindowController {
    
    private var gesturesPreferences: GesturesControlsPreferences {preferences.controlsPreferences.gestures}
    
    // Registers handlers for keyboard events and trackpad/mouse gestures (NSEvent).
    func setUpEventHandling() {
        
        eventMonitor.registerHandler(forEventType: .swipe, self.handleSwipe(_:))
        eventMonitor.startMonitoring()
    }

    // Handles a single swipe event.
    private func handleSwipe(_ event: NSEvent) -> NSEvent? {
        
        // If a modal dialog is open, don't do anything
        // Also, ignore any swipe events that weren't performed over the playlist window
        // (they trigger other functions if performed over the main window)
        
        if !windowLayoutsManager.isShowingModalComponent,
           let eventWindow = event.window, eventWindow == theWindow,
           let swipeDirection = event.gestureDirection {
            
            swipeDirection.isHorizontal ? handlePageUpDown(swipeDirection) : handleScrollTopBottom(swipeDirection)
        }
        
        return event
    }
    
    private func handleScrollTopBottom(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowPlayQueueScrollingTopToBottom.value {
            messenger.publish(swipeDirection == .up ? .PlayQueue.scrollToTop : .PlayQueue.scrollToBottom)
        }
    }
    
    private func handlePageUpDown(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowPlayQueueScrollingPageUpDown.value {
            messenger.publish(swipeDirection == .left ? .PlayQueue.pageUp : .PlayQueue.pageDown)
        }
    }
}
