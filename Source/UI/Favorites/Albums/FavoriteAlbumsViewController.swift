//
//  FavoriteAlbumsViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteAlbumsViewController: FavoritesTableViewController {
    
    override var nibName: NSNib.Name? {"FavoriteAlbums"}
    
    override var numberOfFavorites: Int {
        favorites.numberOfFavoriteAlbums
    }
    
    override func nameOfFavorite(forRow row: Int) -> String? {
        favorites.favoriteAlbum(atChronologicalIndex: row)?.groupName
    }
    
    override func image(forRow row: Int) -> NSImage {
        
//        if let album = nameOfFavorite(forRow: row) {
//            return (libraryDelegate.findGroup(named: album, ofType: .album) as? AlbumGroup)?.art ?? .imgAlbumGroup
//        }
        
        return .imgAlbumGroup
    }
}
