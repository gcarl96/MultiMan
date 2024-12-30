//
//  HomeScreen.swift
//  MultiMan
//
//  Created by Gareth Carless on 05/05/2023.
//

import SwiftUI

struct HomeScreen: View {

    @State var isPresentingNewGameView = false
    @State var isPresentingLoadGameView = false
    @State var isPresentingStatsView = false
    
    var body: some View {
        HStack {
            Button(action: {
                isPresentingNewGameView = true
            }) {
                Text("New Game")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isPresentingNewGameView) {
                NavigationView {
                    NewGameView()
                }
            }
            .padding()
            Button(action: {
                isPresentingLoadGameView = true
            }) {
                Text("Load Game")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 200)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isPresentingLoadGameView) {
                NavigationView {
                    LoadGameView()
                }
            }
            .padding()
            Button(action: {
                isPresentingStatsView = true
            }) {
                Text("Stats")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 200)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isPresentingStatsView) {
                NavigationView {
                    StatsView(games: nil)
                }
            }
            .padding()
        }
    }
}
