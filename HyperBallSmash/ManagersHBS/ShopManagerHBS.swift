import SwiftUI

class ShopManagerHBS: ObservableObject {
    
    private let balanceCoinKeyHBS = "ShopBalanceHBS"
    private let ownedBallsKeyHBS = "ShopOwnedBallHBS"
    private let selectedBallKeyHBS = "ShopSelectedBallHBS"
    
    @Published var balanceCoinHBS: Int {
        didSet {
            saveToUDHBS()
        }
    }

    @Published var ownedBallsHBS: Set<String> {
        didSet {
            saveToUDHBS()
        }
    }

    @Published var selectedBallHBS: String {
        didSet {
            saveToUDHBS()
        }
    }

    init() {
        self.balanceCoinHBS = UserDefaults.standard.integer(forKey: balanceCoinKeyHBS)
        self.ownedBallsHBS = Set(UserDefaults.standard.stringArray(forKey: ownedBallsKeyHBS) ?? ["ball1HBS"])
        self.selectedBallHBS = UserDefaults.standard.string(forKey: selectedBallKeyHBS) ?? "ball1HBS"
        if UserDefaults.standard.object(forKey: balanceCoinKeyHBS) == nil {
            self.balanceCoinHBS = 150
            saveToUDHBS()
        }
        if !ownedBallsHBS.contains(selectedBallHBS) {
            self.selectedBallHBS = "ball1HBS"
            saveToUDHBS()
        }
    }

    func purchaseBallHBS(imageName: String, price: Int) {
        guard balanceCoinHBS >= price, !ownedBallsHBS.contains(imageName) else { return }
        balanceCoinHBS -= price
        ownedBallsHBS.insert(imageName)
    }

    func selectBallHBS(imageName: String) {
        guard ownedBallsHBS.contains(imageName) else { return }
        selectedBallHBS = imageName
    }

    func isOwnedBallHBS(imageName: String) -> Bool {
        ownedBallsHBS.contains(imageName)
    }

    func canAffordBallHBS(price: Int) -> Bool {
        balanceCoinHBS >= price
    }

    func updateCoinBalanceHBS(by amount: Int) {
        balanceCoinHBS += amount
    }

    private func saveToUDHBS() {
        UserDefaults.standard.set(balanceCoinHBS, forKey: balanceCoinKeyHBS)
        UserDefaults.standard.set(Array(ownedBallsHBS), forKey: ownedBallsKeyHBS)
        UserDefaults.standard.set(selectedBallHBS, forKey: selectedBallKeyHBS)
    }
}

