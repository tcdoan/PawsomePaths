//
//  GameMode.swift
//  Hex
//
//  Created by Duong Pham on 2/18/21.
//

import Foundation
import Combine

class GameMode: ObservableObject {
    @Published var board: GameBoard
    private var autoSaveCancellable: AnyCancellable?

    
    init() {
        self.board = GameBoard(size: 11, musicOn: true, soundOn: true)
    }
    
    init(name: String) {
        let defaultsKey = "GameMode.\(name)"
        board = GameBoard(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? GameBoard(size: 11, musicOn: true, soundOn: true)
        autoSaveCancellable = $board.sink { board in
            UserDefaults.standard.setValue(board.json, forKey: defaultsKey)
        }
    }
    
    // MARK: - Access
    var cellValues: [Cell] {
        var cells = [Cell]()
        var id = 0
        for r in 0..<board.size {
            for c in 0..<board.size {
                cells.append(Cell(id: id, colorCode: board.board[r][c]))
                id += 1
            }
        }
        return cells
    }
    
    var playerTurn: String {
        "\(board.playerTurn == 1 ? "Red player" : "Blue player")'s turn"
    }
    
    var result: String {
        switch board.checkResult() {
        case .player1Win: return "Red player wins"
        case .player2Win: return "Blue player wins"
        case .unknown: return "You win"
        }
    }
    
    var gameEnded: Bool {
        switch board.checkResult() {
        case .player1Win: return true
        case .player2Win: return true
        case .unknown: return false
        }
    }
    
    var soundOn: Bool {
        board.soundOn
    }
    
    var musicOn: Bool {
        board.musicOn
    }
    
    // MARK: - Intent(s)
    func play(cellId: Int) {
        board.play(move: BoardPosition(id: cellId, cols: board.size))
    }
    
    func newGame(size: Int) {
        self.board = GameBoard(size: size, musicOn: board.musicOn, soundOn: board.soundOn)
    }
    
    func incrementSize() {
        if board.size < 11 {
            let size = board.size + 1
            newGame(size: size)
        }
    }
    
    func decrementSize() {
        if board.size > 3 {
            let size = board.size - 1
            newGame(size: size)
        }
    }
    
    func toggleSound() {
        board.toggleSound()
    }
    
    func toggleMusic() {
        board.toggleMusic()
    }
}
