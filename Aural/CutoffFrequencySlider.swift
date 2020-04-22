import Cocoa

class CutoffFrequencySlider: EffectsUnitSlider {
    
    var frequency: Float {
        return 20 * powf(10, (floatValue - 20) / 6660)
    }
    
    func setFrequency(_ freq: Float) {
        self.floatValue = 6660 * log10(freq/20) + 20
    }
}

class CutoffFrequencySliderCell: EffectsTickedSliderCell {
    
    var filterType: FilterBandType = .lowPass
    
    override var barPlainGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.sliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.activeSliderBarGradient
                
            // IMPOSSIBLE
            default:    return Colors.Effects.neutralSliderBarColoredGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            return Colors.Effects.sliderBackgroundGradient
            
        } else {
            
            return Colors.Effects.bypassedSliderBarGradient
        }
    }
    
    override var barColoredGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.activeSliderBarGradient
                
            case .highPass:   return Colors.Effects.sliderBackgroundGradient
                
            // IMPOSSIBLE
            default:    return Colors.Effects.neutralSliderBarColoredGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            return Colors.Effects.bypassedSliderBarGradient
            
        } else {
            
            return Colors.Effects.suppressedSliderBarGradient
        }
    }
}
