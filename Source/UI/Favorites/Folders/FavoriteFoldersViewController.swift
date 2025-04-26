//
//  FavoriteFoldersViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteFoldersViewController: FavoritesTableViewController {
    
    override var nibName: NSNib.Name? {"FavoriteFolders"}
    
    override var numberOfFavorites: Int {
        favorites.numberOfFavoriteFolders
    }
    
    override func nameOfFavorite(forRow row: Int) -> String? {
        favorites.favoriteFolder(atChronologicalIndex: row)?.name
    }
    
    override func image(forRow row: Int) -> NSImage {
        .imgFileSystem
    }
}
