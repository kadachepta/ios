

import UIKit
import AVKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var tblSongs: UITableView!
    @IBOutlet weak var lblPlaying: UILabel!
    
    var player: Player!
    var songs: [Song] = []
    
    var currentId: Int!
    var currentSong: Song!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSession()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: Selector(("handleInterruption")), name: AVAudioSession.interruptionNotification, object: nil)

        player = Player()
        
        tblSongs.delegate = self
        tblSongs.dataSource = self
        retrieveSongs()
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    func setSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //User pressed play/pause button
    @IBAction func btnPlayPausePressed(_ sender: Any) {
        if player.avPlayer.rate > 0 {
            player.pauseAudio()
            btnPlayPause.setImage(UIImage(named: "icons8-play-50"), for: .normal)
        } else {
            player.playAudio()
            btnPlayPause.setImage(UIImage(named: "icons8-pause-50"), for: .normal)
        }
    }
    
    //User pressed like button
    @IBAction func btnLikePressed(_ sender: Any) {
        if let id = currentId {
            songLiked(id: id)
            likeButton.setImage(UIImage(named: "icons8-liked-50"), for: .normal)
            likeButton.isEnabled = false
        }
    }
    
    //Increment the like count to get most liked stories
    func songLiked(id: Int) {
        let url = URL(string: "http://kadacheptabackend.com/music/addLikes.php?idMusic=\(String(id))")
        
        let task = URLSession.shared.dataTask(with: url!) {
            data, response, error in
            let retreivedData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(retreivedData!)
        }
        
        task.resume()
        print("Like song")
    }
    
    //TODO: implement this share functionality
    @IBAction func btnSharePressed(_ sender: Any) {
        displayShareSheet(shareContent: "Checkout this story by kadachepta.com @ https://kadachepta.com/?s=" + lblPlaying.text!)
    }
    
    func displayShareSheet(shareContent:String) {
        if currentSong != nil {
            let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString, ], applicationActivities: nil)
            present(activityViewController, animated: true, completion: {})
        }
    }
    
    //User pressed play/pause button
    override func remoteControlReceived(with event: UIEvent?) {
        if event!.type == UIEvent.EventType.remoteControl {
            if event!.subtype == UIEvent.EventSubtype.remoteControlPause {
                print("Control center pause button pressed")
                player.pauseAudio()
                btnPlayPause.setImage(UIImage(named: "icons8-play-50"), for: .normal)
            } else if event!.subtype == UIEvent.EventSubtype.remoteControlPlay {
                print("Control center play button pressed")
                player.playAudio()
                btnPlayPause.setImage(UIImage(named: "icons8-pause-50"), for: .normal)

            }
        }
    }
    
    //User got a phone call or interruption
    func handleInterruption(notification: NSNotification) {
        player.pauseAudio()
        btnPlayPause.setImage(UIImage(named: "icons8-play-50"), for: .normal)

        let interruptionTypeAsObject = notification.userInfo![AVAudioSessionInterruptionTypeKey] as! NSNumber
        
        let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeAsObject.uintValue)
        
        if let type = interruptionType {
            if type == .ended {
                player.playAudio()
                btnPlayPause.setImage(UIImage(named: "icons8-pause-50"), for: .normal)
            }
        }
    }
    
    //Get list of all stories
    func retrieveSongs() {
        let url = URL(string: "http://kadacheptabackend.com/music/getMusic.php")
    
        let task = URLSession.shared.dataTask(with: url!) {
            data, response, error in
            let retreivedList = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(retreivedList!)
            self.parseSongs(data: retreivedList!)
        }
        
        task.resume()
        print("Getting songs")
    }
    
    //Increment the number of plays count to get most played stories
    func songPlayed(id: Int) {
        let url = URL(string: "http://kadacheptabackend.com/music/addPlays.php?idMusic=\(String(id))")
        
        let task = URLSession.shared.dataTask(with: url!) {
            data, response, error in
            let retreivedData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(retreivedData!)
        }
        
        task.resume()
        print("Play count incremented")
    }
    
    // Parse webservice response into individual stories
    func parseSongs(data: NSString) {
        if data.contains("*") {
            let dataArray = (data as String).split(separator: "*")
            for item in dataArray {
                let itemData = item.split(separator: ",")
                let newSong = Song(idMusic: String(itemData[0]), artist: String(itemData[1]), name: String(itemData[2]), likes: String(itemData[3]), plays: String(itemData[4]))
                songs.append(newSong)
            }
            for s in songs {
                print(s.getName())
            }
            
            DispatchQueue.main.async {
                self.tblSongs.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        cell.titleLabel.text = songs[indexPath.row].getCleanName()
        cell.artistLabel.text = songs[indexPath.row].getArtist()
        return cell
    }
    
    /*
        User tapped the story to play
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        player.playStreaming(fileURL: "http://kadacheptabackend.com/music/" + songs[indexPath.row].getArtist().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + " - ".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + songs[indexPath.row].getName().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        lblPlaying.text = "Playing: \(songs[indexPath.row].getArtist()) - \(songs[indexPath.row].getCleanName())"
        btnPlayPause.setImage(UIImage(named: "icons8-pause-50"), for: .normal)

        likeButton.setImage(UIImage(named: "icons8-like-50"), for: .normal)
        likeButton.isEnabled = true
        
        songPlayed(id: songs[indexPath.row].getId())
        currentId = songs[indexPath.row].getId()
        //set the current song, so you can share!
        currentSong = songs[indexPath.row]
    }
}
