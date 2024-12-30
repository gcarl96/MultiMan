//
//  GameData.swift
//  MultiMan
//
//  Created by Gareth Carless on 05/05/2023.
//

import Foundation
import UIKit

class GameData: Codable, ObservableObject, Identifiable {
    @Published var players: [Player]
    @Published var scores: [Int]
    @Published var stats: [[String:Int]]
    @Published var currentPlayer: Int
    @Published var id: Int
    @Published var playersMissingGo: [Int]
    @Published var whiteBallPhoto: UIImage?
    @Published var isGameOver: Bool
    
    enum CodingKeys: CodingKey {
            case players
            case scores
            case stats
            case currentPlayer
            case id
            case playersMissingGo
            case whiteBallPhoto
            case isGameOver
        }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        players = try container.decode([Player].self, forKey: .players)
        scores = try container.decode([Int].self, forKey: .scores)
        stats = try container.decode([[String:Int]].self, forKey: .stats)
        currentPlayer = try container.decode(Int.self, forKey: .currentPlayer)
        id = try container.decode(Int.self, forKey: .id)
        playersMissingGo = try container.decode([Int].self, forKey: .playersMissingGo)
        isGameOver = try container.decode(Bool.self, forKey: .isGameOver)
        
        do {
            let decodedImage = try container.decode(CodableImage.self, forKey: .whiteBallPhoto)
            whiteBallPhoto = UIImage(data: decodedImage.photo)
        } catch {
            print("No image saved for game")
        }
        
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(players, forKey: .players)
        try container.encode(scores, forKey: .scores)
        try container.encode(stats, forKey: .stats)
        try container.encode(currentPlayer, forKey: .currentPlayer)
        try container.encode(id, forKey: .id)
        try container.encode(playersMissingGo, forKey: .playersMissingGo)
        if whiteBallPhoto != nil {
            try container.encode(CodableImage(photo: whiteBallPhoto!), forKey: .whiteBallPhoto)
        }
        try container.encode(isGameOver, forKey: .isGameOver)
    }
    
    func gameToText() -> String {
        let playerDisplays = zip(players, scores).map{"\($0.0.name): \($0.1)"}
        return playerDisplays.joined(separator: "\n")
    }
    
    init(id: Int, players: [Player]) {
        self.id = id
        self.players = players
        self.currentPlayer = 0
        self.playersMissingGo = []
        self.isGameOver = false
        self.scores = []
        self.stats = []
        for _ in (0..<players.count) {
            self.scores.append(0)
            self.stats.append(["Longest Potting Streak" : 0,
                               "Regular Pots" : 0,
                               "Black Pots" : 0,
                               "Regular Gills" : 0,
                               "Black Gills" : 0,
                               "Misses" : 0,
                               "Turns" : 0,
                               "Regular Fouls" : 0,
                               "Black Fouls" : 0])
        }
    }
    
    func setValues(newGameData : GameData) {
        self.id = newGameData.id
        self.players = newGameData.players
        self.currentPlayer = newGameData.currentPlayer
        self.playersMissingGo = newGameData.playersMissingGo
        self.isGameOver = newGameData.isGameOver
        self.scores = newGameData.scores
        self.stats = newGameData.stats
        
        print(self.id)
        print(self.players)
        print(self.currentPlayer)
        print(self.playersMissingGo)
        print(self.isGameOver)
        print(self.scores)
        print(self.stats)
    }
    
    func pottedRegular(gilled: Bool) {
        self.scores[currentPlayer] += gilled ? 2 : 1
        print(self.scores)
    }
    
    func pottedBlack(gilled: Bool) {
        self.scores[currentPlayer] += gilled ? 6 : 3
    }
    
    func fouledRegular() {
        self.playersMissingGo.append(currentPlayer)
        self.nextPlayer()
    }
    
    func hasMissedGo() {
        self.playersMissingGo.removeAll(where: {$0 == currentPlayer})
    }
    
    func fouledBlack(gilled: Bool) {
        if gilled {
            if self.scores[currentPlayer] > 0 {
                self.scores[currentPlayer] = -self.scores[currentPlayer]
            } else {
                self.scores[currentPlayer] += self.scores[currentPlayer]
            }
        } else {
            self.scores[currentPlayer] = 0
        }
        self.playersMissingGo.append(currentPlayer)
        self.nextPlayer()
    }
    
    func nextPlayer() {
        currentPlayer += 1
        if currentPlayer == players.count {
            currentPlayer = 0
        }
        if playersMissingGo.contains(currentPlayer) {
            hasMissedGo()
            nextPlayer()
        }
    }
    
    func gameOver() {
        isGameOver = true
    }
    
}


public struct CodableImage: Codable {

    public let photo: Data
    
    public init(photo: UIImage) {
        self.photo = photo.pngData()!
    }
}
