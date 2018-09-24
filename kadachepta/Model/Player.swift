

import Foundation
import AVKit
import MediaPlayer

class Player {
    
    var avPlayer: AVPlayer!
    
    init() {
        avPlayer = AVPlayer()
    }
    
    func playStreaming(fileURL: String) {
        if let url = URL(string: fileURL) {
            
            print(url.absoluteString)
            avPlayer = AVPlayer(url: url)
            avPlayer.play()
            
            setPlayingScreen(fileURL: fileURL)
            
            print("Playing stream: " + fileURL)
        } else {
            print("No stream URL provided")
        }
    }
    
    func playAudio() {
        if avPlayer.rate == 0 && avPlayer.error == nil {
            avPlayer.play()
        }
    }
    
    func pauseAudio() {
        if avPlayer.rate > 0 && avPlayer.error == nil {
            avPlayer.pause()
        }
    }
    
    func setPlayingScreen(fileURL: String) {
        let urlArray = fileURL.split(separator: "/")
        let songNameWithExt = urlArray[urlArray.endIndex-1]
        
        print(songNameWithExt)
        
        let songInfo = [
            MPMediaItemPropertyTitle: songNameWithExt.removingPercentEncoding,
            MPMediaItemPropertyArtist: "Kadachepta Team"
        ]
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo as [String : Any]
    }
    
}
