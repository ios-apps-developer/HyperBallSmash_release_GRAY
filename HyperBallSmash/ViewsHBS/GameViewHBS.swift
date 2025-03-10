import SpriteKit
import SwiftUI

struct GameViewHBS: View {
    @EnvironmentObject private var shopManagerHBS: ShopManagerHBS
    @EnvironmentObject private var coordinatorHBS: GameManagerHBS
    @ObservedObject var musicManagerHBS = MusicManagerHBS.shared
    @Environment(\.dismiss) private var dismiss
    @State private var boardScale: CGFloat = 0.1
    @State private var boardOpacity: Double = 0.0
    @State private var backgroundOpacity: Double = 0.0
    @State private var randomCoin: Int = 0
    @State private var scene: GameSceneHBS?
    @State private var isPaused: Bool = true
    @State private var showLevelComplete: Bool = false
    @State private var isTransitioning = false

    var body: some View {
        GeometryReader { geometry in
            let isIpad = geometry.size.width > 768
            let scaleFactor: CGFloat = isIpad ? 1.5 : 1.0
            ZStack {
                Image("bg_onbHBS")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let scene = scene {
                    SpriteView(scene: scene)
                        .edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(isTransitioning ? 0 : 1)
                }

                VStack(spacing: 10 * scaleFactor) {
                    gameHeader(scaleFactor: scaleFactor)
                    Spacer()
                }

                if isPaused {
                    gamePauseMenu
                }

                if coordinatorHBS.isGameWinHBS {
                    gameWinMenu
                        .onAppear {
                            awardCoin()
                            isPaused = true
                            scene?.isPaused = true
                            let highScore = coordinatorHBS.getHighScoreHBS(for: coordinatorHBS.currentLevelHBS)
                            if coordinatorHBS.scoreHBS > highScore {
                                showNewHighScore()
                            }
                        }
                }

                if coordinatorHBS.isGameOverHBS {
                    gameOverMenu
                        .onAppear {
                            isPaused = true
                            scene?.isPaused = true
                        }
                }
            }
            .onAppear {
                setupScene()
            }
            .onChange(of: coordinatorHBS.currentLevelHBS) { _ in
                setupScene()
            }
            .persistentSystemOverlays(.hidden)
            .statusBarHidden()
            .navigationBarBackButtonHidden(true)
        }
    }

    private func gameHeader(scaleFactor: CGFloat) -> some View {
        HStack {
            ZStack {
                Image("window_topHBS")
                    .resizable()
                    .frame(width: 120 * scaleFactor, height: 60 * scaleFactor)
                HStack(spacing: 0) {
                    Image("\(UserDefaults.standard.string(forKey: "selAvHBS") ?? "av2HBS")")
                        .resizable()
                        .frame(width: 44 * scaleFactor, height: 44 * scaleFactor)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2 * scaleFactor)
                        )
                    Spacer()
                    livesIndicator(scaleFactor: scaleFactor)
                }
                .frame(width: 100 * scaleFactor)
            }

            Spacer()

            ZStack {
                Image("window_topHBS")
                    .resizable()
                    .frame(width: 120 * scaleFactor, height: 60 * scaleFactor)
                VStack(spacing: 0) {
                    Text("LEVEL \(coordinatorHBS.currentLevelHBS)")
                        .font(FontManagerHBS.h12)
                        .foregroundStyle(.gray)
                        .scaleEffect(scaleFactor)
                        .minimumScaleFactor(0.5)
                        .shadow(color: .white, radius: 2)
                    Spacer()
                    HStack(spacing: 0) {
                        Text("SCORE")
                            .font(FontManagerHBS.h20)
                            .foregroundStyle(.black)
                            .scaleEffect(scaleFactor)
                            .minimumScaleFactor(0.5)
                            .shadow(color: .white, radius: 2)
                        Spacer()
                        Text("\(coordinatorHBS.scoreHBS)")
                            .font(FontManagerHBS.h20)
                            .foregroundStyle(.purple)
                            .scaleEffect(scaleFactor)
                            .minimumScaleFactor(0.5)
                            .shadow(color: .white, radius: 2)
                    }
                    .frame(width: 70 * scaleFactor)
                }
                .frame(height: 40 * scaleFactor)
            }

