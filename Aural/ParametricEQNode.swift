/*
    A special case (customized) extension of AVAudioUnitEQ to represent a 10 band parametric equalizer
*/

import Cocoa
import AVFoundation

// Wrapper around ParametricEQNode's (switches between different EQ types)
class ParametricEQ: ParametricEQProtocol {
    
    var eq10Node: ParametricEQNode
    var eq15Node: FifteenBandEQNode
    var sync: Bool
    
    var allNodes: [ParametricEQNode] { return [eq10Node, eq15Node] }
    
    var bypass: Bool {
        
        didSet {
            
            activeNode.bypass = self.bypass
        }
    }
    
    var type: EQType
    
    var globalGain: Float {

        get {
            return activeNode.globalGain
        }
        
        set(newGlobalGain) {
            activeNode.globalGain = newGlobalGain
        }
    }
    
    var activeNode: ParametricEQNode {
        return type == .tenBand ? eq10Node : eq15Node
    }
    
    var inactiveNode: ParametricEQNode {
        return type == .tenBand ? eq15Node : eq10Node
    }
    
    init(_ type: EQType, _ sync: Bool) {
        
        eq10Node = ParametricEQNode()
        eq15Node = FifteenBandEQNode()
        
        self.type = type
        self.sync = sync
        self.bypass = false
        self.globalGain = AppDefaults.eqGlobalGain
    }
    
    func toggleSync() -> Bool {
        sync = !sync
        return sync
    }
    
    func chooseType(_ type: EQType) {
        
        if self.type == type {return}
        
        self.type = type
        
        eq10Node.bypass = type != .tenBand
        eq15Node.bypass = type != .fifteenBand
        
        if sync {
            setBands(inactiveNode.allBands())
        }
    }
    
    // Pass-through functions
    
    func increaseBass(_ increment: Float) -> [Int: Float] {
        return activeNode.increaseBass(increment)
    }
    
    func decreaseBass(_ decrement: Float) -> [Int: Float] {
        return activeNode.decreaseBass(decrement)
    }
    
    func increaseMids(_ increment: Float) -> [Int: Float] {
        return activeNode.increaseMids(increment)
    }
    
    func decreaseMids(_ decrement: Float) -> [Int: Float] {
        return activeNode.decreaseMids(decrement)
    }
    
    func increaseTreble(_ increment: Float) -> [Int: Float] {
        return activeNode.increaseTreble(increment)
    }
    
    func decreaseTreble(_ decrement: Float) -> [Int: Float] {
        return activeNode.decreaseTreble(decrement)
    }
    
    func setBand(_ index: Int, gain: Float) {
        activeNode.setBand(index, gain: gain)
    }
    
    func setBands(_ allBands: [Int: Float]) {
        
        if allBands.count != activeNode.numberOfBands {

            type == .tenBand ? map15BandsTo10Bands(allBands) : map10BandsTo15Bands(allBands)

        } else {
            activeNode.setBands(allBands)
        }
    }
    
    func allBands() -> [Int: Float] {
        return activeNode.allBands()
    }
    
    private func map10BandsTo15Bands(_ srcBands: [Int: Float]) {
        
        var mappedBands: [Float: Float] = [:]
        
        mappedBands[eq15Node.frequencies[0]] = srcBands[0]
        mappedBands[eq15Node.frequencies[1]] = srcBands[0]
        
        mappedBands[eq15Node.frequencies[2]] = srcBands[1]
        
        mappedBands[eq15Node.frequencies[3]] = srcBands[2]
        mappedBands[eq15Node.frequencies[4]] = srcBands[2]
        
        mappedBands[eq15Node.frequencies[5]] = srcBands[3]
        
        mappedBands[eq15Node.frequencies[6]] = srcBands[4]
        mappedBands[eq15Node.frequencies[7]] = srcBands[4]
        
        mappedBands[eq15Node.frequencies[8]] = srcBands[5]
        
        mappedBands[eq15Node.frequencies[9]] = srcBands[6]
        mappedBands[eq15Node.frequencies[10]] = srcBands[6]
        
        mappedBands[eq15Node.frequencies[11]] = srcBands[7]
        
        mappedBands[eq15Node.frequencies[12]] = srcBands[8]
        mappedBands[eq15Node.frequencies[13]] = srcBands[8]
        
        mappedBands[eq15Node.frequencies[14]] = srcBands[9]
        
        eq15Node.setBands(mappedBands)
    }
    
    private func map15BandsTo10Bands(_ srcBands: [Int: Float]) {
        
        var mappedBands: [Float: Float] = [:]
        
        mappedBands[eq10Node.frequencies[0]] = (srcBands[0]! + srcBands[1]!) / 2
        mappedBands[eq10Node.frequencies[1]] = srcBands[2]
        mappedBands[eq10Node.frequencies[2]] = (srcBands[3]! + srcBands[4]!) / 2
        mappedBands[eq10Node.frequencies[3]] = srcBands[5]
        mappedBands[eq10Node.frequencies[4]] = (srcBands[6]! + srcBands[7]!) / 2
        mappedBands[eq10Node.frequencies[5]] = srcBands[8]
        mappedBands[eq10Node.frequencies[6]] = (srcBands[9]! + srcBands[10]!) / 2
        mappedBands[eq10Node.frequencies[7]] = srcBands[11]
        mappedBands[eq10Node.frequencies[8]] = (srcBands[12]! + srcBands[13]!) / 2
        mappedBands[eq10Node.frequencies[9]] = srcBands[14]
        
        eq10Node.setBands(mappedBands)
    }
}

