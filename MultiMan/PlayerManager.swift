//
//  PlayerManager.swift
//  MultiMan
//
//  Created by Gareth Carless on 05/05/2023.
//

import Foundation

class PlayerManager: ObservableObject {
    static let shared = PlayerManager()
    
    var players: [Player] = []
    
    func addPlayer(name: String) {
        let player = Player(name: name)
        players.append(player)
    }
    
    func deletePlayer(player: Player) {
        print("deleting player: \(player.name)")
        players = players.filter({ $0.name != player.name })
    }
    
    func savePlayers() {
        do {
            let data = try JSONEncoder().encode(players)
            UserDefaults.standard.set(data, forKey: "players")
        } catch {
            print("Error saving players: \(error.localizedDescription)")
        }
    }
    
    func loadPlayers() {
        do {
            if let data = UserDefaults.standard.data(forKey: "players") {
                players = try JSONDecoder().decode([Player].self, from: data)
            }
        } catch {
            print("Error loading players: \(error.localizedDescription)")
        }
    }
}
