/*
    Utilities for manipulating UI elements or performing computations
 */

import Cocoa

class UIUtils {
    
    // Dismisses the currently displayed modal dialog
    static func dismissModalDialog() {
        NSApp.stopModal()
    }
    
    // Centers a modal dialog with respect to the main app window, and shows it
    static func showModalDialog(_ dialog: NSWindow) {
        
        centerDialog(dialog)
        
        NSApp.runModal(for: dialog)
        dialog.close()
    }
    
    // Centers an alert with respect to the main app window, and shows it. Returns the modal response from the alert.
    static func showAlert(_ alert: NSAlert) -> NSModalResponse {
        
        centerDialog(alert.window)
        return alert.runModal()
    }
    
    // Centers a dialog with respect to the main app window
    private static func centerDialog(_ dialog: NSWindow) {
        
        let window = WindowState.mainWindow!
        
        let windowX = window.frame.origin.x
        let windowY = window.frame.origin.y
        
        let windowWidth = window.frame.width
        let windowHeight = window.frame.height
        
        let dialogWidth = dialog.frame.width
        let dialogHeight = dialog.frame.height
        
        let posX = windowX + ((windowWidth - dialogWidth) / 2)
        let posY = windowY + ((windowHeight - dialogHeight) / 2)
        
        dialog.setFrameOrigin(NSPoint(x: posX, y: posY))
        dialog.setIsVisible(true)
    }
    
//    // Computes a window position relative to the desired location on screen, e.g Top left or Bottom center, etc.
//    static func windowPositionRelativeToScreen(_ windowWidth: CGFloat, _ windowHeight: CGFloat, _ locationOnScreen: WindowLocations) -> NSPoint {
//        
//        let screen = NSScreen.main()!
//        
//        let screenWidth = screen.frame.width
//        let screenHeight = screen.frame.height
//        
//        let minX = screen.visibleFrame.minX
//        let maxX = screen.visibleFrame.maxX
//        
//        let minY = screen.visibleFrame.minY
//        let maxY = screen.visibleFrame.maxY
//        
//        var x: CGFloat, y: CGFloat
//        
//        switch locationOnScreen {
//            
//        case .center:
//            
//            x = (screenWidth / 2) - (windowWidth / 2)
//            y = (screenHeight / 2) - (windowHeight / 2)
//            
//        case .topLeft:
//            
//            x = minX
//            y = maxY - windowHeight
//            
//        case .topCenter:
//            
//            x = (screenWidth / 2) - (windowWidth / 2)
//            y = maxY - windowHeight
//            
//        case .topRight:
//            
//            x = screenWidth - windowWidth
//            y = maxY - windowHeight
//            
//        case .leftCenter:
//            
//            x = minX
//            y = (screenHeight / 2) - (windowHeight / 2)
//            
//        case .rightCenter:
//            
//            x = maxX - windowWidth
//            y = (screenHeight / 2) - (windowHeight / 2)
//            
//        case .bottomLeft:
//            
//            x = minX
//            y = minY
//            
//        case .bottomCenter:
//            
//            x = (screenWidth / 2) - (windowWidth / 2)
//            y = minY
//            
//        case .bottomRight:
//            
//            x = maxX - windowWidth
//            y = minY
//            
//        }
//        
//        return NSPoint(x: x, y: y)
//    }
    
    // Calculates the direction of a swipe gesture
    static func determineSwipeDirection(_ event: NSEvent) -> GestureDirection? {
        
        if (event.type != .swipe) {
            return nil
        }
        
        // Offset
        let deltaX = event.deltaX, deltaY = event.deltaY
        
        // No offset data, no direction
        if (deltaX == 0 && deltaY == 0) {
            return nil
        }
        
        // Determine absolute offset values along both axes
        let absX = abs(deltaX), absY = abs(deltaY)
        
        // Check along which axis greater movement occurred
        if (absX > absY) {
            
            // This is a horizontal swipe (left/right)
            return deltaX < 0 ? .right : .left
            
        } else {
            
            // This is a vertical swipe (up/down)
            return deltaY < 0 ? .down : .up
        }
    }
    
    // Calculates the direction and magnitude of a scroll gesture
    static func determineScrollVector(_ event: NSEvent) -> (direction: GestureDirection, movement: CGFloat)? {
        
        if (event.type != .scrollWheel) {
            return nil
        }
        
        // Offset
        let deltaX = event.deltaX, deltaY = event.deltaY
        
        // No offset data, no direction
        if (deltaX == 0 && deltaY == 0) {
            return nil
        }
        
        // Determine absolute offset values along both axes
        let absX = abs(deltaX), absY = abs(deltaY)
        
        var direction: GestureDirection
        var movement: CGFloat
        
        // Check along which axis greater movement occurred
        if (absX > absY) {
            
            // This is a horizontal swipe (left/right)
            direction = deltaX < 0 ? .right : .left
            movement = absX
            
        } else {
            
            // This is a vertical swipe (up/down)
            direction = deltaY < 0 ? .down : .up
            movement = absY
        }
        
        return (direction, movement)
    }
    