class ParametricEQNode: AVAudioUnitEQ, ParametricEQProtocol {
    
    var frequencies: [Float] {return [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384]}
    var bandwidth: Float {return 1}
    
    var bassBandIndexes: [Int] {return [0, 1, 2]}
    var midBandIndexes: [Int] {return [3, 4, 5, 6]}
    var trebleBandIndexes: [Int] {return [7, 8, 9]}
    
    var numberOfBands: Int {
        return bands.count
    }
    
    func bandAtFrequency(_ freq: Float) -> AVAudioUnitEQFilterParameters? {
        
        for band in bands {
            if band.frequency == freq {
                return band
            }
        }
        
        return nil
    }
    
    private let maxGain: Float = 20
    private let minGain: Float = -20
    
    override convenience init() {
        self.init(10)
    }
  
    fileprivate init(_ numBands: Int) {
        
        super.init(numberOfBands: numBands)
        initBands()
    }
    
    fileprivate func initBands() {
        
        for i in 0..<numberOfBands {
            
            let band = bands[i]
            
            band.frequency = frequencies[i]
            
            // Constant
            band.bypass = false
            band.filterType = AVAudioUnitEQFilterType.parametric
            band.bandwidth = bandwidth
        }
    }
    
    func increaseBass(_ increment: Float) -> [Int: Float] {
        
        let _ = increaseBandGains(bassBandIndexes, increment)
        return allBands()
    }
    
    func decreaseBass(_ decrement: Float) -> [Int: Float] {
        let _ = decreaseBandGains(bassBandIndexes, decrement)
        return allBands()
    }
    
    func increaseMids(_ increment: Float) -> [Int: Float] {
        let _ = increaseBandGains(midBandIndexes, increment)
        return allBands()
    }
    
    func decreaseMids(_ decrement: Float) -> [Int: Float] {
        let _ = decreaseBandGains(midBandIndexes, decrement)
        return allBands()
    }
    
    func increaseTreble(_ increment: Float) -> [Int: Float] {
        let _ = increaseBandGains(trebleBandIndexes, increment)
        return allBands()
    }
    
    func decreaseTreble(_ decrement: Float) -> [Int: Float] {
        let _ = decreaseBandGains(trebleBandIndexes, decrement)
        return allBands()
    }
    
    private func increaseBandGains(_ bandIndexes: [Int], _ increment: Float) -> [Int: Float] {
        
        var newGainValues = [Int: Float]()
        bandIndexes.forEach({
            
            let band = bands[$0]
            band.gain = min(band.gain + increment, maxGain)
            newGainValues[$0] = band.gain
        })
        
        return newGainValues
    }
    
    private func decreaseBandGains(_ bandIndexes: [Int], _ decrement: Float) -> [Int: Float] {
        
        var newGainValues = [Int: Float]()
        bandIndexes.forEach({
            
            let band = bands[$0]
            band.gain = max(band.gain - decrement, minGain)
            newGainValues[$0] = band.gain
        })
        
        return newGainValues
    }
    
    // Helper function to set gain for a band
    func setBand(_ index: Int, gain: Float) {
        if ((0..<numberOfBands).contains(index)) {
            bands[index].gain = gain
        }
    }
    
    // Helper function to set gain for all bands
    func setBands(_ allBands: [Int: Float]) {
        
        for (index, gain) in allBands {
            if ((0..<numberOfBands).contains(index)) {
                bands[index].gain = gain
            }
        }
    }
    
    func setBands(_ allBands: [Float: Float]) {
        
        for (freq, gain) in allBands {
            bandAtFrequency(freq)!.gain = gain
        }
    }
    
    func allBands() -> [Int: Float] {
        
        var allBands: [Int: Float] = [:]
        for index in 0..<bands.count {
            allBands[index] = bands[index].gain
        }
        
        return allBands
    }
}

class FifteenBandEQNode: ParametricEQNode {
    
    override var frequencies: [Float] {return [25, 40, 63, 100, 160, 250, 400, 630, 1024, 1638.4, 2560, 4096, 6451.2, 10240, 16384]}
    override var bandwidth: Float {return 2/3}
    
    override var bassBandIndexes: [Int] {return [0, 1, 2, 3, 4]}
    override var midBandIndexes: [Int] {return [5, 6, 7, 8, 9, 10]}
    override var trebleBandIndexes: [Int] {return [11, 12, 13, 14]}
    
    init() {
        super.init(15)
    }
}

protocol ParametricEQProtocol {
    
    func increaseBass(_ increment: Float) -> [Int: Float]
    
    func decreaseBass(_ decrement: Float) -> [Int: Float]
    
    func increaseMids(_ increment: Float) -> [Int: Float]
    
    func decreaseMids(_ decrement: Float) -> [Int: Float]
    
    func increaseTreble(_ increment: Float) -> [Int: Float]
    
    func decreaseTreble(_ decrement: Float) -> [Int: Float]

    func setBand(_ index: Int, gain: Float)
    
    func setBands(_ allBands: [Int: Float])
    
    func allBands() -> [Int: Float]
}

