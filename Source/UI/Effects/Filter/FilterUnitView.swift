//
//  FilterUnitView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var chart: FilterChart!
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var btnScrollLeft: TintedImageButton!
    @IBOutlet weak var btnScrollRight: TintedImageButton!
    
    @IBOutlet weak var tabsBox: NSBox!
    private var bandViews: [FilterBandView] = []
    private var tabButtons: [NSButton] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var filterUnit: FilterUnitDelegateProtocol = objectGraph.audioGraphDelegate.filterUnit
    
    private var numTabs: Int {tabView.numberOfTabViewItems}
    var selectedTab: Int {tabView.numberOfTabViewItems == 0 ? -1 : tabView.selectedIndex}
    private var tabsShown: ClosedRange<Int> = (-1)...(-1)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction,
                    bandsDataFunction: @escaping () -> [FilterBand]) {
        
        chart.filterUnitStateFunction = stateFunction
        chart.bandsDataFunction = bandsDataFunction
    }
    
    func setBands(_ bands: [FilterBandView]) {
        
        clearBands()

        for band in bands {
            addBand(band, selectNewTab: false)
        }
        
        if numTabs > 0 {
            
            selectTab(at: 0)
            tabsShown = 0...(min(numTabs - 1, maxShownBands - 1))
        }
        
        updateCRUDButtonStates()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func addBand(_ bandView: FilterBandView, selectNewTab: Bool) {
        
        bandViews.append(bandView)
        
        let index = bandView.bandIndex
        let prevBtnMaxX = index == 0 ? 0 : tabButtons[index - 1].frame.maxX
        
        bandView.bandChangedCallback = redrawChart
        
        bandView.buttonPosition = NSMakePoint(prevBtnMaxX, 0)
        tabsBox.addSubview(bandView.tabButton)
        tabButtons.append(bandView.tabButton)
        
        let newItem = NSTabViewItem(identifier: "\(index)")
        tabView.addTabViewItem(newItem)
        newItem.view?.addSubview(bandView)
        
        redrawChart()
        updateCRUDButtonStates()
        
        // Button tag is the tab index
        guard selectNewTab else {return}
        
        selectTab(at: index)
        
        // Show new tab
        if index >= maxShownBands {
            
            for _ in 0..<(index - tabsShown.upperBound) {
                scrollRight()
            }
            
        } else {
            tabsShown = 0...index
        }
    }
    
    func removeSelectedBand() {
        
        // Remove the selected band's controller and view
        removeTab(at: selectedTab)

        // Remove the last tab button (bands count has decreased by 1)
        tabButtons.remove(at: tabButtons.lastIndex).removeFromSuperview()
        
        for index in selectedTab..<numTabs {

            // Reassign band indexes to controllers
            bandViews[index].bandIndex = index

            // Reassign tab buttons to controllers
            bandViews[index].tabButton = tabButtons[index]
        }

        selectTab(at: numTabs > 0 ? 0 : -1)

        // Show tab 0
        for _ in 0..<tabsShown.lowerBound {
            scrollLeft()
        }

        redrawChart()
        updateCRUDButtonStates()
    }
    
    func stateChanged() {
        
        redrawChart()
        bandViews.forEach {$0.stateChanged()}
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Helper functions
    
    private let maxNumBands: Int = 31
    private let maxShownBands: Int = 7
    
    private func clearBands() {
        
        tabButtons.forEach {$0.removeFromSuperview()}
        tabButtons.removeAll()

        removeAllTabs()

        updateCRUDButtonStates()
        tabsShown = (-1)...(-1)
    }
    
    private func updateCRUDButtonStates() {
        
        btnAdd.isEnabled = numTabs < maxNumBands
        btnRemove.isEnabled = numTabs > 0
        
        [btnAdd, btnRemove].forEach {$0?.redraw()}
        
        let overflow: Bool = numTabs > maxShownBands
        btnScrollLeft.showIf(overflow && tabsShown.lowerBound > 0)
        btnScrollRight.showIf(overflow && tabsShown.upperBound < numTabs - 1)
    }
    
    private func moveTabButtonsLeft() {
        tabButtons.forEach {$0.moveLeft(distance: $0.width)}
    }
    
    private func moveTabButtonsRight() {
        tabButtons.forEach {$0.moveRight(distance: $0.width)}
    }
    
    private func scrollLeft() {
        
        if tabsShown.lowerBound > 0 {
            
            moveTabButtonsRight()
            tabsShown = (tabsShown.lowerBound - 1)...(tabsShown.upperBound - 1)
            updateCRUDButtonStates()
        }
        
        if !tabsShown.contains(selectedTab) {
            selectTab(at: tabsShown.lowerBound)
        }
    }
    
    private func scrollRight() {
        
        if tabsShown.upperBound < numTabs - 1 {
            
            moveTabButtonsLeft()
            tabsShown = (tabsShown.lowerBound + 1)...(tabsShown.upperBound + 1)
            updateCRUDButtonStates()
        }
    }
    
    func selectTab(at index: Int) {
        
        if index >= 0 {

            tabView.selectTabViewItem(at: index)
            tabButtons.forEach {$0.state = $0.tag == selectedTab ? .on : .off}
        }
        
//        if !tabsShown.contains(selTab) {
//            selectTab(at: tabsShown.lowerBound)
//        }
    }
    
    func redrawChart() {
        chart.redraw()
    }
    
//    func selectTab(at index: Int) {
//        tabView.selectTabViewItem(at: index)
//    }
    
    func removeTab(at index: Int) {
        tabView.removeTabViewItem(tabView.tabViewItem(at: index))
    }
    
    func removeAllTabs() {
        tabView.tabViewItems.removeAll()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
//        redrawChart()
//
//        bandControllers.forEach {$0.applyFontScheme(fontScheme)}
//
//        // Redraw the add/remove band buttons
//        btnAdd.redraw()
//        btnRemove.redraw()
//
//        // Redraw the frequency chart
//        filterUnitView.applyFontScheme(fontScheme)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        // Need to do this to avoid multiple redundant redraw() calls
        
//        changeMainCaptionTextColor(scheme.general.mainCaptionTextColor)
//
//        super.changeFunctionButtonColor(scheme.general.functionButtonColor)
//        super.changeFunctionCaptionTextColor(scheme.effects.functionCaptionTextColor)
//        super.changeFunctionValueTextColor(scheme.effects.functionValueTextColor)
//
//        super.changeActiveUnitStateColor(scheme.effects.activeUnitStateColor)
//        super.changeBypassedUnitStateColor(scheme.effects.bypassedUnitStateColor)
//        super.changeSuppressedUnitStateColor(scheme.effects.suppressedUnitStateColor)
//
//        filterUnitView.redrawChart()
//
//        [btnAdd, btnRemove].forEach {$0?.redraw()}
//        [btnScrollLeft, btnScrollRight].forEach {$0?.reTint()}
//
//        bandControllers.forEach {$0.applyColorScheme(scheme)}
    }
    
    func changeBackgroundColor(_ color: NSColor) {
//        filterUnitView.redrawChart()
    }
    
    func changeSliderColors() {
//        bandControllers.forEach {$0.redrawSliders()}
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        
//        super.changeActiveUnitStateColor(color)
//        bandControllers.forEach {$0.redrawSliders()}
//        filterUnitView.redrawChart()
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        
//        super.changeBypassedUnitStateColor(color)
//        bandControllers.forEach {$0.redrawSliders()}
//        filterUnitView.redrawChart()
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        
//        super.changeSuppressedUnitStateColor(color)
//        bandControllers.forEach {$0.redrawSliders()}
//        filterUnitView.redrawChart()
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        
//        super.changeFunctionCaptionTextColor(color)
//        bandControllers.forEach {$0.changeFunctionCaptionTextColor(color)}
    }
    
    func changeFunctionValueTextColor(_ color: NSColor) {
        
//        super.changeFunctionValueTextColor(color)
//        bandControllers.forEach {$0.changeFunctionValueTextColor(color)}
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        
//        super.changeFunctionButtonColor(color)
//
//        [btnScrollLeft, btnScrollRight].forEach {$0?.reTint()}
//        bandControllers.forEach {$0.changeFunctionButtonColor()}
    }
    
    func changeTextButtonMenuColor(_ color: NSColor) {
        
//        [btnAdd, btnRemove].forEach {$0?.redraw()}
//        bandControllers.forEach {$0.changeTextButtonMenuColor()}
    }

    func changeButtonMenuTextColor(_ color: NSColor) {
        
//        [btnAdd, btnRemove].forEach {$0?.redraw()}
//        bandControllers.forEach {$0.changeButtonMenuTextColor()}
    }
    
    func changeSelectedTabButtonColor(_ color: NSColor) {
        
        if (0..<numTabs).contains(selectedTab) {
            tabButtons[selectedTab].redraw()
        }
    }
    
    func changeTabButtonTextColor(_ color: NSColor) {
        tabButtons.forEach {$0.redraw()}
    }
    
    func changeSelectedTabButtonTextColor(_ color: NSColor) {
        
        if (0..<numTabs).contains(selectedTab) {
            tabButtons[selectedTab].redraw()
        }
    }
}
