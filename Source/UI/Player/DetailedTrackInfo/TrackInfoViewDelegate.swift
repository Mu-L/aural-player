//
//  TrackInfoViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

typealias KeyValuePair = (key: String, value: String)

/*
    Data source and delegate for the Detailed Track Info popover view
 */
class TrackInfoViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    // The table view that displays the track info
    @IBOutlet weak var table: NSTableView! {
        
        didSet {
            TrackInfoViewHolder.tablesMap[self.tableId] = table
        }
    }
    
    // Used to measure table row height
    @IBOutlet var virtualKeyField: NSTextField!
    @IBOutlet var virtualValueField: NSTextField!
    
    // Container for the key-value pairs of info displayed
    var keyValuePairs: [KeyValuePair] = []
    
    // Cached playing track instance (to avoid reloading the same data)
    var displayedTrack: Track?
    
    var tableId: TrackInfoTab {return .metadata}
    
    // Constants used to calculate row height
    
    // Values used to determine the row height of table rows in the detailed track info popover view
    private static let trackInfoKeyColumnWidth: CGFloat = 135
    private static let trackInfoValueColumnWidth: CGFloat = 365
    
    private lazy var keyColumnBounds = NSMakeRect(.zero, .zero, Self.trackInfoKeyColumnWidth, .greatestFiniteMagnitude)
    private lazy var valueColumnBounds = NSMakeRect(.zero, .zero, Self.trackInfoValueColumnWidth, .greatestFiniteMagnitude)
    
    let value_unknown: String = "<Unknown>"
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if let track = self.displayedTrack {
            
            // A track is playing, add its info to the info array, as key-value pairs
            keyValuePairs = infoForTrack(track)
            return keyValuePairs.count
        }
        
        return 0
    }
    
    // Each track info view row contains one key-value pair
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        TrackInfoRowView.fromKeyAndValue(keyValuePairs[row].key, keyValuePairs[row].value, self.tableId)
    }
    
    // Adjust row height based on if the text wraps over to the next line
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        // Set the key and value within the virtual text fields (which are not displayed)
        virtualKeyField.stringValue = keyValuePairs[row].key
        virtualValueField.stringValue = keyValuePairs[row].value
        
        // And then compute row height from their cell sizes
        let keyHeight = virtualKeyField.cell!.cellSize(forBounds: keyColumnBounds).height
        let valueHeight = virtualValueField.cell!.cellSize(forBounds: valueColumnBounds).height
        
        // The desired row height is the maximum of the two heights, plus some padding
        return max(keyHeight, valueHeight) + 5
    }
    
    // Completely disable row selection.
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {false}
    
    // Should be overriden by subclasses.
    func infoForTrack(_ track: Track) -> [KeyValuePair] {[]}
}

// Place to hold a reference to the trackInfoView object (used in DetailedTrackInfoRowView class)
class TrackInfoViewHolder: Destroyable {
    
    static var tablesMap: [TrackInfoTab: NSTableView] = [:]
    
    static func destroy() {
        tablesMap.removeAll()
    }
}

enum TrackInfoTab {
    
    case metadata
    case audio
    case coverArt
    case fileSystem
}
