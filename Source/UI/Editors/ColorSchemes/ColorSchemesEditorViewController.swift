import Cocoa

/*
 View controller for the editor that allows the user to manage user-defined color schemes.
 */
class ColorSchemesEditorViewController: GenericPresetsManagerViewController {
    
    // A view that gives the user a visual preview of what each color scheme looks like.
    @IBOutlet weak var previewView: ColorSchemePreviewView!
    
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override var nibName: String? {"ColorSchemesEditor"}
    
    override var numberOfPresets: Int {colorSchemesManager.numberOfUserDefinedPresets}
    
    override func nameOfPreset(atIndex index: Int) -> String {colorSchemesManager.userDefinedPresets[index].name}
    
    override func presetExists(named name: String) -> Bool {
        colorSchemesManager.presetExists(named: name)
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Clear the preview view (no theme is selected).
        previewView.clear()
    }
    
    override func deletePresets(atIndices indices: IndexSet) {
        
        colorSchemesManager.deletePresets(atIndices: indices)
        previewView.clear()
    }
    
    // Applies the selected font scheme to the system.
    override func applyPreset(atIndex index: Int) {
        
        let selScheme = colorSchemesManager.userDefinedPresets[index]
        let updatedScheme = colorSchemesManager.applyScheme(selScheme)
        
        // TODO: This should really be in ColorSchemesManager, not here. Same for other preset managers.
        Messenger.publish(.applyColorScheme, payload: updatedScheme)
    }
    
    override func renamePreset(named name: String, to newName: String) {
        colorSchemesManager.renamePreset(named: name, to: newName)
    }

    // Updates the visual preview.
    private func updatePreview() {
        
        if presetsTableView.numberOfSelectedRows == 1 {
            previewView.scheme = colorSchemesManager.userDefinedPresets[presetsTableView.selectedRow]
            
        } else {
            previewView.clear()
        }
    }
    
    // MARK: View delegate and data source functions
    
    // When the table selection changes, the button states and preview might need to change.
    override func tableViewSelectionDidChange(_ notification: Notification) {
        
        super.tableViewSelectionDidChange(notification)
        updatePreview()
    }
   
    // Returns a view for a single column
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let scheme = colorSchemesManager.userDefinedPresets[row]
        return createTextCell(tableView, tableColumn!, row, scheme.name, true)
    }
}
