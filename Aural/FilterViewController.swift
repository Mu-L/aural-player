import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterViewController: NSViewController, MessageSubscriber, StringInputClient {
    
    // Filter controls
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var filterBassSlider: RangeSlider!
    @IBOutlet weak var filterMidSlider: RangeSlider!
    @IBOutlet weak var filterTrebleSlider: RangeSlider!
    
    @IBOutlet weak var lblFilterBassRange: NSTextField!
    @IBOutlet weak var lblFilterMidRange: NSTextField!
    @IBOutlet weak var lblFilterTrebleRange: NSTextField!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Filter"}
    
    override func viewDidLoad() {
        initControls()
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
    }
 
    private func initControls() {
        
        btnFilterBypass.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getFilterState()
        }
        btnFilterBypass.updateState()
        
        let bassBand = graph.getFilterBassBand()
        filterBassSlider.initialize(AppConstants.bass_min, AppConstants.bass_max, Double(bassBand.min), Double(bassBand.max), {
            (slider: RangeSlider) -> Void in
            self.filterBassChanged()
        })
        
        let midBand = graph.getFilterMidBand()
        filterMidSlider.initialize(AppConstants.mid_min, AppConstants.mid_max, Double(midBand.min), Double(midBand.max), {
            (slider: RangeSlider) -> Void in
            self.filterMidChanged()
        })
        
        let trebleBand = graph.getFilterTrebleBand()
        filterTrebleSlider.initialize(AppConstants.treble_min, AppConstants.treble_max, Double(trebleBand.min), Double(trebleBand.max), {
            (slider: RangeSlider) -> Void in
            self.filterTrebleChanged()
        })
        
        lblFilterBassRange.stringValue = bassBand.rangeString
        lblFilterMidRange.stringValue = midBand.rangeString
        lblFilterTrebleRange.stringValue = trebleBand.rangeString
        
        // Initialize the menu with user-defined presets
        FilterPresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleFilterState()
        btnFilterBypass.updateState()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.master))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.eq))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.pitch))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.reverb))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.delay))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.filter))
    }
    
    // Action function for the Filter unit's bass slider. Updates the Filter bass band.
    private func filterBassChanged() {
        lblFilterBassRange.stringValue = graph.setFilterBassBand(Float(filterBassSlider.start), Float(filterBassSlider.end))
    }
    
    // Action function for the Filter unit's mid-frequency slider. Updates the Filter mid-frequency band.
    private func filterMidChanged() {
        lblFilterMidRange.stringValue = graph.setFilterMidBand(Float(filterMidSlider.start), Float(filterMidSlider.end))
    }
    
    // Action function for the Filter unit's treble slider. Updates the Filter treble band.
    private func filterTrebleChanged() {
        lblFilterTrebleRange.stringValue = graph.setFilterTrebleBand(Float(filterTrebleSlider.start), Float(filterTrebleSlider.end))
    }
    
    // Applies a preset to the effects unit
    @IBAction func filterPresetsAction(_ sender: AnyObject) {
        
        // Get preset definition
        let preset = FilterPresets.presetByName(presetsMenu.titleOfSelectedItem!)
        
        filterBassSlider.start = preset.bassBand.lowerBound
        filterBassSlider.end = preset.bassBand.upperBound
        lblFilterBassRange.stringValue = graph.setFilterBassBand(Float(filterBassSlider.start), Float(filterBassSlider.end))
        
        filterMidSlider.start = preset.midBand.lowerBound
        filterMidSlider.end = preset.midBand.upperBound
        lblFilterMidRange.stringValue = graph.setFilterMidBand(Float(filterMidSlider.start), Float(filterMidSlider.end))
        
        filterTrebleSlider.start = preset.trebleBand.lowerBound
        filterTrebleSlider.end = preset.trebleBand.upperBound
        lblFilterTrebleRange.stringValue = graph.setFilterTrebleBand(Float(filterTrebleSlider.start), Float(filterTrebleSlider.end))
        
        // Don't select any of the items
        presetsMenu.selectItem(at: -1)
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New Filter preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !FilterPresets.presetWithNameExists(string)
        
        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        
        let bassBand = filterBassSlider.start...filterBassSlider.end
        let midBand = filterMidSlider.start...filterMidSlider.end
        let trebleBand = filterTrebleSlider.start...filterTrebleSlider.end
        
        FilterPresets.addUserDefinedPreset(string, bassBand, midBand, trebleBand)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let message = notification as? EffectsUnitStateChangedNotification {
            
            if message.effectsUnit == .filter {
                btnFilterBypass.updateState()
            }
        }
    }
}
