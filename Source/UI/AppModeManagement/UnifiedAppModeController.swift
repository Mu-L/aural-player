//
//  UnifiedAppModeController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class UnifiedAppModeController: AppModeController {
    
    var mode: AppMode {.unified}
    
    private var windowController: UnifiedPlayerWindowController?
    
    var mainWindow: NSWindow? {windowController?.window}
    
    var windowMagnetism: Bool = preferences.viewPreferences.windowMagnetism {
        
        didSet {
            
            if windowMagnetism {
                
                for window in NSApp.windows.filter({$0 != mainWindow}) {
                    
                    let isVisible = window.isVisible
                    mainWindow?.addChildWindow(window, ordered: .above)
                    
                    if !isVisible {
                        window.hide()
                    }
                }
                
            } else {
                
                mainWindow?.childWindows?.forEach {
                    
                    let isVisible = $0.isVisible
                    
                    mainWindow?.removeChildWindow($0)
                    $0.showIf(isVisible)
                }
            }
        }
    }
    
    var isShowingPlayer: Bool {true}
    
    var isShowingPlayQueue: Bool {
        windowController?.isShowingPlayQueue ?? false
    }

    var isShowingLyrics: Bool {
        windowController?.isShowingLyrics ?? false
    }

    var isShowingEffects: Bool {
        windowController?.isShowingEffects ?? false
    }
    
    var isShowingChaptersList: Bool {
        windowController?.isShowingChaptersList ?? false
    }
    
    var isShowingVisualizer: Bool {
        windowController?.isShowingVisualizer ?? false
    }
    
    var isShowingWaveform: Bool {
        windowController?.isShowingWaveform ?? false
    }
    
    var isShowingTrackInfo: Bool {
        windowController?.isShowingTrackInfo ?? false
    }

    func presentMode(transitioningFromMode previousMode: AppMode?) {

        NSApp.setActivationPolicy(.regular)
        NSApp.menu = (NSApp.delegate as? AppDelegate)?.mainMenu
        
        windowController = UnifiedPlayerWindowController()
        windowController?.showWindow(self)
        
        reactivateApp(previousMode: previousMode)
        
        // Build Library if not already built or building
        // Always give it a high priority.
//        libraryDelegate.buildLibraryIfNotBuilt(immediate: true)
    }
    
    func dismissMode() {

        unifiedPlayerUIState.windowFrame = windowController?.window?.frame
        
        for window in NSApp.windows {
            
            window.windowController?.destroy()
            window.close()
        }
        
        windowController = nil
    }
}
