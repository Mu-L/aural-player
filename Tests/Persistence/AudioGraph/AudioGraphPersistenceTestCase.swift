//
//  AudioGraphPersistenceTestCase.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class AudioGraphPersistenceTestCase: PersistenceTestCase {
    
    // MARK: Master unit --------------------------------------------
    
    func randomMasterPresets(count: Int? = nil) -> [MasterPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        if numPresets == 0 {return []}
        
        let eqPresets = randomEQPresets(count: numPresets).compactMap {EQPreset(persistentState: $0)}
        let pitchShiftPresets = randomPitchShiftPresets(count: numPresets).compactMap {PitchPreset(persistentState: $0)}
        let timeStretchPresets = randomTimeStretchPresets(count: numPresets).compactMap {TimePreset(persistentState: $0)}
        let reverbPresets = randomReverbPresets(count: numPresets).compactMap {ReverbPreset(persistentState: $0)}
        let delayPresets = randomDelayPresets(count: numPresets).compactMap {DelayPreset(persistentState: $0)}
        let filterPresets = randomFilterPresets(count: numPresets).compactMap {FilterPreset(persistentState: $0)}
        
        return (0..<numPresets).map {index in
            
            let preset = MasterPreset("preset-\(index + 1)", eqPresets[index],
                                      pitchShiftPresets[index],
                                      timeStretchPresets[index],
                                      reverbPresets[index],
                                      delayPresets[index],
                                      filterPresets[index],
                                      false)
            
            return MasterPresetPersistentState(preset: preset)
        }
    }
    
    // MARK: EQ unit --------------------------------------------
    
    func randomNillableEQPresets(unitState: EffectsUnitState? = nil) -> [EQPresetPersistentState]? {
        randomNillableValue {self.randomEQPresets(unitState: unitState)}
    }
    
    func randomEQPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [EQPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            EQPresetPersistentState(preset: EQPreset("preset-\(index)", unitState ?? randomUnitState(),
                                                     randomEQ15Bands(), randomEQGlobalGain(),
                                                     false))
        }
    }
    
    func randomEQType() -> EQType {EQType.randomCase()}
    
    func randomNillableEQType() -> EQType? {
        randomNillableValue {self.randomEQType()}
    }
    
    func randomNillableEQGlobalGain() -> Float? {
        randomNillableValue {self.randomEQGlobalGain()}
    }
    
    func randomNillableEQ10Bands() -> [Float]? {
        randomNillableValue {self.randomEQ10Bands()}
    }
    
    func randomNillableEQ15Bands() -> [Float]? {
        randomNillableValue {self.randomEQ15Bands()}
    }
    
    let validEQGainRange: ClosedRange<Float> = -20...20
    
    func randomEQGlobalGain() -> Float {Float.random(in: validEQGainRange)}
    
    func randomEQ10Bands() -> [Float] {
        (0..<10).map {_ in Float.random(in: validEQGainRange)}
    }
    
    func randomEQ15Bands() -> [Float] {
        (0..<15).map {_ in Float.random(in: validEQGainRange)}
    }
    
    // MARK: Pitch Shift unit --------------------------------------------
    
    func randomNillablePitchShiftPresets(unitState: EffectsUnitState? = nil) -> [PitchShiftPresetPersistentState]? {
        randomNillableValue {self.randomPitchShiftPresets(unitState: unitState)}
    }
    
    func randomPitchShiftPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [PitchShiftPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            PitchShiftPresetPersistentState(preset: PitchPreset("preset-\(index)", unitState ?? randomUnitState(),
                                                                randomPitch(), randomOverlap(),
                                                                false))
        }
    }
    
    func randomPitch() -> Float {Float.random(in: -2400...2400)}
    
    func randomNillablePitch() -> Float? {
        randomNillableValue {self.randomPitch()}
    }
    
    func randomPositivePitch() -> Float {Float.random(in: 0...2400)}
    
    func randomNegativePitch() -> Float {Float.random(in: -2400..<0)}
    
    func randomOverlap() -> Float {Float.random(in: 3...32)}
    
    func randomNillableOverlap() -> Float? {
        randomNillableValue {self.randomOverlap()}
    }
    
    // MARK: Time Stretch unit --------------------------------------------
    
    func randomNillableTimeStretchPresets(unitState: EffectsUnitState? = nil) -> [TimeStretchPresetPersistentState]? {
        randomNillableValue {self.randomTimeStretchPresets(unitState: unitState)}
    }
    
    func randomTimeStretchPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [TimeStretchPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            TimeStretchPresetPersistentState(preset: TimePreset("preset-\(index)", unitState ?? randomUnitState(),
                                                                randomTimeStretchRate(), randomOverlap(),
                                                                Bool.random(), false))
        }
    }
    
    func randomTimeStretchRate() -> Float {Float.random(in: 0.25...4)}
    
    func randomNillableTimeStretchRate() -> Float? {
        randomNillableValue {self.randomTimeStretchRate()}
    }
    
    func randomTimeStretchShiftPitch() -> Bool {
        Bool.random()
    }
    
    func randomNillableTimeStretchShiftPitch() -> Bool? {
        randomNillableValue {self.randomTimeStretchShiftPitch()}
    }
    
    // MARK: Reverb unit --------------------------------------------
    
    func randomNillableReverbPresets(unitState: EffectsUnitState? = nil) -> [ReverbPresetPersistentState]? {
        randomNillableValue {self.randomReverbPresets(unitState: unitState)}
    }
    
    func randomReverbPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [ReverbPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            ReverbPresetPersistentState(preset: ReverbPreset("preset-\(index)", unitState ?? randomUnitState(),
                                                             randomReverbSpace(), randomReverbAmount(),
                                                             false))
        }
    }
    
    func randomReverbSpace() -> ReverbSpaces {ReverbSpaces.randomCase()}
    
    func randomNillableReverbSpace() -> ReverbSpaces? {
        randomNillableValue {self.randomReverbSpace()}
    }
    
    func randomReverbAmount() -> Float {Float.random(in: 0...100)}
    
    func randomNillableReverbAmount() -> Float? {
        randomNillableValue {self.randomReverbAmount()}
    }
    
    // MARK: Delay unit --------------------------------------------
    
    func randomNillableDelayPresets(unitState: EffectsUnitState? = nil) -> [DelayPresetPersistentState]? {
        randomNillableValue {self.randomDelayPresets(unitState: unitState)}
    }
    
    func randomDelayPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [DelayPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            DelayPresetPersistentState(preset: DelayPreset("preset-\(index)", unitState ?? randomUnitState(),
                                                           randomDelayAmount(), randomDelayTime(),
                                                           randomDelayFeedback(), randomDelayLowPassCutoff(),
                                                           false))
        }
    }
    
    func randomDelayAmount() -> Float {Float.random(in: 0...100)}
    
    func randomNillableDelayAmount() -> Float? {
        randomNillableValue {self.randomDelayAmount()}
    }
    
    func randomDelayTime() -> Double {Double.random(in: 0...2)}
    
    func randomNillableDelayTime() -> Double? {
        randomNillableValue {self.randomDelayTime()}
    }
    
    func randomDelayFeedback() -> Float {Float.random(in: -100...100)}
    
    func randomNillableDelayFeedback() -> Float? {
        randomNillableValue {self.randomDelayFeedback()}
    }
    
    func randomDelayLowPassCutoff() -> Float {Float.random(in: 10...20000)}
    
    func randomNillableDelayLowPassCutoff() -> Float? {
        randomNillableValue {self.randomDelayLowPassCutoff()}
    }
    
    // MARK: Filter unit --------------------------------------------
    
    func randomFilterBandType() -> FilterBandType {FilterBandType.randomCase()}
    
    func randomFilterFrequency() -> Float {
        Float.random(in: SoundConstants.audibleRangeMin...SoundConstants.audibleRangeMax)
    }
    
    func randomFilterBands() -> [FilterBandPersistentState] {
        
        let numBands = Int.random(in: 1...10)
        return (0..<numBands).map {_ in
            
            let type = randomFilterBandType()
            
            switch type {
            
            case .bandStop:
                
                let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                
                return FilterBandPersistentState(band: FilterBand.bandStopBand(minFreq, maxFreq))
                
            case .bandPass:
                
                let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                
                return FilterBandPersistentState(band: FilterBand.bandPassBand(minFreq, maxFreq))
                
            case .lowPass:
                
                return FilterBandPersistentState(band: FilterBand.lowPassBand(randomFilterFrequency()))
                
            case .highPass:
                
                return FilterBandPersistentState(band: FilterBand.highPassBand(randomFilterFrequency()))
            }
        }
    }
    
    func randomNillableFilterBands() -> [FilterBandPersistentState]? {
        randomNillableValue {self.randomFilterBands()}
    }
    
    func randomFilterPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [FilterPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            let numBands = Int.random(in: 1...10)
            let bands = (0..<numBands).map {(_: Int) -> FilterBand in
                
                let type = self.randomFilterBandType()
                
                switch type {
                
                case .bandStop:
                    
                    let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                    let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                    
                    return FilterBand.bandStopBand(minFreq, maxFreq)
                    
                case .bandPass:
                    
                    let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                    let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                    
                    return FilterBand.bandPassBand(minFreq, maxFreq)
                    
                case .lowPass:
                    
                    return FilterBand.lowPassBand(randomFilterFrequency())
                    
                case .highPass:
                    
                    return FilterBand.highPassBand(randomFilterFrequency())
                }
            }
            
            return FilterPresetPersistentState(preset: FilterPreset("preset-\(index)", unitState ?? randomUnitState(), bands, false))
        }
    }
    
    func randomNillableFilterPresets(unitState: EffectsUnitState? = nil) -> [FilterPresetPersistentState]? {
        randomNillableValue {self.randomFilterPresets(unitState: unitState)}
    }
    
    // MARK: Audio Unit -------------------------------------------
    
    func randomNillableAUParams() -> [AudioUnitParameterPersistentState]? {
        randomNillableValue {self.randomAUParams()}
    }
    
    func randomAUParams() -> [AudioUnitParameterPersistentState] {
        
        let numParams = Int.random(in: 1...100)
        
        return (1...numParams).map {_ in
            AudioUnitParameterPersistentState(address: randomAUParamAddress(), value: randomAUParamValue())
        }
    }
    
    func randomAUParamAddress() -> UInt64 {
        UInt64.random(in: 1...UInt64.max)
    }
    
    func randomAUParamValue() -> Float {
        Float.random(in: -100000...100000)
    }

    func randomNillableAUOSType() -> OSType? {
        randomNillableValue {self.randomAUOSType()}
    }
    
    func randomAUOSType() -> OSType {
        OSType.random(in: OSType.min...OSType.max)
    }
    
    func randomAUPresetNumber() -> Int {
        Int.random(in: 0...Int.max)
    }
    
    func randomNillableAUPresets() -> [AudioUnitPresetPersistentState]? {
        randomNillableValue {self.randomAUPresets()}
    }
    
    func randomAUPresets() -> [AudioUnitPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in

            AudioUnitPresetPersistentState(preset: AudioUnitPreset("preset-\(index)", .active, false,
                                                                 componentType: randomAUOSType(),
                                                                 componentSubType: randomAUOSType(),
                                                                 number: randomAUPresetNumber()))
        }
    }
    
    // MARK: Audio Device -----------------------------------------
    
    func randomDeviceName() -> String {
        randomString(length: Int.random(in: 10...30))
    }
    
    func randomDeviceUID() -> String {
        UUID().uuidString
    }
    
    // MARK: Sound Profile ----------------------------------------
    
    func randomVolume() -> Float {
        Float.random(in: 0...1)
    }
    
    func randomBalance() -> Float {
        Float.random(in: -1...1)
    }
}
