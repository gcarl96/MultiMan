//
//  LoadGameView.swift
//  MultiMan
//
//  Created by Gareth Carless on 05/05/2023.
//

import Foundation
import SwiftUI


struct LoadGameView: View {
    @ObservedObject var gameManager = GameManager()
    
    @State private var isPresentingMainGameView = false
    @State private var isPresentingHomeView = false


    @State var chosenGame = 0
    @State var isConfirmationPresented = false
    
    init() {
        gameManager.loadGames()
    }

    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Load Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
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
            
            
            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(gameManager.games) { game in
                            GameTileView(game: game, isSelected: self.chosenGame == game.id, gameOver:game.isGameOver)
                                .onTapGesture {
                                    self.chosenGame = game.id
                                }
                                .onLongPressGesture {
                                    isConfirmationPresented = true
                                }
                                .confirmationDialog("Change background", isPresented: $isConfirmationPresented) {
                                    Button("Yes") { gameManager.deleteGame(gameId: game.id) }
                                    Button("No") { }
                                } message: {
                                    Text("Delete Game")
                                }
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            Button(action: {
                // Show PoolGameView
                if self.gameManager.games.first(where: {$0.id == self.chosenGame}) != nil {
                    isPresentingMainGameView = true
                }
            }) {
                Text(self.gameManager.games.first(where: {$0.id == self.chosenGame})?.isGameOver ?? false ? "See Result" : "Start Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isPresentingMainGameView) {
                if let chosenGame = self.gameManager.games.first(where: {$0.id == self.chosenGame}) {
                        NavigationView {
                        PoolGameView(gameData: chosenGame)
                    }
                }
            }
        }
        .padding()
    }
}


struct GameTileView: View {
    let game: GameData
    var isSelected: Bool
    var gameOver: Bool
    
    var body: some View {
        VStack {
            Spacer()
            ForEach(Array(game.players.enumerated()), id: \.element) { index, player in
                Text("\(game.players[index].name) - \(game.scores[index])")
                    .font(.body)
                    .foregroundColor(.white)
                    .bold()
                    .padding(5)
            }
            Spacer()
        }
        .frame(width: 100, height: 100)
        .background(
            gameOver ? isSelected ? Color.orange : Color.red
            : isSelected ? Color.blue : Color.gray
        )
        .cornerRadius(10)
        .padding(10)
    }
}
