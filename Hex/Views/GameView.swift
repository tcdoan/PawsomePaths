//
//  GameView.swift
//  Hex
//
//  Created by Duong Pham on 2/14/21.
//

import SwiftUI
import UIKit

struct GameView: View {
    @State private var welcomeView = false
    @State private var showResult = false
    @State private var showSettings = false
    @ObservedObject var hexGame: GameMode
    let red = Color(red: 0.9296875, green: 0.46, blue: 0.453)
    let blue = Color(red:0.39, green:0.55, blue:0.894)
    let buttonFontSize: CGFloat = 12
    let gameTitle: CGFloat = 36
    let playerTurnFontSize: CGFloat = 20
    
    var body: some View {
        let board = hexGame.board
        if (welcomeView) {
            WelcomeView()
        } else {
            Text("Back")
                .padding()
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    welcomeView = true
                }
            
            Text("Hex Game")
                .font(Font.custom("KronaOne-Regular", size: gameTitle))
                .foregroundColor(Color(red: 0, green: 0.14453125, blue: 0, opacity: 1))
            
            
            HStack {
                Text("Player 1 turn").foregroundColor(board.playerTurn == 1 ? red : .gray)
                    .padding()
                Text("Player 2 turn").foregroundColor(board.playerTurn == 2 ? blue : .gray)
                    .padding()
            }
            .font(Font.custom("KronaOne-Regular", size: playerTurnFontSize))


            Image(systemName: "gearshape")
                .onTapGesture {
                    showSettings = true
                }
                .popup(isPresented: $showSettings) {
                    settingsView(game: hexGame)
                        .frame(width: 250, height: 75, alignment: .top)
                }
            GeometryReader { geometry in
                ZStack {
                    HexGrid(hexGame.cellValues, cols: hexGame.board.size) { cell in
                        CellView(cell: cell).onTapGesture {
                            if hexGame.gameEnded {
                                showResult = true
                            } else {
                                hexGame.play(cellId: cell.id)
                            }
                        }
                    }
                    .popup(isPresented: $showResult) {
                        ZStack {
                            Image("background")
                            VStack {
                                resultReport(game: hexGame)
                                    .padding(.vertical, 150)
                                newGameButton(game: hexGame, showResult: showResult)
                                ZStack {
                                    Button("Menu") {
                                        welcomeView = true
                                    }
                                    RoundedRectangle(cornerRadius: 10).opacity(0.3)
                                }
                                .frame(width: 100, height: 40, alignment: .center)
                                .padding()
                            }
                        }
                        .frame(width: 300, height: 450, alignment: .center)
                        .cornerRadius(30.0)
                        .font(Font.custom("KronaOne-Regular", size: buttonFontSize))
                        .foregroundColor(Color(red: 0.1758, green: 0.515625, blue: 0.53901, opacity: 1))
                    }
                    
                    if (showResult == true) {
                        FireworkRepresentable().offset(x: geometry.size.width / 2)                    .zIndex(-1)
                        FireworkRepresentable().zIndex(-1)
                        FireworkRepresentable().offset(x: geometry.size.width, y: geometry.size.height / 2).zIndex(-1)
                    }
                }
            }
            newGameButton(game: hexGame, showResult: !showResult)
                .foregroundColor(!showResult ? .blue : .gray)
                .padding()
        }
    }
}

struct newGameButton: View {
    var game: GameMode
    let buttonFontSize: CGFloat = 12

    var showResult: Bool
    var body: some View {
        Button(action: {showResult ? game.newGame(size: game.board.size) : nil}) {
            RoundedRectangle(cornerRadius: 10).opacity(0.3)
                .frame(width: 100, height: 40, alignment: .center)
                .overlay(Text("New Game").font(Font.custom("KronaOne-Regular", size: buttonFontSize))
)
        }
    }
}

struct resultReport: View {
    var game: GameMode
    let resultFontSize: CGFloat = 30

    var body: some View {
        VStack {
            ZStack {
                Text("\(game.result)")
                    .font(Font.custom("KronaOne-Regular", size: resultFontSize))
                    .foregroundColor(Color(red: 0.1758, green: 0.515625, blue: 0.53901, opacity: 1))
            }
        }
    }
}

struct settingsView: View {
    @ObservedObject var game: GameMode
    @State private var showAlert: Bool = false
    var body: some View {
        Section(header: Text("Board size")) {
            Stepper(
                onIncrement: {
                    game.incrementSize()
                    if game.board.size == 11 {
                        showAlert = true
                    }
                },
                onDecrement: {
                    game.decrementSize()
                    if game.board.size == 3 {
                        showAlert = true
                    }
                },
                label: {
                    Text("\(game.board.size)")
                })
                .alert(isPresented: $showAlert) { () -> Alert in
                    Alert(title: Text("Invalid board size"), message: Text("Board size cannot be less than 3x3 or greater than 11x11"), dismissButton: Alert.Button.cancel())
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameView(hexGame: SinglePlayerGame())
            GameView(hexGame: SinglePlayerGame())
        }
    }
}
