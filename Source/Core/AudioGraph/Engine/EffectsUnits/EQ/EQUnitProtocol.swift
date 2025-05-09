//
//  EQUnitProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for an Equalizer effects unit that controls the volume of sound in
/// different frequency bands. So, it can emphasize or suppress bass (low frequencies),
/// vocals (mid frequencies), or treble (high frequencies).
///
protocol EQUnitProtocol: EffectsUnitProtocol {
    
    var globalGain: Float {get set}
    
    var bands: [Float] {get set}
    
    // Sets the gain value of a single equalizer band identified by index (the lowest frequency band has an index of 0).
    subscript(_ index: Int) -> Float {get set}
    
    // Increases the equalizer bass band gains by a small increment. Returns all EQ band gain values, mapped by index.
    @discardableResult func increaseBass(by increment: Float) -> [Float]
    
    // Decreases the equalizer bass band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    @discardableResult func decreaseBass(by decrement: Float) -> [Float]
    
    // Increases the equalizer mid-frequency band gains by a small increment. Returns all EQ band gain values, mapped by index.
    @discardableResult func increaseMids(by increment: Float) -> [Float]
    
    // Decreases the equalizer mid-frequency band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    @discardableResult func decreaseMids(by decrement: Float) -> [Float]
    
    // Increases the equalizer treble band gains by a small increment. Returns all EQ band gain values, mapped by index.
    @discardableResult func increaseTreble(by increment: Float) -> [Float]
    
    // Decreases the equalizer treble band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    @discardableResult func decreaseTreble(by decrement: Float) -> [Float]
    
    var presets: EQPresets {get}
    
    func applyPreset(_ preset: EQPreset)
    
    var settingsAsPreset: EQPreset {get}
}
