//
//  ViewPreferencesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ViewPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: NSNib.Name? {"ViewPreferences"}
    
    @IBOutlet weak var btnWindowMagnetism: CheckBox!
    
    @IBOutlet weak var btnSnapToWindows: CheckBox!
    
    @IBOutlet weak var lblWindowGapCaption: NSTextField!
    @IBOutlet weak var lblWindowGap: NSTextField!
    @IBOutlet weak var gapStepper: NSStepper!
    
    @IBOutlet weak var btnSnapToScreen: CheckBox!

    @IBOutlet weak var btnShowLyricsTranslation: CheckBox!

    private static let disabledControlTooltip: String = "<This preference is only applicable to the \"Modular\" app mode>"
    
    var preferencesView: NSView {self.view}
    
    let viewPrefs = preferences.viewPreferences
    
    func resetFields() {
        
        btnWindowMagnetism.onIf(viewPrefs.windowMagnetism)
        
        btnSnapToWindows.onIf(viewPrefs.snapToWindows)
        gapStepper.floatValue = viewPrefs.windowGap
        lblWindowGap.stringValue = ValueFormatter.formatPixels(gapStepper.floatValue)
        [lblWindowGap, gapStepper].forEach {$0!.enableIf(btnSnapToWindows.isOn)}
        
        btnSnapToScreen.onIf(viewPrefs.snapToScreen)

        btnShowLyricsTranslation.onIf(viewPrefs.showLyricsTranslation)

        disableIrrelevantControls()
    }
    
    private func disableIrrelevantControls() {
        
        guard appModeManager.currentMode != .modular else {return}
        
        [btnSnapToWindows, gapStepper].forEach {
            
            $0?.toolTip = Self.disabledControlTooltip
            $0?.disable()
        }
        
        [lblWindowGapCaption, lblWindowGap].forEach {
            
            $0?.toolTip = Self.disabledControlTooltip
            $0?.textColor = .disabledControlTextColor
        }
    }
    
    @IBAction func snapToWindowsAction(_ sender: Any) {
        [lblWindowGap, gapStepper].forEach {$0!.enableIf(btnSnapToWindows.isOn)}
    }
    
    @IBAction func gapStepperAction(_ sender: Any) {
        lblWindowGap.stringValue = ValueFormatter.formatPixels(gapStepper.floatValue)
    }

    func save() throws {
        
        let oldMagnetismValue = viewPrefs.windowMagnetism
        viewPrefs.windowMagnetism = btnWindowMagnetism.isOn
        
        if viewPrefs.windowMagnetism != oldMagnetismValue {
            appModeManager.windowMagnetism = viewPrefs.windowMagnetism
        }
        
        viewPrefs.snapToWindows = btnSnapToWindows.isOn
        viewPrefs.windowGap = gapStepper.floatValue
        viewPrefs.snapToScreen = btnSnapToScreen.isOn
        viewPrefs.showLyricsTranslation = btnShowLyricsTranslation.isOn
    }
}
