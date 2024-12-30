//
//  GameManager.swift
//  MultiMan
//
//  Created by Gareth Carless on 05/05/2023.
//

import Foundation


class GameManager: ObservableObject {
    static let shared = GameManager()
    
    @Published var games: [GameData] = []
    @Published var isSaving = false
    
    func saveGame(gameData: GameData) {
        print("Saving game with id: \(gameData.id)")
        isSaving = true
        
        self.loadGames()
        
        self.games = self.games.filter({$0.id != gameData.id})
        self.games.append(gameData)
        
        for game in games {
            for (index, player) in game.players.enumerated() {
                print("\(player.name) - \(game.scores[index])")
            }
        }
        
        self.saveGames()
        isSaving = false
    }
    
    func saveGames() {
        do {
            let data = try JSONEncoder().encode(self.games)
            UserDefaults.standard.set(data, forKey: "games")
        } catch {
            print("Error saving games: \(error.localizedDescription)")
        }
    }
    
    func loadGames() {
        do {
            if let data = UserDefaults.standard.data(forKey: "games") {
                print("Trying to load games")
                self.games = try JSONDecoder().decode([GameData].self, from: data)
                self.games.sort(by: { (leftProfile, rightProfile) -> Bool in
                    return leftProfile.isGameOver == false && rightProfile.isGameOver != false
                })
            }
        } catch {
            print("Error loading games: \(error.localizedDescription)")
        }
    }
    
    
    func deleteGame(gameId: Int) {
        self.loadGames()
        
        self.games = self.games.filter({$0.id != gameId})
        
        for game in games {
            print(game)
        }
        
        self.saveGames()
    }
}
