//
//  SoundPreferencesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa

class SoundPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: NSNib.Name? {"SoundPreferences"}
    
    var preferencesView: NSView {self.view}
    
    @IBOutlet weak var btnRememberSettingsforAllTracks: CheckBox!
    
    @IBOutlet weak var lblVolumeDelta: NSTextField!
    @IBOutlet weak var volumeDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblPanDelta: NSTextField!
    @IBOutlet weak var panDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblEQDelta: NSTextField!
    @IBOutlet weak var eqDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblPitchDelta: NSTextField!
    @IBOutlet weak var pitchDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblRateDelta: NSTextField!
    @IBOutlet weak var rateDeltaStepper: NSStepper!
    
    func resetFields() {
        
        let soundPrefs = preferences.soundPreferences
        
        // Per-track effects settings memory
        btnRememberSettingsforAllTracks.onIf(soundPrefs.rememberEffectsSettingsForAllTracks)
        
        // Volume increment / decrement
        
        let volumeDelta = (soundPrefs.volumeDelta * ValueConversions.volume_audioGraphToUI).roundedInt
        volumeDeltaStepper.integerValue = volumeDelta
        lblVolumeDelta.stringValue = String(format: "%d%%", volumeDelta)
        
        // Pan increment / decrement
        
        let panDelta = (soundPrefs.panDelta * ValueConversions.pan_audioGraphToUI).roundedInt
        panDeltaStepper.integerValue = panDelta
        panDeltaAction(self)
        
        let eqDelta = soundPrefs.eqDelta
        eqDeltaStepper.floatValue = eqDelta
        eqDeltaAction(self)
        
        let pitchDelta = soundPrefs.pitchDelta
        pitchDeltaStepper.integerValue = pitchDelta
        pitchDeltaAction(self)
        
        let rateDelta = soundPrefs.rateDelta
        rateDeltaStepper.floatValue = rateDelta
        rateDeltaAction(self)
    }
    
    @IBAction func volumeDeltaAction(_ sender: Any) {
        lblVolumeDelta.stringValue = String(format: "%d%%", volumeDeltaStepper.integerValue)
    }
    
    @IBAction func panDeltaAction(_ sender: Any) {
        lblPanDelta.stringValue = String(format: "%d%%", panDeltaStepper.integerValue)
    }
    
    @IBAction func eqDeltaAction(_ sender: Any) {
        lblEQDelta.stringValue = String(format: "%.1lf dB", eqDeltaStepper.floatValue)
    }
    
    @IBAction func pitchDeltaAction(_ sender: Any) {
        lblPitchDelta.stringValue = String(format: "%d cents", pitchDeltaStepper.integerValue)
    }
    
    @IBAction func rateDeltaAction(_ sender: Any) {
        lblRateDelta.stringValue = String(format: "%.2lfx", rateDeltaStepper.floatValue)
    }
    
    func save() throws {
        
        let soundPrefs = preferences.soundPreferences
        
        soundPrefs.volumeDelta = volumeDeltaStepper.floatValue * ValueConversions.volume_UIToAudioGraph
        soundPrefs.panDelta = panDeltaStepper.floatValue * ValueConversions.pan_UIToAudioGraph
        
        soundPrefs.eqDelta = eqDeltaStepper.floatValue
        soundPrefs.pitchDelta = pitchDeltaStepper.integerValue
        soundPrefs.rateDelta = rateDeltaStepper.floatValue

        let wasAllTracks: Bool = soundPrefs.rememberEffectsSettingsForAllTracks
        soundPrefs.rememberEffectsSettingsForAllTracks = btnRememberSettingsforAllTracks.isOn
        let isNowIndividualTracks: Bool = btnRememberSettingsforAllTracks.isOff
        
        if wasAllTracks && isNowIndividualTracks {
            audioGraph.soundProfiles.removeAll()
        }
    }
}
