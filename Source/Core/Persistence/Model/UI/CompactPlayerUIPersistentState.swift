//
//  CompactPlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// Persistent state for the Control Bar app mode's UI.
///
/// - SeeAlso: `CompactPlayerUIState`
///
struct CompactPlayerUIPersistentState: Codable {
    
    let windowLocation: NSPoint?
    let trackInfoScrollingEnabled: Bool?
}
