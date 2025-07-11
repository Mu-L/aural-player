//
//  MediaKeyHandler.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Handler that responds to macOS media keys (play / pause, next, previous).
///
/// Delegates to the **MediaKeyTap** framework to set up the underlying event handlers.
///
class MediaKeyHandler: MediaKeyTapDelegate {
    
    private let preferences: MediaKeysControlsPreferences
    
    private var mediaKeyTap: MediaKeyTap?
    private var monitoringEnabled: Bool = false
    
    private var lastEvent: KeyEvent?
    
    private var keyRepeatInterval_msecs: Int {
        
        switch preferences.skipKeyRepeatSpeed {
            
        case .slow:
            
            return 1000
            
        case .medium:
            
            return 500
            
        case .fast:
            
            return 250
        }
    }
    
    // Recurring task used to repeat key press events according to the preferred repeat speed.
    private var repeatExecutor: RepeatingTaskExecutor?
    
    private lazy var messenger = Messenger(for: self)
    
    init(_ preferences: MediaKeysControlsPreferences) {
        
        self.preferences = preferences
        messenger.subscribe(to: .Application.launched, handler: startMonitoring, filter: {[weak self] in self?.preferences.enabled ?? false})
    }
    
    func startMonitoring() {
        
        if monitoringEnabled {return}
        
        if mediaKeyTap == nil {
            mediaKeyTap = MediaKeyTap(delegate: self, on: .keyDownAndUp)
        }
        
        mediaKeyTap?.start()
        monitoringEnabled = true
    }
    
    func stopMonitoring() {
        
        if monitoringEnabled {
            
            mediaKeyTap?.stop()
            monitoringEnabled = false
        }
    }
    
    func handle(mediaKey: MediaKey, event: KeyEvent) {
        
        switch mediaKey {
            
        case .playPause:
            
            // Only do this on keyDown
            if event.keyPressed {
                
                DispatchQueue.main.async {
                    playbackOrch.togglePlayPause()
                }
            }
            
        default:
            
            switch preferences.skipKeyBehavior {
                
            case .hybrid:
                
                handleHybrid(mediaKey, event)
                
            case .trackChangesOnly:
                
                handleTrackChangesOnly(mediaKey, event)
                
            case .seekingOnly:
                
                handleSeekingOnly(mediaKey, event)
            }
        }
    }
    
    private func handleHybrid(_ mediaKey: MediaKey, _ event: KeyEvent) {
        
        let isFwd: Bool = mediaKey.equalsOneOf(.fastForward, .next)
        
        // Only do this on keyDown, if it is being repeated
        if event.keyPressed && event.keyRepeat {
            
            // Seeking (repeated)
            initTimerIfRequired {
                
                if isFwd {
                    playbackOrch.seekForward()
                } else {
                    playbackOrch.seekBackward()
                }
            }
            
        } else if !event.keyPressed, let lastEvent = lastEvent, lastEvent.keyPressed {
            
            if lastEvent.keyRepeat {
                
                // Key up after repeating ... invalidate the repeating task
                repeatExecutor?.stop()
                repeatExecutor = nil
                
            } else {
                
                // Only do this on keyUp, if the last key event was keyDown, and was not a repeat
                
                // Change track
                DispatchQueue.main.async {
                    
                    if isFwd {
                        playbackOrch.nextTrack()
                    } else {
                        playbackOrch.previousTrack()
                    }
                }
            }
        }
        
        lastEvent = event
    }
    
    private func handleTrackChangesOnly(_ mediaKey: MediaKey, _ event: KeyEvent) {
        
        let isFwd: Bool = mediaKey.equalsOneOf(.fastForward, .next)
        
        func previousOrNextTrack() {
            
            if isFwd {
                playbackOrch.nextTrack()
            } else {
                playbackOrch.previousTrack()
            }
        }
        
        if event.keyPressed && !event.keyRepeat {
            
            DispatchQueue.main.async {
                previousOrNextTrack()
            }
            
            // Only do this on keyDown, if it is being repeated
        } else if event.keyPressed && event.keyRepeat {
            
            initTimerIfRequired {
                previousOrNextTrack()
            }
            
        } else if !event.keyPressed, let lastEvent = lastEvent, lastEvent.keyPressed && lastEvent.keyRepeat {
            
            // Key up after repeating ... invalidate the repeating task
            repeatExecutor?.stop()
            repeatExecutor = nil
        }
        
        lastEvent = event
    }
    
    private func handleSeekingOnly(_ mediaKey: MediaKey, _ event: KeyEvent) {
        
        let isFwd: Bool = mediaKey.equalsOneOf(.fastForward, .next)
        
        func seekBackwardOrForward() {
            
            if isFwd {
                playbackOrch.seekForward()
            } else {
                playbackOrch.seekBackward()
            }
        }
        
        if event.keyPressed && !event.keyRepeat {
            
            DispatchQueue.main.async {
                seekBackwardOrForward()
            }
            
        // Only do this on keyDown, if it is being repeated
        } else if event.keyPressed && event.keyRepeat {
            
            // Seeking (repeated)
            initTimerIfRequired {
                seekBackwardOrForward()
            }
            
        } else if !event.keyPressed, let lastEvent = lastEvent, lastEvent.keyPressed && lastEvent.keyRepeat {
            
            // Key up after repeating ... invalidate the repeating task
            repeatExecutor?.stop()
            repeatExecutor = nil
        }
        
        lastEvent = event
    }
    
    /// Initializes a repeating task timer with the given task.
    private func initTimerIfRequired(_ task: @escaping () -> Void) {
        
        if repeatExecutor == nil {
            
            repeatExecutor = RepeatingTaskExecutor(intervalMillis: keyRepeatInterval_msecs, task: task, queue: .main)
            repeatExecutor?.startOrResume()
        }
    }
}
