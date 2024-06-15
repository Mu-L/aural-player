//
//  ViewPopupMenuContainer.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class ViewPopupMenuContainer: NSViewController {
    
    override var nibName: NSNib.Name? {"ViewPopupMenu"}
    
    @IBOutlet weak var popupMenu: NSMenu!
    @IBOutlet weak var menuIconItem: TintedIconMenuItem!
    @IBOutlet weak var viewMenuController: ViewMenuController!
}
