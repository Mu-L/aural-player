//
//  FilterBandViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterBandViewController: NSViewController {
    
    override var nibName: String? {"FilterBand"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var filterTypeMenu: NSPopUpButton!
    
    @IBOutlet weak var freqRangeSlider: FilterBandSlider!
    @IBOutlet weak var cutoffSlider: CutoffFrequencySlider!
    @IBOutlet weak var cutoffSliderCell: FilterCutoffFrequencySliderCell!
    
    @IBOutlet weak var lblRangeCaption: NSTextField!
    @IBOutlet weak var presetRangesMenu: NSPopUpButton!
    @IBOutlet weak var presetRangesIconMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var lblCutoffCaption: NSTextField!
    @IBOutlet weak var presetCutoffsMenu: NSPopUpButton!
    @IBOutlet weak var presetCutoffsIconMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var lblFrequencies: NSTextField!
    
    @IBOutlet weak var tabButton: NSButton!
    
    private var functionCaptionLabels: [NSTextField] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private var filterUnit: FilterUnitDelegateProtocol = objectGraph.audioGraphDelegate.filterUnit
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    var band: FilterBand = .bandStopBand(minFreq: SoundConstants.subBass_min, maxFreq: SoundConstants.subBass_max)
    var bandIndex: Int!
    
    var bandChangedCallback: (() -> Void) = {
        // Do nothing
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func viewDidLoad() {
        
        oneTimeSetup()
        resetFields()
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    private func oneTimeSetup() {
        
        freqRangeSlider.onControlChanged = {[weak self] slider in self?.freqRangeChanged()}
        freqRangeSlider.stateFunction = filterUnit.stateFunction
        cutoffSlider.stateFunction = filterUnit.stateFunction
        
        functionCaptionLabels = findFunctionCaptionLabels(under: self.view)
        
        presetRangesIconMenuItem.tintFunction = {Colors.functionButtonColor}
        presetCutoffsIconMenuItem.tintFunction = {Colors.functionButtonColor}
    }
    
    private func resetFields() {
        
        let filterType = band.type
        
        filterTypeMenu.selectItem(withTitle: filterType.description)
        
        let filterTypeIsBandPassOrStop: Bool = filterType.equalsOneOf(.bandStop, .bandPass)
        
        [freqRangeSlider, lblRangeCaption, presetRangesMenu].forEach {$0?.showIf(filterTypeIsBandPassOrStop)}
        [cutoffSlider, lblCutoffCaption, presetCutoffsMenu].forEach {$0?.hideIf(filterTypeIsBandPassOrStop)}
        
        if filterTypeIsBandPassOrStop {
            
            freqRangeSlider.filterType = filterType
            
            if let minFreq = band.minFreq, let maxFreq = band.maxFreq {
                
                freqRangeSlider.setFrequencyRange(minFreq, maxFreq)
                lblFrequencies.stringValue = "[ \(formatFrequency(minFreq)) - \(formatFrequency(maxFreq)) ]"
                
                cutoffSlider.setFrequency(SoundConstants.audibleRangeMin)
            }
            
        } else {
            
            if filterType == .lowPass, let maxFreq = band.maxFreq {
                cutoffSlider.setFrequency(maxFreq)
                
            } else if filterType == .highPass, let minFreq = band.minFreq {
                cutoffSlider.setFrequency(minFreq)
            }
            
            cutoffSliderCell.filterType = filterType
            cutoffSlider.redraw()
            lblFrequencies.stringValue = formatFrequency(cutoffSlider.frequency)
            
            freqRangeSlider.setFrequencyRange(SoundConstants.audibleRangeMin, SoundConstants.subBass_max)
        }
        
        freqRangeSlider.updateState()
        cutoffSlider.updateState()
        
        presetCutoffsMenu.deselect()
        presetRangesMenu.deselect()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func bandTypeAction(_ sender: Any) {
        
        guard let selectedItemTitle = filterTypeMenu.titleOfSelectedItem else {return}
        
        let filterType = FilterBandType.fromDescription(selectedItemTitle)
        band.type = filterType
        
        let filterTypeIsBandPassOrStop: Bool = filterType.equalsOneOf(.bandStop, .bandPass)
        
        [freqRangeSlider, lblRangeCaption, presetRangesMenu].forEach {$0?.showIf(filterTypeIsBandPassOrStop)}
        [cutoffSlider, lblCutoffCaption, presetCutoffsMenu].forEach {$0?.hideIf(filterTypeIsBandPassOrStop)}
        
        if filterTypeIsBandPassOrStop {
            
            freqRangeSlider.filterType = filterType
            freqRangeChanged()
            
            band.minFreq = freqRangeSlider.startFrequency
            band.maxFreq = freqRangeSlider.endFrequency
            
        } else {
            
            cutoffSliderCell.filterType = filterType
            cutoffSlider.redraw()
            cutoffSliderAction(self)
            
            band.minFreq = filterType == .lowPass ? nil : cutoffSlider.frequency
            band.maxFreq = filterType == .lowPass ? cutoffSlider.frequency : nil
        }
        
        filterUnit[bandIndex] = band
        
        bandChangedCallback()
    }
    
    // Action for the frequency range slider.
    private func freqRangeChanged() {
        
        band.minFreq = freqRangeSlider.startFrequency
        band.maxFreq = freqRangeSlider.endFrequency
        
        filterUnit[bandIndex] = band
        
        lblFrequencies.stringValue = String(format: "[ %@ - %@ ]", formatFrequency(freqRangeSlider.startFrequency), formatFrequency(freqRangeSlider.endFrequency))
        
        bandChangedCallback()
    }
    
    @IBAction func cutoffSliderAction(_ sender: Any) {
        
        band.minFreq = band.type == .lowPass ? nil : cutoffSlider.frequency
        band.maxFreq = band.type == .lowPass ? cutoffSlider.frequency : nil
        
        filterUnit[bandIndex] = band
        
        lblFrequencies.stringValue = formatFrequency(cutoffSlider.frequency)
        
        bandChangedCallback()
    }
    
    @IBAction func presetRangeAction(_ sender: NSPopUpButton) {
        
        guard let rangeItem = sender.selectedItem as? FrequencyRangeMenuItem else {return}
        
        freqRangeSlider.setFrequencyRange(rangeItem.minFreq, rangeItem.maxFreq)
        freqRangeChanged()
        
        presetRangesMenu.deselect()
    }
    
    @IBAction func presetCutoffAction(_ sender: NSPopUpButton) {
        
        guard let selectedItem = sender.selectedItem else {return}
        
        cutoffSlider.setFrequency(Float(selectedItem.tag))
        cutoffSliderAction(self)
        
        presetCutoffsMenu.deselect()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Helper functions
    
    private func formatFrequency(_ freq: Float) -> String {
        
        let rounded = freq.roundedInt
        
        if rounded % 1000 == 0 {
            return String(format: "%d KHz", rounded / 1000)
        } else {
            return String(format: "%d Hz", rounded)
        }
    }
    
    func stateChanged() {
        
        freqRangeSlider.updateState()
        cutoffSlider.updateState()
    }
    
    private func findFunctionCaptionLabels(under view: NSView) -> [NSTextField] {
        
        var labels: [NSTextField] = []
        
        for subview in view.subviews {
            
            if let label = subview as? NSTextField, !(label is FunctionValueLabel) {
                
                labels.append(label)
                continue
            }
            
            // Recursive call
            let subviewLabels = findFunctionCaptionLabels(under: subview)
            labels.append(contentsOf: subviewLabels)
        }
        
        return labels
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        tabButton.redraw()
        
        functionCaptionLabels.forEach {$0.font = fontSchemesManager.systemScheme.effects.unitFunctionFont}
        
        filterTypeMenu.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
        filterTypeMenu.redraw()
        
        presetRangesMenu.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
        lblFrequencies.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeFunctionButtonColor()
        changeTextButtonMenuColor()
        changeFunctionCaptionTextColor(scheme.effects.functionCaptionTextColor)
        changeFunctionValueTextColor(scheme.effects.functionValueTextColor)
        redrawSliders()
        tabButton.redraw()
    }
    
    func changeFunctionButtonColor() {
        [presetCutoffsIconMenuItem, presetRangesIconMenuItem].forEach {$0?.reTint()}
    }

    func changeTextButtonMenuColor() {
        filterTypeMenu.redraw()
    }
    
    func changeButtonMenuTextColor() {
        filterTypeMenu.redraw()
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        functionCaptionLabels.forEach {$0.textColor = color}
    }
    
    func changeFunctionValueTextColor(_ color: NSColor) {
        lblFrequencies.textColor = color
    }
    
    func redrawSliders() {
        [cutoffSlider, freqRangeSlider].forEach {$0?.redraw()}
    }
}

@IBDesignable
class FrequencyRangeMenuItem: NSMenuItem {
    
    @IBInspectable var minFreq: Float = SoundConstants.audibleRangeMin
    @IBInspectable var maxFreq: Float = SoundConstants.audibleRangeMax
}
