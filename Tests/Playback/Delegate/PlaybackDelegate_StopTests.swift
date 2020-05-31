import XCTest

class PlaybackDelegate_StopTests: PlaybackDelegateTests {

    func testStop_noPlayingTrack() {
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        verifyRequestContext_stopPlaybackChain(.noTrack, nil, 0)
        
        executeAfter(0.5) {
            self.assertTrackChange(nil, .noTrack, nil)
        }
    }
    
    func testStop_trackPlaying() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        verifyRequestContext_stopPlaybackChain(.playing, track, seekPosBeforeChange)
        
        executeAfter(0.5) {
            self.assertTrackChange(track, .playing, nil, 2)
        }
    }
    
    func testStop_trackPaused() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlayback(track)
        doPausePlayback(track)
        
        let seekPosBeforeChange = delegate.seekPosition.timeElapsed
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        verifyRequestContext_stopPlaybackChain(.paused, track, seekPosBeforeChange)
        
        executeAfter(0.5) {
            self.assertTrackChange(track, .paused, nil, 2)
        }
    }
    
    func testStop_trackWaiting() {
        
        let track = createTrack("Like a Virgin", 249.99887766)
        doBeginPlaybackWithDelay(track, 5)
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        verifyRequestContext_stopPlaybackChain(.waiting, track, 0)
        
        XCTAssertNil(stopPlaybackChain.executedContext!.delay)
        
        executeAfter(0.5) {
            self.assertTrackChange(track, .waiting, nil)
        }
    }
    
    func testStop_trackTranscoding() {
        
        let track = createTrack("Like a Virgin", "wma", 249.99887766)
        doBeginPlayback_trackNeedsTranscoding(track)
        
        delegate.stop()
        assertNoTrack()
        
        XCTAssertEqual(stopPlaybackChain.executionCount, 1)
        verifyRequestContext_stopPlaybackChain(.transcoding, track, 0)
        
        XCTAssertEqual(transcoder.transcodeCancelCallCount, 1)
        XCTAssertEqual(transcoder.transcodeCancel_track!, track)
        
        executeAfter(0.5) {
            self.assertTrackChange(track, .transcoding, nil)
        }
    }
}