            Spacer()

            Button {
                togglePause()
            } label: {
                Image("btn_pauseHBS")
                    .resizable()
                    .frame(width: 60 * scaleFactor, height: 60 * scaleFactor)
            }
        }
        .padding(.horizontal, 20 * scaleFactor)
        .padding(.top, 4 * scaleFactor)
    }

    private func setupScene() {
        isTransitioning = true

        scene = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newScene = GameSceneHBS(level: coordinatorHBS.currentLevelHBS, shopManager: shopManagerHBS)
            newScene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            newScene.scaleMode = .resizeFill
            newScene.gameDelegate = coordinatorHBS
            newScene.gameManager = coordinatorHBS

            scene = newScene
            scene?.isPaused = false
            isPaused = false

            withAnimation(.easeIn(duration: 0.2)) {
                isTransitioning = false
            }
        }
    }

    private func togglePause() {
        if isPaused {
            scene?.isPaused = false
            isPaused = false
        } else {
            scene?.isPaused = true
            isPaused = true
        }
    }

    private func restartLevel() {
        withAnimation(.easeOut(duration: 0.2)) {
            isTransitioning = true
        }

        coordinatorHBS.restartCurrentLevelHBS()

        setupScene()
    }

    private func startNextLevel() {
        withAnimation(.easeOut(duration: 0.2)) {
            isTransitioning = true
        }
        coordinatorHBS.startNextLevelHBS()

        setupScene()
    }

    private var gamePauseMenu: some View {
        GeometryReader { geometry in
            let isIpad = geometry.size.width > 768
            let scaleFactor: CGFloat = isIpad ? 1.5 : 1.0
            let menuScale: CGFloat = isIpad ? 0.8 : 0.7

            ZStack {
                Color.black.opacity(backgroundOpacity)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.easeInOut(duration: 0.5), value: backgroundOpacity)
                    .onTapGesture {
                        closePauseMenu()
                    }

                ZStack {
                    Image("window_avatarsHBS")
                        .resizable()
                        .frame(width: 200 * scaleFactor * menuScale,
                               height: 180 * scaleFactor * menuScale)

                    VStack(spacing: 1 * scaleFactor) {
                        ZStack {
                            Image("header_blueHBS")
                                .resizable()
                                .frame(width: 190 * scaleFactor * menuScale,
                                       height: 24 * scaleFactor * menuScale)
                            Text("pause")
                                .font(FontManagerHBS.h28)
                                .foregroundStyle(.white)
                                .scaleEffect(scaleFactor * menuScale)
                                .minimumScaleFactor(0.5)
                                .shadow(color: .black, radius: 2)
                        }

                        HStack(spacing: 0) {
                            Text("SOUND")
                                .font(FontManagerHBS.h23)
                                .foregroundStyle(.white)
                                .scaleEffect(scaleFactor * menuScale)
                                .minimumScaleFactor(0.5)
                                .shadow(color: .black, radius: 2)
                            Spacer()
                            Toggle(isOn: $musicManagerHBS.isSoundOnHBS) {
                                Text("")
                            }
                            .labelsHidden()
                            .tint(.purple)
                            .scaleEffect(scaleFactor * menuScale)
                        }
                        .frame(width: 160 * scaleFactor * menuScale)

                        HStack(spacing: 0) {
                            Text("VIBRATION")
                                .font(FontManagerHBS.h23)
                                .foregroundStyle(.white)
                                .scaleEffect(scaleFactor * menuScale)
                                .minimumScaleFactor(0.5)
                                .shadow(color: .black, radius: 2)
                            Spacer()
                            Toggle(isOn: $musicManagerHBS.isVibroOnHBS) {
                                Text("")
                            }
                            .labelsHidden()
                            .tint(.purple)
                            .scaleEffect(scaleFactor * menuScale)
                        }
                        .frame(width: 160 * scaleFactor * menuScale)

                        Button {
                            closePauseMenu()
                        } label: {
                            ZStack {
                                Image("btn_purpleLongHBS")
                                    .resizable()
                                    .frame(width: 120 * scaleFactor * menuScale,
                                           height: 45 * scaleFactor * menuScale)
                                Text("RESUME")
                                    .font(FontManagerHBS.h30)
                                    .foregroundStyle(.white)
                                    .scaleEffect(scaleFactor * menuScale)
                                    .minimumScaleFactor(0.6)
                            }
                        }
                    }
                    .frame(width: 200 * scaleFactor * menuScale,
                           height: 160 * scaleFactor * menuScale)
                }
                .scaleEffect(boardScale)
                .opacity(boardOpacity)
                .animation(.easeInOut(duration: 0.5), value: boardOpacity)
                .animation(.easeInOut(duration: 0.5), value: boardScale)
            }
        }
        .onAppear(perform: openBoard)
        .onDisappear(perform: closeBoard)
    }

    private var gameOverMenu: some View {
        GeometryReader { geometry in
            let isIpad = geometry.size.width > 768
            let scaleFactor: CGFloat = isIpad ? 1.5 : 1.0

            ZStack {
                Color.black.opacity(backgroundOpacity)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.easeInOut(duration: 0.5), value: backgroundOpacity)
                VStack(spacing: 0 * scaleFactor) {
                    ZStack {
                        Image("window_endGameHBS")
                            .resizable()
                            .frame(width: 240 * scaleFactor, height: 250 * scaleFactor)

                        VStack(spacing: 12 * scaleFactor) {
                            Spacer()
                            VStack(spacing: 0) {
                                Text("Level\(coordinatorHBS.currentLevelHBS)")
                                    .font(FontManagerHBS.h16)
                                    .foregroundStyle(.gray).opacity(0.5)
                                    .shadow(color: .white, radius: 2)
                                    .scaleEffect(scaleFactor)
                                    .minimumScaleFactor(0.6)
                                Text("failed")
                                    .font(FontManagerHBS.h30)
                                    .foregroundStyle(.white)
                                    .shadow(color: .red, radius: 2)
                                    .scaleEffect(scaleFactor)
                                    .minimumScaleFactor(0.6)
                            }
                            .offset(y: -28 * scaleFactor)
                            ZStack {
                                Image("btn_balanHBSEC")
                                    .resizable()
                                    .frame(width: 144 * scaleFactor, height: 60 * scaleFactor)

                                HStack(spacing: 12 * scaleFactor) {
                                    Image("coinHBS")
                                        .resizable()
                                        .frame(width: 50 * scaleFactor, height: 40 * scaleFactor)
                                    Text("0")
                                        .font(FontManagerHBS.h28)
                                        .foregroundStyle(.white)
                                        .shadow(color: .black, radius: 2)
                                        .scaleEffect(scaleFactor)
                                        .minimumScaleFactor(0.6)
                                        .offset(y: 2 * scaleFactor)
                                }
                            }
                            Spacer()
                            HStack(spacing: 16 * scaleFactor) {
                                Button {
                                    closeGameOverMenu()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        dismiss()
                                    }
                                } label: {
                                    Image("btn_homeHBS")
                                        .resizable()
                                        .frame(width: 60 * scaleFactor, height: 60 * scaleFactor)
                                }
                                Button {
                                    closeGameOverMenu()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        restartLevel()
                                    }
                                } label: {
                                    ZStack {
                                        Image("btn_purpleLongHBS")
                                            .resizable()
                                            .frame(width: 160 * scaleFactor, height: 60 * scaleFactor)
                                        Text("RESTART")
                                            .font(FontManagerHBS.h28)
                                            .foregroundStyle(.white)
                                            .shadow(color: .black, radius: 2)
                                            .scaleEffect(scaleFactor)
                                            .minimumScaleFactor(0.6)
                                    }
                                }
                            }
                        }
                        .frame(height: 400 * scaleFactor)
                    }
                }
                .frame(width: 360 * scaleFactor, height: 392 * scaleFactor)
                .scaleEffect(boardScale)
                .opacity(boardOpacity)
                .animation(.easeInOut(duration: 0.5), value: boardOpacity)
                .animation(.easeInOut(duration: 0.5), value: boardScale)
            }
        }
        .onAppear {
            isPaused = true
            scene?.isPaused = true
            openBoard()
        }
    }

    private var gameWinMenu: some View {
        GeometryReader { geometry in
            let isIpad = geometry.size.width > 768
            let scaleFactor: CGFloat = isIpad ? 1.5 : 1.0

            ZStack {
                Color.black.opacity(backgroundOpacity)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.easeInOut(duration: 0.5), value: backgroundOpacity)
                VStack(spacing: 0 * scaleFactor) {
                    ZStack {
                        Image("window_endGameHBS")
                            .resizable()
                            .frame(width: 240 * scaleFactor, height: 250 * scaleFactor)

                        VStack(spacing: 14 * scaleFactor) {
                            Spacer()
                            VStack(spacing: 0) {
                                Text("Level\(coordinatorHBS.currentLevelHBS)")
                                    .font(FontManagerHBS.h16)
                                    .foregroundStyle(.gray).opacity(0.5)
                                    .shadow(color: .white, radius: 2)
                                    .scaleEffect(scaleFactor)
                                    .minimumScaleFactor(0.6)
                                Text("complete")
                                    .font(FontManagerHBS.h30)
                                    .foregroundStyle(.white)
                                    .shadow(color: .red, radius: 2)
                                    .scaleEffect(scaleFactor)
                                    .minimumScaleFactor(0.6)
                            }
                            .offset(y: -28 * scaleFactor)
                            Text("Score")
                                .font(FontManagerHBS.h20)
                                .foregroundStyle(Color(hex: "60CFFF"))
                                .shadow(color: .white, radius: 2)
                                .scaleEffect(scaleFactor)
                                .minimumScaleFactor(0.6)
                                .offset(y: -28 * scaleFactor)
                            ZStack {
                                Image("blue_bgHBS")
                                    .resizable()
                                    .frame(width: 120 * scaleFactor, height: 40 * scaleFactor)
                                Text("\(coordinatorHBS.scoreHBS)")
                                    .font(FontManagerHBS.h30)
                                    .foregroundStyle(Color(hex: "228AED"))
                                    .shadow(color: .white, radius: 2)
                                    .scaleEffect(scaleFactor)
                                    .minimumScaleFactor(0.6)
                            }
                            .offset(y: -28 * scaleFactor)
                            Text("reward")
                                .font(FontManagerHBS.h20)
                                .foregroundStyle(Color(hex: "60CFFF"))
                                .shadow(color: .white, radius: 2)
                                .scaleEffect(scaleFactor)
                                .minimumScaleFactor(0.6)
                                .offset(y: -28 * scaleFactor)
                            HStack(spacing: 12 * scaleFactor) {
                                Image("coinHBS")
                                    .resizable()
                                    .frame(width: 50 * scaleFactor, height: 40 * scaleFactor)
                                Text("\(randomCoin)")
                                    .font(FontManagerHBS.h28)
                                    .foregroundStyle(.white)
                                    .shadow(color: .black, radius: 2)
                                    .scaleEffect(scaleFactor)
                                    .minimumScaleFactor(0.6)
                                    .offset(y: 2 * scaleFactor)
                            }
                            .offset(y: -28 * scaleFactor)
                            HStack(spacing: 16 * scaleFactor) {
                                Button {
                                    closeGameOverMenu()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        dismiss()
                                    }
                                } label: {
                                    Image("btn_homeHBS")
                                        .resizable()
                                        .frame(width: 60 * scaleFactor, height: 60 * scaleFactor)
                                }
                                Button {
                                    closeGameOverMenu()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        startNextLevel()
                                    }
                                } label: {
                                    ZStack {
                                        Image("btn_purpleLongHBS")
                                            .resizable()
                                            .frame(width: 160 * scaleFactor, height: 60 * scaleFactor)
                                        Text("NEXT LEVEL")
                                            .font(FontManagerHBS.h28)
                                            .foregroundStyle(.white)
                                            .shadow(color: .black, radius: 2)
                                            .scaleEffect(scaleFactor)
                                            .minimumScaleFactor(0.6)
                                    }
                                }
                            }
                        }
                        .frame(height: 400 * scaleFactor)
                    }
                }
                .frame(width: 360 * scaleFactor, height: 392 * scaleFactor)
                .scaleEffect(boardScale)
                .opacity(boardOpacity)
                .animation(.easeInOut(duration: 0.5), value: boardOpacity)
                .animation(.easeInOut(duration: 0.5), value: boardScale)
            }
            .transition(.opacity)
        }
        .onAppear {
            isPaused = true
            scene?.isPaused = true
            openBoard()
        }
    }

    private func awardCoin() {
        randomCoin = Int.random(in: 50 ... 100)
        UserDefaults.standard.set(
            UserDefaults.standard.integer(forKey: "coinsHBS") + randomCoin,
            forKey: "coinsHBS"
        )
    }

    private func showNewHighScore() {
        withAnimation(.spring()) {}
    }

    private func openBoard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.easeInOut(duration: 0.5)) {
                boardScale = 1.0
                boardOpacity = 1.0
                backgroundOpacity = 0.68
            }
        }
    }

    private func closeBoard() {
        withAnimation(.easeInOut(duration: 0.5)) {
            boardScale = 0.1
            boardOpacity = 0.0
            backgroundOpacity = 0.0
        }
    }

    private func closeGameOverMenu() {
        withAnimation(.easeIn(duration: 0.3)) {
            backgroundOpacity = 0
            boardOpacity = 0
            boardScale = 0.1
        }
    }

    private func closePauseMenu() {
        withAnimation(.easeInOut(duration: 0.5)) {
            boardScale = 0.1
            boardOpacity = 0.0
            backgroundOpacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            togglePause()
        }
    }

    private func livesIndicator(scaleFactor: CGFloat) -> some View {
        HStack(spacing: 2 * scaleFactor) {
            ForEach(0 ..< 3) { index in
                Image(index < coordinatorHBS.livesHBS ? "heartHBS" : "empty")
                    .resizable()
                    .frame(width: 16 * scaleFactor, height: 16 * scaleFactor)
            }
        }
    }
}

