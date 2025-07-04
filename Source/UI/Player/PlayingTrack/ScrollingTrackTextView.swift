//
//  ScrollingTrackInfoView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
//  NOTE - This is a modified version of code borrowed from:
//  https://gist.github.com/NicholasBellucci/b5e9d31c47f335c36aa043f5f39eedb2
//
import Cocoa

///
/// A view that displays a text "marquee" for current track info. If the text is longer than the width of the view,
/// the text scrolls across the view in an animation in order to display the entire text in a single line.
///
class ScrollingTrackTextView: NSView {
    
    override var frame: NSRect {
        didSet {resized()}
    }
    
    // TODO: Use PlayingTrackInfo here instead of artist + title
    
    ///
    /// (Optional) Name of the artist of the track whose info is currently displayed in the text view.
    ///
    private var artist: String?
    
    ///
    /// Title of the track whose info is currently displayed in the text view.
    ///
    private var title: String = ""

    /// Text to scroll
    private var text: NSString = ""
    private var attrText: NSMutableAttributedString!

    /// Font for scrolling text
    var font: NSFont = standardFontSet.mainFont(size: 12) {
        didSet {
            fontUpdated()
        }
    }

    /// Scrolling text color
    var titleTextColor: NSColor = systemColorScheme.primaryTextColor
    
    var artistTextColor: NSColor = systemColorScheme.secondaryTextColor
    
    ///
    /// Whether the text should be scrolled (true) or just truncated (false).
    ///
    var scrollingEnabled: Bool = true {
        
        didSet {
            update(artist: self.artist, title: self.title)
        }
    }
    
    func update() {
        update(artist: self.artist, title: self.title)
    }

    /// Determines if the text should be delayed before starting scroll
    var isDelayed: Bool = true

    /// Spacing between the tail and head of the scrolling text
    let spacing: CGFloat = 50
    
    /// Amount of time the text is delayed before scrolling
    var delay: TimeInterval = 1 {
        didSet {updateTraits()}
    }

    /// Speed at which the text scrolls. This number is divided by 100.
    var speed: Double = 4 {
        didSet {updateTraits()}
    }
    
    // MARK: - Private variables
    private var timer: Timer?
    private var point = NSPoint(x: 0, y: 0)
    private var hasArtist: Bool = false

    private(set) var stringSize = NSSize(width: 0, height: 0) {
        didSet {point.x = 0}
    }

    private var timerSpeed: Double? {speed / 100}

    private var textFontAttributes: [NSAttributedString.Key: Any] {
        [.font: font, .foregroundColor: titleTextColor]
    }
    
    override func awakeFromNib() {
        self.postsFrameChangedNotifications = true
    }

    // MARK: - Open functions

    /**
     Sets up the scrolling text view

     - Parameters:
     - string: The string that will be used as the text in the view
     - layoutRequired:  Whether or not the view needs layout (required when the text font has changed).
     */
    func update(artist: String?, title: String, layoutRequired: Bool = false) {
        
        updateText(artist: artist, title: title)
        stringSize = text.size(withAttributes: textFontAttributes)
        
        if layoutRequired {
            self.needsLayout = true
        }
        
        redraw()
        updateTraits()
    }
    
    func clear() {
        
        self.artist = nil
        self.title = ""
        self.text = ""
        self.attrText = nil
        
        clearTimer()
        redraw()
        toolTip = nil
    }
    
    private func updateText(artist: String?, title: String) {
        
        self.artist = artist
        self.title = title
        self.attrText = nil
        
        let font: NSFont = textFontAttributes[.font] as! NSFont
        
        if scrollingEnabled {
            
            if let theArtist = artist {
                
                self.text = String(format: "%@ - %@", theArtist, title) as NSString
                self.attrText = (theArtist + "   ").attributed(font: font, color: artistTextColor) + title.attributed(font: font, color: titleTextColor)
                
            } else {
                self.text = title as NSString
            }
            
            toolTip = self.text as String
            
        } else {
            
            var truncatedString: String = ""
            
            if let theArtist = artist {
                
                let fullLengthString = String(format: "%@ - %@", theArtist, title)
                let parts = String.truncateCompositeStringIntoParts(font, width, fullLengthString, theArtist, title, "   ")
                truncatedString = parts[2]
                
                self.attrText = (parts[0] + "   ").attributed(font: font, color: artistTextColor) + parts[1].attributed(font: font, color: titleTextColor)
                toolTip = fullLengthString
                
            } else {
                
                truncatedString = title.truncate(font: font, maxWidth: width)
                toolTip = title
            }
            
            self.text = truncatedString as NSString
        }
    }
    
    func resized() {
        
        if scrollingEnabled {
            
            redraw()
            updateTraits()
            
        } else {
            update(artist: self.artist, title: self.title)
        }
    }
    
    func fontUpdated() {
        update(artist: self.artist, title: self.title, layoutRequired: true)
    }
    
    // MARK: Mouse handling ---------------------------------
    
    private var mouseBeingDragged: Bool = false
    
    open override func mouseDragged(with event: NSEvent) {
        mouseBeingDragged = true
    }
    
    open override func mouseUp(with event: NSEvent) {
        
        if mouseBeingDragged {
            
            mouseBeingDragged = false
            super.mouseUp(with: event)
            
            return
        }
        
        scrollingEnabled.toggle()
        super.mouseUp(with: event)
    }
}

// MARK: - Private extension
private extension ScrollingTrackTextView {
    
    func setSpeed(newInterval: TimeInterval) {
        
        clearTimer()

        if timer == nil, newInterval > 0.0, !((text as String).isEmptyAfterTrimming) {
            
            timer = Timer.scheduledTimer(timeInterval: newInterval, target: self, selector: #selector(scrollText(_:)),
                                         userInfo: nil, repeats: true)
            
            if let theTimer = timer {
                RunLoop.main.add(theTimer, forMode: .common)
            }
            
        } else {
            
            clearTimer()
            point.x = 0
        }
    }

    func updateTraits() {
        
        clearTimer()
        
        if scrollingEnabled && stringSize.width > width {
            
            guard let speed = timerSpeed else { return }
            
            if isDelayed {
                
                timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: {[weak self] timer in
                    self?.setSpeed(newInterval: speed)
                })
                
            } else {
                setSpeed(newInterval: speed)
            }
            
        } else {
            setSpeed(newInterval: 0)
        }
    }
    
    func clearTimer() {
        
        timer?.invalidate()
        timer = nil
    }

    @objc func scrollText(_ sender: Timer) {
        
        point.x -= 1
        redraw()
    }
}

// MARK: - Overrides
extension ScrollingTrackTextView {
    
    override open func draw(_ dirtyRect: NSRect) {
        
        if (text as String).isEmptyAfterTrimming && attrText == nil {
            return
        }

        if point.x + stringSize.width < 0 {
            point.x += stringSize.width + spacing
        }

        if let attrText = self.attrText {
            attrText.draw(at: point)
            
        } else {
            text.draw(at: point, withAttributes: textFontAttributes)
        }

        if point.x < 0 {

            var otherPoint = point
            otherPoint.x += stringSize.width + spacing
            
            if let attrText = self.attrText {
                attrText.draw(at: otherPoint)
                
            } else {
                text.draw(at: otherPoint, withAttributes: textFontAttributes)
            }
        }
    }

    override open func layout() {

        super.layout()
        point.y = (height - stringSize.height) / 2
    }
}
