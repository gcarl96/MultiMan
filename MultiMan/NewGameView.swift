//
//  NewGameView.swift
//  MultiMan
//
//  Created by Gareth Carless on 05/05/2023.
//

import Foundation
import SwiftUI

struct PlayerRowView: View {
    let player: Player
    let isSelected: Bool
    let toggleSelection: () -> Void
    
    var body: some View {
        HStack {
            Text(player.name)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleSelection()
        }
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
    }
}

struct NewGameView: View {
    @ObservedObject var playerManager = PlayerManager.shared
    @ObservedObject var gameManager = GameManager()
    
    @State private var selectedPlayers: [Player] = []
    @State private var newPlayerName: String = ""
    @FocusState private var addingNewPlayer: Bool
    @State private var isPresentingMainGameView = false
    @State private var isPopoverPresented = false
    @State private var isSheetPresented = false
    @State private var isConfirmationPresented = false
    @State private var isPresentingHomeView = false
    

    
    init() {
        playerManager.loadPlayers()
    }

    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Select Players:")
                    .fontWeight(.bold)
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
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                        ForEach(playerManager.players) { player in
                            PlayerTileView(player: player, isSelected: selectedPlayers.contains(player))
                                .onTapGesture {
                                    if let index = selectedPlayers.firstIndex(of: player) {
                                        selectedPlayers.remove(at: index)
                                    } else {
                                        selectedPlayers.append(player)
                                    }
                                }
                                .onLongPressGesture {
                                    isConfirmationPresented = true
                                }
                                .confirmationDialog("Change background", isPresented: $isConfirmationPresented) {
                                    Button("Yes") { playerManager.deletePlayer(player: player) }
                                    Button("No") { }
                                } message: {
                                    Text("Delete Player")
                                }
                        }
                    }
                    .padding()
                }
            }
            
            VStack {
                HStack {
                    Button(action: {
                        isPopoverPresented = true
                    }) {
                        Label("Add Player", systemImage: "plus.circle")
                    }
                    .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
                        VStack {
                            HStack {
                                Text("New Player Name:")
                                TextField("", text: $newPlayerName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            Button(action: {
                                // Add new player and dismiss popover
                                if !newPlayerName.isEmpty {
                                    playerManager.addPlayer(name: newPlayerName)
                                    newPlayerName = ""
                                    isPopoverPresented = false
                                }
                            }) {
                                Text("Add")
                            }
                            .disabled(newPlayerName.isEmpty)
                            .padding(.top, 10)
                        }
                        .padding(10)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                // Start new game with selected players
                print("starting game")
                playerManager.savePlayers()
                // Show PoolGameView
                isPresentingMainGameView = true
            }) {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isPresentingMainGameView) {
                NavigationView {
                    PoolGameView(gameData: GameData(id: Int(Date().timeIntervalSince1970), players: selectedPlayers))
                }
            }
        }
        .padding()
    }
}


struct PlayerTileView: View {
    let player: Player
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text(player.name)
                .font(.title2)
                .foregroundColor(.white)
                .bold()
                .padding(5)
            Spacer()
        }
        .frame(width: 100, height: 80)
        .background(isSelected ? Color.blue : Color.gray)
        .cornerRadius(10)
        .padding(10)
    }
}