struct GameViewHBS_Previews: PreviewProvider {
    static var previews: some View {
        GameViewHBS()
            .environmentObject(GameManagerHBS())
            .environmentObject(ShopManagerHBS())
    }
}

import SwiftUI
@preconcurrency import WebKit

struct MenuVviewHBS: View {
    @State private var storedURLHBS: String? = UserDefaults.standard.string(forKey: "StoredURLHBS")
    @State private var webEngineHBS = WKWebView()
    @State private var isLoadingHBS = false
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationBarHBS(webEngineHBS: webEngineHBS)
            
            ZStack {
                WebContentHBS(
                    webEngineHBS: $webEngineHBS,
                    storedURLHBS: $storedURLHBS,
                    isLoadingHBS: $isLoadingHBS
                )
                .edgesIgnoringSafeArea(.bottom)
                
                if isLoadingHBS {
                    LoaderViewHBS()
                }
            }
        }
        .onAppear {
            configureOrientationHBS()
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func configureOrientationHBS() {
        if let delegate = HyperBallNotificationWizard.shared {
            delegate.screenOrientation = .allButUpsideDown
            delegate.updateScreenOrientation()
        }
    }
}

struct NavigationBarHBS: View {
    let webEngineHBS: WKWebView
    
    var body: some View {
        HStack {
            BackButtonHBS(webEngineHBS: webEngineHBS)
            Spacer()
            HomeButtonHBS(webEngineHBS: webEngineHBS)
        }
        .padding()
        .background(Color.black)
    }
}

