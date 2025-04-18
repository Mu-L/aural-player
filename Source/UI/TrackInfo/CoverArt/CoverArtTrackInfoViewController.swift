//
//  CoverArtTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class CoverArtTrackInfoViewController: TrackInfoKVListViewController {
    
    override var nibName: NSNib.Name? {"CoverArtTrackInfo"}
    
    // Displays track artwork
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var lblNoArt: NSTextField!
    
    override var trackInfoSource: TrackInfoSource {
        CoverArtTrackInfoSource.instance
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    override func refresh() {
        
        guard let track = TrackInfoViewContext.displayedTrack else {return}
        artView?.image = track.art?.originalOrDownscaledImage
        lblNoArt.showIf(artView?.image == nil)
        
        super.refresh()
    }
    
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        refresh()
    }
    
    override var jsonObject: AnyObject? {
        artView.image != nil ? super.jsonObject : nil
    }
    
    override var htmlTableName: String {"Cover Art"}
    
    override func writeHTML(to writer: HTMLWriter) {
        
        guard let track = TrackInfoViewContext.displayedTrack else {return}
        
        // Embed art in HTML
        guard let image = track.art?.originalOrDownscaledImage,
              let bits = image.representations.first as? NSBitmapImageRep,
              let data = bits.representation(using: .jpeg, properties: [:]) else {return}
        
        let outFile = writer.outputFile
        let imgFile = outFile.parentDir.appendingPathComponent(track.displayName + "-coverArt.jpg", isDirectory: false)
        
        do {
            try data.write(to: imgFile)
            
        } catch {}
        
        writer.addImage(imgFile.lastPathComponent, "(Cover Art)")
        
        if artView.image != nil {
            super.writeHTML(to: writer)
        }
    }
    
    func exportArt(forTrack track: Track, type: NSBitmapImageRep.FileType, fileExtension: String) {
        
        let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-coverArt",
                                                           fileExtension: fileExtension)
        
        guard dialog.runModal() == .OK, let outFile = dialog.url,
              let image = track.art?.originalOrDownscaledImage else {return}
        
        do {
            try image.writeToFile(fileType: type, file: outFile)
            
        } catch {
            
            _ = DialogsAndAlerts.genericErrorAlert("Image file not written", "Unable to export image", error.localizedDescription).showModal()
        }
    }
    
    // MARK: Theming ---------------------------------------------------
    
    override func initTheme() {
        
        super.initTheme()
        
        lblNoArt.font = systemFontScheme.normalFont
        lblNoArt.textColor = systemColorScheme.primaryTextColor
    }
    
    override func fontSchemeChanged() {
        
        lblNoArt.font = systemFontScheme.normalFont
        super.fontSchemeChanged()
    }
    
    override func colorSchemeChanged() {
        
        lblNoArt.textColor = systemColorScheme.primaryTextColor
        super.colorSchemeChanged()
    }
    
    override func primaryTextColorChanged(_ newColor: NSColor) {
        
        lblNoArt.textColor = newColor
        super.primaryTextColorChanged(newColor)
    }
}

class CompactPlayerCoverArtTrackInfoViewController: CoverArtTrackInfoViewController {
    
    override var nibName: NSNib.Name? {"CompactPlayerCoverArtTrackInfo"}
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        var showTextView = false
        if let displayedTrack = TrackInfoViewContext.displayedTrack {
            showTextView = displayedTrack.art != nil
        }
        
        textView.enclosingScrollView?.showIf(showTextView)
    }
}
