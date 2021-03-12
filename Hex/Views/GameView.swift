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
    @State var showResult = false
    @State private var showSettings = false
    @ObservedObject var hexGame: GameMode
    @State var soundOn: Bool

    let red = Color(red: 0.9296875, green: 0.46, blue: 0.453)
    let blue = Color(red:0.39, green:0.55, blue:0.894)
    let backgroundColor = Color(red: 0.83984, green: 0.90625, blue: 0.7265625, opacity: 1)
    let buttonFontSize: CGFloat = 12
    let gameTitle: CGFloat = 36
    let playerTurnFontSize: CGFloat = 18
    
    var body: some View {
        let board = hexGame.board
        if (welcomeView) {
            WelcomeView()
        } else {
            GeometryReader { geometry in
                Rectangle().foregroundColor(backgroundColor).ignoresSafeArea().zIndex(-2)
                VStack {
                    Text("Back")
                        .padding()
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            welcomeView = true
                            playSound("MouseClick", type: "mp3", soundOn: soundOn)
                        }
                    Text("Hex Game")
                        .font(Font.custom("KronaOne-Regular", size: gameTitle))
                        .foregroundColor(Color(red: 0.82422, green: 0.37891, blue: 0.207, opacity: 1))
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
                        .popover(isPresented: $showSettings) {
                            settingsView(game: hexGame, soundOn: $soundOn)
                                .frame(width: 250, alignment: .top)
                        }

                        ZStack {
                            if (showResult == true) {
                                ForEach(0...8, id: \.self) {_ in
                                    FireworkRepresentable().position(x: CGFloat.random(in: 10 ... 2 * geometry.size.width), y: CGFloat.random(in: 10 ... geometry.size.height)).zIndex(-1)
                                }
                            }
                            HexGrid(hexGame.cellValues, cols: hexGame.board.size) { cell in
                                CellView(cell: cell).onTapGesture {
                                    playSound("WaterDrop", type: "mp3", soundOn: soundOn)
                                    if !hexGame.gameEnded { // only when game has not ended
                                        hexGame.play(cellId: cell.id)
                                    }
                                    if hexGame.gameEnded {
                                        showResult = true
                                    }
                                }
                            }
                            .popup(isPresented: $showResult) {
                                ZStack {
                                    Image(hexGame.result == "Computer wins" ? "losing" : "background")
                                    VStack {
                                        resultReport(result: hexGame.result, soundOn: soundOn)
                                            .padding(.bottom, 150)
                                            .padding(.top, 80)
                                        newGameButton(game: hexGame, showResult: showResult)
                                        ZStack {
                                            Button("Menu") {
                                                welcomeView = true
                                                hexGame.newGame(size: hexGame.board.size)
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
                        }
                newGameButton(game: hexGame, showResult: !showResult)
                    .foregroundColor(!showResult ? .blue : .gray)
                    .padding()
                }
            }
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
                .overlay(Text("New Game")
                .font(Font.custom("KronaOne-Regular", size: buttonFontSize)))
        }
    }
}

struct resultReport: View {
    var result: String
    let resultFontSize: CGFloat = 30
    @State var soundOn: Bool

    var body: some View {
        VStack {
            ZStack {
                Text("\(result)")
                    .font(Font.custom("KronaOne-Regular", size: resultFontSize))
                    .foregroundColor(Color(red: 0.1758, green: 0.515625, blue: 0.53901, opacity: 1))
            }
        }
    }
}

struct settingsView: View {
    @ObservedObject var game: GameMode
    @State private var showAlert: Bool = false
    @Binding var soundOn: Bool
    private let palePink: Color = Color(red: 0.996, green: 0.8633, blue: 0.8828 , opacity: 1)

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
                .padding()
        }
        Section(header: Text("Sound")) {
            Button {
                soundOn = !soundOn
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).frame(width: 50, height: 50, alignment: .center)                        .foregroundColor(palePink)
                    Image(systemName: soundOn ? "speaker.wave.3" : "speaker").imageScale(.large)
                        .foregroundColor(.pink)
                }
                .padding()
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            GameView(hexGame: SinglePlayerGame())
//            GameView(hexGame: SinglePlayerGame())
//        }
//    }
//}
