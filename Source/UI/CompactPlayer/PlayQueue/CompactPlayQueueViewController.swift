//
//  CompactPlayQueueViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class CompactPlayQueueViewController: PlayQueueViewController {
    
    override var nibName: NSNib.Name? {"CompactPlayQueue"}
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the play queue.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    override var playQueueView: PlayQueueView {
        .expanded
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribe(to: .PlayQueue.showPlayingTrack, handler: showPlayingTrack)
        messenger.subscribe(to: .PlayQueue.updateSummary, handler: updateSummary)
        
        messenger.subscribe(to: .PlayQueue.addTracks, handler: importFilesAndFolders)
        
        messenger.subscribe(to: .PlayQueue.playNext, handler: playNext)
        
        messenger.subscribe(to: .PlayQueue.removeTracks, handler: removeTracks)
        messenger.subscribe(to: .PlayQueue.cropSelection, handler: cropSelection)
        messenger.subscribe(to: .PlayQueue.removeAllTracks, handler: removeAllTracks)
        
        messenger.subscribe(to: .PlayQueue.playSelectedTrack, handler: playSelectedTrack)
        
        messenger.subscribe(to: .PlayQueue.selectAllTracks, handler: selectAll)
        messenger.subscribe(to: .PlayQueue.clearSelection, handler: clearSelection)
        messenger.subscribe(to: .PlayQueue.invertSelection, handler: invertSelection)
        
        messenger.subscribe(to: .PlayQueue.pageUp, handler: pageUp)
        messenger.subscribe(to: .PlayQueue.pageDown, handler: pageDown)
        messenger.subscribe(to: .PlayQueue.scrollToTop, handler: scrollToTop)
        messenger.subscribe(to: .PlayQueue.scrollToBottom, handler: scrollToBottom)
        
        messenger.subscribe(to: .PlayQueue.moveTracksUp, handler: moveTracksUp)
        messenger.subscribe(to: .PlayQueue.moveTracksDown, handler: moveTracksDown)
        messenger.subscribe(to: .PlayQueue.moveTracksToTop, handler: moveTracksToTop)
        messenger.subscribe(to: .PlayQueue.moveTracksToBottom, handler: moveTracksToBottom)
        
        messenger.subscribe(to: .PlayQueue.exportAsPlaylistFile, handler: exportTrackList)
        
        messenger.subscribe(to: .PlayQueue.shuffleModeUpdated, handler: updateSummary)
    }
    
    // MARK: Notification handling ----------------------------------------------------------------------------------
    
    // TODO: This is a hack ! Re-investigate the superClass method that calls this. eg. doSort()
    override func notifyReloadTable() {
        
        tableView.reloadData()
        updateSummary()
    }
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override var rowHeight: CGFloat {45}
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        getView(for: tableColumn, row: row)
    }
    
    override func updateSummary() {
        
        let tracksCardinalString = playQueue.size == 1 ? "track" : "tracks"
        
        if let playingTrackIndex = playQueue.currentTrackIndex {
            
            if playQueue.shuffleMode == .on {
                updateShuffleSequenceProgress()
                
            } else {
                
                let playIconAttStr = "▶".attributed(font: futuristicFontSet.mainFont(size: 12), color: systemColorScheme.secondaryTextColor)
                let tracksSummaryAttStr = "  \(playingTrackIndex + 1) / \(playQueue.size) \(tracksCardinalString)".attributed(font: systemFontScheme.smallFont,
                                                                                                                                      color: systemColorScheme.secondaryTextColor)
                
                lblTracksSummary.attributedStringValue = playIconAttStr + tracksSummaryAttStr
            }
            
        } else {
            
            lblTracksSummary.stringValue = "\(playQueue.size) \(tracksCardinalString)"
            lblTracksSummary.font = systemFontScheme.smallFont
            lblTracksSummary.textColor = systemColorScheme.secondaryTextColor
        }
        
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(playQueue.duration)
        lblDurationSummary.font = systemFontScheme.smallFont
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
    }
    
    private func updateShuffleSequenceProgress() {
        
        let imgAttachment = NSTextAttachment()
        imgAttachment.image = .imgShuffle
        let imgAttrString = NSMutableAttributedString(attachment: imgAttachment)
        
        let sequenceProgress = playQueue.shuffleSequence.progress
        let tracksSummaryAttStr = "  \(sequenceProgress.tracksPlayed) / \(playQueue.size) tracks".attributed(font: systemFontScheme.smallFont,
                                                                                                                    color: systemColorScheme.secondaryTextColor)
        lblTracksSummary.attributedStringValue = imgAttrString + tracksSummaryAttStr
    }
    
    override func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        super.trackTransitioned(notification)
        
        if preferences.playQueuePreferences.showNewTrackInPlayQueue, notification.endTrack != nil {
            showPlayingTrack()
        }
        
        updateSummary()
    }
    
    override func removeTracks() {
        
        _ = trackList.removeTracks(at: selectedRows)
        updateSummary()
        
        // Check for at least 1 row (and also get the minimum index).
        if let firstRemovedRow = selectedRows.min() {
            tracksRemoved(firstRemovedRow: firstRemovedRow)
        }
        
        clearSelection()
    }
    
    override func initTheme() {
        
        super.initTheme()
        
        lblCaption.font = systemFontScheme.captionFont
        lblCaption.textColor = systemColorScheme.captionTextColor
    }
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        lblCaption.font = systemFontScheme.captionFont
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        lblCaption.textColor = systemColorScheme.captionTextColor
    }
}
