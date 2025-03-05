import SwiftUI

enum AppStateHBS { case splashHBS, onboardHBS, mainMenuHBS, mainVMenuHBS }
@main
struct HyperBallSmashApp: App {
    @StateObject private var shopManagerHBS = ShopManagerHBS()
    @StateObject private var gameManagerHBS = GameManagerHBS()

    var body: some Scene {
        WindowGroup {
            CoordinatorViewHBS()
                .persistentSystemOverlays(.hidden)
                .statusBarHidden()
                .environmentObject(shopManagerHBS)
                .environmentObject(gameManagerHBS)
        }
    }
}
