//
//  StatsView.swift
//  MultiMan
//
//  Created by Gareth Carless on 07/05/2023.
//

import SwiftUI

struct StatsView: View {
    var stats: [String: [String: Float]]
    var gamesData: [GameData]
    var columnKeys = ["Games Played", "Wins", "Longest Potting Streak", "Pots", "Pot Success", "Regular Pots", "Black Pots", "Regular Gills", "Black Gills", "Turns", "Fouls", "Regular Fouls", "Black Fouls", "Pots After Player", "Fouls After Player", "Wins After Player"]
    
    @State private var isPresentingHomeView = false
    @State private var statsPerGame = false
    
    init(games: [GameData]?) {
        let gameManager = GameManager()
        gameManager.loadGames()
        gamesData = games ?? gameManager.games
        
        let players = Set(Array(self.gamesData.map{ $0.players.map{ $0.name } }.joined()))
        
        stats = Dictionary(uniqueKeysWithValues: players.map {($0, [String: Float]())})
        
        let sumStats = ["Regular Pots", "Black Pots", "Regular Gills", "Black Gills", "Turns", "Regular Fouls", "Black Fouls"]
        let afterPlayerStats = ["Pots After Player", "Fouls After Player"]
        
        for player in stats.keys {
            let relevantGames = gamesData.filter({$0.players.map{$0.name}.contains(player)})
            stats[player]!["Games Played"] = Float(relevantGames.count)
            stats[player]!["Wins"] = Float(relevantGames.filter({findWinningPlayer(game: $0) == player && $0.isGameOver}).count)
            stats[player]!["Longest Potting Streak"] = Float(relevantGames.map{findStatForPlayer(game: $0, player: player, stat: "Longest Potting Streak", aboutSubsequentPlayer: false)}.max()!)
            for stat in sumStats {
                stats[player]![stat] = Float(relevantGames.map{findStatForPlayer(game: $0, player: player, stat: stat, aboutSubsequentPlayer: false)}.reduce(0, +))
            }
            stats[player]!["Pots"] = stats[player]!["Regular Pots"]! + stats[player]!["Black Pots"]! + stats[player]!["Regular Gills"]! + stats[player]!["Black Gills"]!
            stats[player]!["Fouls"] = stats[player]!["Regular Fouls"]! + stats[player]!["Black Fouls"]!
            stats[player]!["Pot Success"] = stats[player]!["Pots"]! / (stats[player]!["Pots"]! + stats[player]!["Turns"]!)
            
            for stat in afterPlayerStats {
                stats[player]![stat] = Float(relevantGames.map{findStatForPlayer(game: $0, player: player, stat: stat, aboutSubsequentPlayer: true)}.reduce(0, +))
            }
            stats[player]!["Wins After Player"] = Float(relevantGames.filter({playerAfterWon(game: $0, player: player) && $0.isGameOver}).count)
        }
        print(stats)
    }
    
    var body: some View {
        VStack {
            HStack {
                Toggle(statsPerGame ? "Stats Per Game" : "Overall Stats", isOn: $statsPerGame)
                Spacer()
                Button(action: {
                    isPresentingHomeView = true
                }) {
                    Image(systemName: "house")
                        .font(.system(size: 30))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.black)
                        .cornerRadius(5)
                        .padding(.bottom, 20)
                }
                .sheet(isPresented: $isPresentingHomeView) {
                    NavigationView {
                        HomeScreen()
                    }
                }
            }
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(columnKeys, id: \.self) { key in
                        VStack {
                            Text(key)
                                .font(.headline)
                                .padding(.top)
                                .padding(.bottom, 5)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(topPlayersForStat(key), id: \.self) { player in
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.blue)
                                            .frame(width: 150, height: 50)
                                            .overlay(
                                                VStack {
                                                    Text(player)
                                                        .foregroundColor(.white)
                                                        .font(.headline)
                                                        .padding(.top)
                                                    Text(String(format: "%.1f", (stats[player]?[key] ?? 0) / (statsPerGame && !["Games Player", "Longest Potting Streak", "Pot Success"].contains(key) ? stats[player]!["Games Played"]! : 1) ))
                                                        .foregroundColor(.white)
                                                        .font(.subheadline)
                                                        .padding(.bottom)
                                                }
                                            )
                                    }
                                }
                                .padding(.leading)
                                .padding(.bottom)
                            }
                            Divider()
                        }
                    }
                }
            }
        }
    }

    
    func findWinningPlayer(game: GameData) -> String {
        let highScore = game.scores.max() ?? 0
        let winningPlayerIndex = game.scores.firstIndex(of: highScore) ?? 0
        let winningPlayer = game.players[winningPlayerIndex]
        return winningPlayer.name
    }
    
    func playerAfterWon(game: GameData, player: String) -> Bool {
        var playerIndex = game.players.map { $0.name }.firstIndex(of: player) ?? 0
        playerIndex += 1
        if playerIndex >= game.players.count {
            playerIndex = 0
        }
        
        let highScore = game.scores.max() ?? 0
        let winningPlayerIndex = game.scores.firstIndex(of: highScore) ?? 0
        
        return playerIndex == winningPlayerIndex
    }
    
    func findStatForPlayer(game: GameData, player: String, stat: String, aboutSubsequentPlayer: Bool) -> Int {
        var playerIndex = game.players.map { $0.name }.firstIndex(of: player) ?? 0
        
        if aboutSubsequentPlayer {
            playerIndex += 1
            if playerIndex >= game.players.count {
                playerIndex = 0
            }
        }
        var totalStats = game.stats[playerIndex][stat] ?? 0
        
        if aboutSubsequentPlayer {
            if stat == "Pots After Player" {
                totalStats = (game.stats[playerIndex]["Regular Pots"] ?? 0) + (game.stats[playerIndex]["Regular Gills"] ?? 0) + (game.stats[playerIndex]["Black Pots"] ?? 0) + (game.stats[playerIndex]["Black Gills"] ?? 0)
            }
            if stat == "Fouls After Player" {
                totalStats = (game.stats[playerIndex]["Regular Fouls"] ?? 0) + (game.stats[playerIndex]["Black Fouls"] ?? 0)
            }
        }
        
        return totalStats
    }
    
    func abbreviateString(_ str: String) -> String {
        let words = str.split(separator: " ")
        var result = ""
        for word in words {
            if let firstLetter = word.first {
                result.append(firstLetter)
            }
        }
        return result
    }
    
    func topPlayersForStat(_ stat: String) -> [String] {
        let sortedPlayers = stats.keys.sorted {
            stats[$0]?[stat] ?? 0 > stats[$1]?[stat] ?? 0
        }
        let topPlayers = Array(sortedPlayers)
        return topPlayers
    }
}
