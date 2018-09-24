

import Foundation

class Song {
    var idMusic: Int
    var artist: String
    var name: String
    var likes: Int
    var plays: Int
    
    init(idMusic: String, artist: String, name: String, likes: String, plays: String) {
        self.idMusic = Int(idMusic)!
        self.artist = artist
        self.name = name
        self.likes = Int(likes)!
        self.plays = Int(plays)!
    }
    
    func getId() -> Int {
        return idMusic
    }
    
    func getName() -> String {
        return name
    }
    
    func getCleanName() -> String {
        return String(name.dropLast(4))
    }
    
    func getLikes() -> Int {
        return likes
    }
    
    func getPlays() -> Int {
        return plays
    }
    
    func getArtist() -> String {
        return artist
    }
}