    static func checkForSnap(_ child: SnappingWindow, _ parent: NSWindow) -> Bool {
        
        var snap: SnapType = checkForBottomSnap(child, parent)
        
        if (snap.isValidSnap()) {
            
            // Snap on the bottom
            child.snapLocation = snap.getLocation(child, parent)
            
        } else {
            
            snap = checkForRightSnap(child, parent)
            
            if (snap.isValidSnap()) {
            
                // Snap on the right
                child.snapLocation = snap.getLocation(child, parent)
                
            } else {
                
                snap = checkForLeftSnap(child, parent)
                
                if (snap.isValidSnap()) {
                    
                    // Snap on the left
                    child.snapLocation = snap.getLocation(child, parent)
                }
            }
        }
        
        child.snapped = snap.isValidSnap()
        return snap.isValidSnap()
    }
    
    // Top edge of FX vs Bottom edge of main (i.e. below main window)
    private static func checkForBottomSnap(_ child: SnappingWindow, _ parent: NSWindow) -> SnapType {
        
        // Left edges
        var snapMinX = parent.x - Dimensions.snapProximity
        var snapMaxX = parent.x + Dimensions.snapProximity
        let rangeX_leftEdges = snapMinX...snapMaxX
        
        let snapMinY = parent.y - child.height - Dimensions.snapProximity
        let snapMaxY = parent.y - child.height + Dimensions.snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX_leftEdges.contains(child.x) && rangeY.contains(child.y) {
            return SnapType.bottom_leftEdges
        }
        
        // Right edges
        snapMinX = parent.maxX - Dimensions.snapProximity
        snapMaxX = parent.maxX + Dimensions.snapProximity
        let rangeX_rightEdges = snapMinX...snapMaxX
        
        if rangeX_rightEdges.contains(child.maxX) && rangeY.contains(child.y) {
            return SnapType.bottom_rightEdges
        }
        
        return SnapType.none
    }
    
    // Left edge of FX vs Right edge of main (i.e. to the right of the main window)
    private static func checkForRightSnap(_ child: SnappingWindow, _ parent: NSWindow) -> SnapType {
        
        let snapMinX = parent.maxX - Dimensions.snapProximity
        let snapMaxX = parent.maxX + Dimensions.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        // Bottom edges
        var snapMinY = parent.y - Dimensions.snapProximity
        var snapMaxY = parent.y + Dimensions.snapProximity
        let rangeY_bottomEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_bottomEdges.contains(child.y) {
            return SnapType.right_bottomEdges
        }
        
        // Top edges
        snapMinY = parent.maxY - Dimensions.snapProximity
        snapMaxY = parent.maxY + Dimensions.snapProximity
        let rangeY_topEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_topEdges.contains(child.maxY) {
            return SnapType.right_topEdges
        }
        
        return SnapType.none
    }
    
    // Right edge of FX vs Left edge of main (i.e. to the left of the main window)
    private static func checkForLeftSnap(_ child: SnappingWindow, _ parent: NSWindow) -> SnapType {
        
        let snapMinX = parent.x - child.width - Dimensions.snapProximity
        let snapMaxX = parent.x - child.width + Dimensions.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        // Bottom edges
        var snapMinY = parent.y - Dimensions.snapProximity
        var snapMaxY = parent.y + Dimensions.snapProximity
        let rangeY_bottomEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_bottomEdges.contains(child.y) {
            return SnapType.left_bottomEdges
        }
        
        // Top edges
        snapMinY = parent.maxY - Dimensions.snapProximity
        snapMaxY = parent.maxY + Dimensions.snapProximity
        let rangeY_topEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_topEdges.contains(child.maxY) {
            return SnapType.left_topEdges
        }
        
        return SnapType.none
    }
}

enum SnapType {
    
    case none
    
    case bottom_leftEdges
    case bottom_rightEdges
    
    case right_bottomEdges
    case right_topEdges
    
    case left_bottomEdges
    case left_topEdges
    
    func isValidSnap() -> Bool {
        return self != .none
    }
    
    func getLocation(_ child: NSWindow, _ parent: NSWindow) -> NSPoint {
        
        switch self {
         
        case .bottom_leftEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: 0, y: -child.height))
            
        case .bottom_rightEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: parent.width - child.width, y: -child.height))
            
        case .right_bottomEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: parent.width, y: 0))
            
        case .right_topEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: parent.width, y: parent.height - child.height))
            
        case .left_bottomEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: -child.width, y: 0))
            
        case .left_topEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: -child.width, y: parent.height - child.height))
            
        default:    return NSPoint.zero     // Impossible
            
        }
    }
}
