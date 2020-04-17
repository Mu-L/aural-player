import Cocoa

/*
    Factory for instantiating windows/dialogs from XIBs
 */
class WindowFactory {
    
    private static var mainWindowController: MainWindowController = MainWindowController()
    
    private static var effectsWindowController: EffectsWindowController = EffectsWindowController()
    
    private static var playlistWindowController: PlaylistWindowController = PlaylistWindowController()
    
    private static let chaptersListWindowController: ChaptersListWindowController = ChaptersListWindowController()
    
    static var editorWindowController: EditorWindowController = EditorWindowController()
    
//    private static var barModeWindowController: BarModeWindowController = BarModeWindowController()
    
    private static var preferencesWindowController: PreferencesWindowController = PreferencesWindowController()
    
    private static var playlistSearchWindowController: PlaylistSearchWindowController = PlaylistSearchWindowController()
    
    private static var playlistSortWindowController : PlaylistSortWindowController = PlaylistSortWindowController()
    
    private static var gapsEditorWindowController: GapsEditorWindowController = GapsEditorWindowController()
    
    private static var delayedPlaybackEditorWindowController: DelayedPlaybackEditorWindowController = DelayedPlaybackEditorWindowController()
    
    private static var jumptToTimeEditorWindowController: JumpToTimeEditorWindowController = JumpToTimeEditorWindowController()
    
    // MARK: Accessor functions for the different windows/dialogs
    
    static var mainWindow: NSWindow {
        return mainWindowController.window!
    }
    
    static var effectsWindow: NSWindow {
        return effectsWindowController.window!
    }
    
    // Returns the playlist window
    static var playlistWindow: NSWindow {
        return playlistWindowController.window!
    }
    
    static var chaptersListWindow: NSWindow {
        return chaptersListWindowController.window!
    }
    
    static var playlistContextMenu: NSMenu {
        return playlistWindowController.contextMenu
    }
    
    // Returns the preferences modal dialog
    static var preferencesDialog: ModalDialogDelegate {
        return preferencesWindowController
    }
    
    // Returns the playlist search dialog
    static var playlistSearchDialog: ModalDialogDelegate {
        return playlistSearchWindowController
    }
    
    // Returns the playlist sort dialog
    static var playlistSortDialog: ModalDialogDelegate {
        return playlistSortWindowController
    }
    
    static var gapsEditorDialog: ModalDialogDelegate {
        return gapsEditorWindowController
    }
    
    static var delayedPlaybackEditorDialog: ModalDialogDelegate {
        return delayedPlaybackEditorWindowController
    }
    
    static var jumpToTimeEditorDialog: ModalDialogDelegate {
        return jumptToTimeEditorWindowController
    }
}
