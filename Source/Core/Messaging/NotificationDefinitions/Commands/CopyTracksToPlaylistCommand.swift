//
//  CopyTracksToPlaylistCommand.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct CopyTracksToPlaylistCommand: NotificationPayload {
    
    let notificationName: Notification.Name = .playlist_copyTracks
    
    let tracks: [Track]
    let destinationPlaylistName: String
}