struct BackButtonHBS: View {
    let webEngineHBS: WKWebView
    
    var body: some View {
        Button(action: handleBackHBS) {
            Image(systemName: "arrow.left")
                .font(.title)
                .foregroundColor(.white)
        }
    }
    
    private func handleBackHBS() {
        guard webEngineHBS.canGoBack else { return }
        webEngineHBS.goBack()
    }
}

struct HomeButtonHBS: View {
    let webEngineHBS: WKWebView
    
    var body: some View {
        Button(action: handleHomeHBS) {
            Image(systemName: "house")
                .font(.title)
                .foregroundColor(.white)
        }
    }
    
    private func handleHomeHBS() {
        guard let storedURL = UserDefaults.standard.string(forKey: "StoredURLHBS"),
              let url = URL(string: storedURL) else { return }
        webEngineHBS.load(URLRequest(url: url))
    }
}

struct LoaderViewHBS: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.7))
    }
}

struct WebContentHBS: UIViewRepresentable {
    @Binding var webEngineHBS: WKWebView
    @Binding var storedURLHBS: String?
    @Binding var isLoadingHBS: Bool
    
    
    func makeCoordinator() -> WebNavigatorHBS {
        WebNavigatorHBS(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = configureWebViewHBS()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        DispatchQueue.main.async {
            self.webEngineHBS = webView
            self.loadInitialPageHBS()
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func configureWebViewHBS() -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
        webView.scrollView.backgroundColor = .black
        webView.scrollView.subviews.forEach { $0.backgroundColor = .black }
        
        return webView
    }
    
    private func loadInitialPageHBS() {
        let targetURL = storedURLHBS ?? ""
        guard let url = URL(string: targetURL) else { return }
        webEngineHBS.load(URLRequest(url: url))
    }
}

class WebNavigatorHBS: NSObject, WKNavigationDelegate, WKUIDelegate {
    private let parent: WebContentHBS
    
    init(_ parent: WebContentHBS) {
        self.parent = parent
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.parent.isLoadingHBS = true
        }
    }
    
    func webView(_ webView: WKWebView, didFinish: WKNavigation!) {
        DispatchQueue.main.async {
            self.parent.isLoadingHBS = false
        }
        
        guard let currentURL = webView.url?.absoluteString else { return }
        let savedURL = UserDefaults.standard.string(forKey: "StoredURLHBS") ?? ""
        
        if savedURL.isEmpty || savedURL.contains("redirect") || savedURL.contains("reboundrampage.info") {
            UserDefaults.standard.set(currentURL, forKey: "StoredURLHBS")
        }
    }
    
    // Обработка дочерних окон
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let targetURL = navigationAction.request.url {
            webView.load(URLRequest(url: targetURL))
        }
        return nil
    }
    
    // Обработка закрытия окон
    func webViewDidClose(_ webView: WKWebView) {
        // Дополнительная логика при закрытии окна, если нужна
    }
    
    // Обработка JavaScript alert
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
    
    // Обработка JavaScript confirm
    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(true)
    }
    
    // Обработка JavaScript prompt
    func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (String?) -> Void
    ) {
        completionHandler(defaultText)
    }
}

struct MenuVviewHBS_Previews: PreviewProvider {
    static var previews: some View {
        MenuVviewHBS()
    }
}
