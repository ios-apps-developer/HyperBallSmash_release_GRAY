import SwiftUI

protocol GameSceneDelegateHBS: AnyObject {
    func didUpdateScoreHBS(_ scoreHBS: Int)
    func didUpdateLivesHBS(_ livesHBS: Int)
    func didEndGameHBS(winHBS: Bool)
}

class GameManagerHBS: ObservableObject, GameSceneDelegateHBS {
    enum LevelStateHBS: String {
        case notStarted
        case inProgress
        case completed
    }

    @Published var isGameOverHBS = false
    @Published var isGameWinHBS = false
    @Published var isPausedHBS = false
    @Published var currentLevelHBS = 1 {
        didSet { saveProgressHBS() }
    }
    @Published var levelStatesHBS: [Int: LevelStateHBS] = [:] {
        didSet { saveProgressHBS() }
    }
    @Published var scoreHBS: Int = 0
    @Published var livesHBS: Int = 3
    @Published var highScoresHBS: [Int: Int] = [:]
    
    private let defaultsHBS = UserDefaults.standard
    private let levelStatesKeyHBS = "levelStatesHBS"
    private let currentLevelKeyHBS = "currentLevelHBS"
    private let highScoresKeyHBS = "highScoresHBS"

    init() {
        loadProgressHBS()
        loadHighScoresHBS()
    }
    
    func didUpdateScoreHBS(_ scoreHBS: Int) {
        self.scoreHBS = scoreHBS
        if let currentHighScore = highScoresHBS[currentLevelHBS] {
            if scoreHBS > currentHighScore {
                highScoresHBS[currentLevelHBS] = scoreHBS
                saveHighScoresHBS()
            }
        } else {
            highScoresHBS[currentLevelHBS] = scoreHBS
            saveHighScoresHBS()
        }
    }
    
    func didUpdateLivesHBS(_ livesHBS: Int) {
        self.livesHBS = livesHBS
        if livesHBS <= 0 {
            isGameOverHBS = true
        }
    }
    
    func didEndGameHBS(winHBS: Bool) {
        print("Game end triggered - Win: \(winHBS)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if winHBS {
                print("Processing win condition")
                self.levelStatesHBS[self.currentLevelHBS] = .completed
                if self.currentLevelHBS < 20 {
                    self.levelStatesHBS[self.currentLevelHBS + 1] = .inProgress
                }
                self.isGameWinHBS = true
            } else {
                self.isGameOverHBS = true
            }
            self.isPausedHBS = true
            self.saveProgressHBS()
        }
    }
    
    func getHighScoreHBS(for level: Int) -> Int {
        return highScoresHBS[level] ?? 0
    }
    
    func startLevelHBS(_ levelHBS: Int) {
        isGameOverHBS = false
        isGameWinHBS = false
        currentLevelHBS = levelHBS
        scoreHBS = 0
        livesHBS = 3
        levelStatesHBS[levelHBS] = .inProgress
        saveProgressHBS()
    }

    func resetGameStatesHBS() {
        DispatchQueue.main.async {
            self.isGameOverHBS = false
            self.isGameWinHBS = false
            self.isPausedHBS = false
            self.scoreHBS = 0
            self.livesHBS = 3
        }
    }

    func restartCurrentLevelHBS() {
        resetGameStatesHBS()
        levelStatesHBS[currentLevelHBS] = .inProgress
        saveProgressHBS()
    }

    func startNextLevelHBS() {
        if currentLevelHBS < 20 {
            resetGameStatesHBS()
            currentLevelHBS += 1
            levelStatesHBS[currentLevelHBS] = .inProgress
            saveProgressHBS()
        }
    }

    private func saveProgressHBS() {
        let levelStatesDataHBS = levelStatesHBS.reduce(into: [String: String]()) { resultHBS, pairHBS in
            resultHBS["\(pairHBS.key)"] = pairHBS.value.rawValue
        }
        defaultsHBS.set(levelStatesDataHBS, forKey: levelStatesKeyHBS)
        defaultsHBS.set(currentLevelHBS, forKey: currentLevelKeyHBS)
    }
    
    private func saveHighScoresHBS() {
        let scoresData = highScoresHBS.reduce(into: [String: Int]()) { result, pair in
            result["\(pair.key)"] = pair.value
        }
        defaultsHBS.set(scoresData, forKey: highScoresKeyHBS)
    }
    
    private func loadHighScoresHBS() {
        if let savedScores = defaultsHBS.dictionary(forKey: highScoresKeyHBS) as? [String: Int] {
            highScoresHBS = savedScores.reduce(into: [Int: Int]()) { result, pair in
                if let level = Int(pair.key) {
                    result[level] = pair.value
                }
            }
        }
    }
    
    private func loadProgressHBS() {
        if let savedLevelStatesHBS = defaultsHBS.dictionary(forKey: levelStatesKeyHBS) as? [String: String] {
            levelStatesHBS = savedLevelStatesHBS.reduce(into: [Int: LevelStateHBS]()) { resultHBS, pairHBS in
                if let intKeyHBS = Int(pairHBS.key), let levelStateHBS = LevelStateHBS(rawValue: pairHBS.value) {
                    resultHBS[intKeyHBS] = levelStateHBS
                }
            }
        }

        currentLevelHBS = defaultsHBS.integer(forKey: currentLevelKeyHBS)
        if currentLevelHBS == 0 { currentLevelHBS = 1 }

        if levelStatesHBS.isEmpty {
            for levelHBS in 1...20 {
                levelStatesHBS[levelHBS] = levelHBS == 1 ? .inProgress : .notStarted
            }
        }
    }
}
