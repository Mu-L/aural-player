//
//  ModalDialogButtonCells.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Customizes the look n feel of buttons on modal dialogs
 */

import Cocoa

// Base class for all modal dialog button cells
class ModalDialogButtonCell: NSButtonCell {
    
    var cellInsetX: CGFloat {1}
    var cellInsetY: CGFloat {1}
    
    var borderRadius: CGFloat {2}
    
    var textColor: NSColor {systemColorScheme.primaryTextColor}
//    var textColor_disabled: NSColor {systemColorScheme.primaryTextColor}
    
    var textFont: NSFont {.modalDialogButtonFont}
    
    var yOffset: CGFloat {2}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Background
        let drawRect = cellFrame.insetBy(dx: cellInsetX, dy: cellInsetY)
        NSBezierPath.strokeRoundedRect(drawRect, radius: borderRadius, withColor: systemColorScheme.buttonColor)
        
        // Title
        title.drawCentered(in: drawRect, withFont: textFont, andColor: textColor, yOffset: yOffset)
    }
}

class FilterBandEditorDialogButtonCell: ModalDialogButtonCell {
    
    override var textFont: NSFont {systemFontScheme.smallFont}
}

// Cell for all response buttons (Save/Cancel, etc)
class ModalDialogResponseButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {1}
    override var cellInsetY: CGFloat {0}
    
    override var borderRadius: CGFloat {2.5}
    
    override var textColor: NSColor {systemColorScheme.backgroundColor}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Background
        let drawRect = cellFrame.insetBy(dx: cellInsetX, dy: cellInsetY)
        NSBezierPath.fillRoundedRect(drawRect, radius: borderRadius, withColor: systemColorScheme.buttonColor)
        
        // Title
        title.drawCentered(in: drawRect, withFont: textFont, andColor: textColor, yOffset: yOffset)
    }
}

class StringInputPopoverResponseButtonCell: ModalDialogResponseButtonCell {
    override var textFont: NSFont {.stringInputPopoverFont}
}

class ColorAwareButtonCell: ModalDialogButtonCell {
    
    override var textColor: NSColor {systemColorScheme.buttonColor}
}
