//
//  DelayPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class DelayPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    override var nibName: NSNib.Name? {"DelayPresetsManager"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .delay
        effectsUnit = audioGraphDelegate.delayUnit
        presetsWrapper = PresetsWrapper<DelayPreset, DelayPresets>(audioGraphDelegate.delayUnit.presets)
    }
}
