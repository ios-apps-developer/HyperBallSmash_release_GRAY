import SwiftUI

struct MenuViewHBS: View {
    @ObservedObject var musicManagerHBS = MusicManagerHBS.shared
    @State private var showSettingsHBS = false
    @State private var settingsScaleHBS: CGFloat = 0.1
    @State private var settingsOpacityHBS: Double = 0.0
    @State private var logoOffsetHBS: CGFloat = -300
    @State private var logoOpacityHBS: Double = 0.0
    @State private var backgroundOpacityHBS: Double = 0.0
    @State private var isRotatedHBS: Bool = false
    @State private var showButtonsHBS = false
    @State private var pulseScaleHBS: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            let isIpadHBS = geometry.size.width > 768
            let scaleFactorHBS: CGFloat = isIpadHBS ? 1.5 : 1.0

            NavigationStack {
                ZStack {
                    Image("bg_menuHBS")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack(spacing: 24 * scaleFactorHBS) {
                        Spacer()
                        Image("logo_gameHBS")
                            .resizable()
                            .scaledToFit()
                            .offset(y: -logoOffsetHBS)
                            .opacity(logoOpacityHBS)
                        Spacer()
                        VStack(spacing: 20 * scaleFactorHBS) {
                            NavigationLink(destination: LevelsViewHBS()) {
                                ZStack {
                                    Image("btn_purpleLongHBS")
                                        .resizable()
                                        .frame(width: 220 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                                        .scaleEffect(scaleFactorHBS)
                                    Text("PLAY")
                                        .font(FontManagerHBS.h40)
                                        .foregroundStyle(.white)
                                        .scaleEffect(scaleFactorHBS)
                                        .minimumScaleFactor(0.5)
                                        .shadow(color: .black, radius: 2)
                                }
                                .scaleEffect(pulseScaleHBS)
                                .offset(y: logoOffsetHBS)
                                .opacity(logoOpacityHBS)
                            }
                            HStack(spacing: 0) {
                                NavigationLink(destination: OnboardingViewHBS{}) {
                                    Image("btn_onbHBS")
                                        .resizable()
                                        .frame(width: 60 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                                        .offset(x: logoOffsetHBS)
                                        .opacity(logoOpacityHBS)
                                }
                                Spacer()
                                Button {
                                    openSettingsHBS()
                                } label: {
                                    Image("btn_settingsHBS")
                                        .resizable()
                                        .frame(width: 60 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                                        .offset(y: -logoOffsetHBS)
                                        .opacity(logoOpacityHBS)
                                }
                                Spacer()
                                NavigationLink(destination: ShopViewHBS()) {
                                    Image("btn_shopHBS")
                                        .resizable()
                                        .frame(width: 60 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                                        .offset(x: -logoOffsetHBS)
                                        .opacity(logoOpacityHBS)
                                }
                            }
                            .frame(width: 220 * scaleFactorHBS)
                        }
                        Spacer()
                    }
                }
            }
            if showSettingsHBS {
                ZStack {
                    Color.black.opacity(backgroundOpacityHBS)
                        .edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .animation(.easeInOut(duration: 0.5), value: backgroundOpacityHBS)
                        .onTapGesture {
                            closeSettingsHBS()
                        }
                    
                    ZStack {
                        Image("window_avatarsHBS")
                            .resizable()
                            .frame(width: 252 * scaleFactorHBS, height: 228 * scaleFactorHBS)
                        VStack(spacing: 16 * scaleFactorHBS) {
                            ZStack {
                                Image("header_blueHBS")
                                    .resizable()
                                    .frame(width: 242 * scaleFactorHBS, height: 30 * scaleFactorHBS)
                                Text("SETTINGS")
                                    .font(FontManagerHBS.h28)
                                    .foregroundStyle(.white)
                                    .scaleEffect(scaleFactorHBS)
                                    .minimumScaleFactor(0.5)
                                    .shadow(color: .black, radius: 2)
                            }
                            HStack(spacing: 0) {
                                Text("SOUND")
                                    .font(FontManagerHBS.h23)
                                    .foregroundStyle(.white)
                                    .scaleEffect(scaleFactorHBS)
                                    .minimumScaleFactor(0.5)
                                    .shadow(color: .black, radius: 2)
                                Spacer()
                                Toggle(isOn: $musicManagerHBS.isSoundOnHBS) {
                                    Text("")
                                }
                                .labelsHidden()
                                .tint(.purple)
                                .scaleEffect(scaleFactorHBS)
                            }
                            .frame(width: 202 * scaleFactorHBS)
                            HStack(spacing: 0) {
                                Text("VIBRATION")
                                    .font(FontManagerHBS.h23)
                                    .foregroundStyle(.white)
                                    .scaleEffect(scaleFactorHBS)
                                    .minimumScaleFactor(0.5)
                                    .shadow(color: .black, radius: 2)
                                Spacer()
                                Toggle(isOn: $musicManagerHBS.isVibroOnHBS) {
                                    Text("")
                                }
                                .labelsHidden()
                                .tint(.purple)
                                .scaleEffect(scaleFactorHBS)
                            }
                            .frame(width: 202 * scaleFactorHBS)
                            
                            Button { closeSettingsHBS() } label: {
                                ZStack {
                                    Image("btn_purpleHBS")
                                        .resizable()
                                        .frame(width: 120 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                                    Text("CLOSE")
                                        .font(FontManagerHBS.h30)
                                        .foregroundStyle(.white)
                                        .scaleEffect(scaleFactorHBS)
                                        .minimumScaleFactor(0.5)
                                        .shadow(color: .black, radius: 2)
                                }
                            }
                        }
                        .frame(width: 253 * scaleFactorHBS, height: 200 * scaleFactorHBS)
                    }
                    .scaleEffect(settingsScaleHBS)
                    .opacity(settingsOpacityHBS)
                    .animation(.easeInOut(duration: 0.5), value: settingsOpacityHBS)
                    .animation(.easeInOut(duration: 0.5), value: settingsScaleHBS)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.8)) {
                    self.logoOpacityHBS = 1.0
                    self.logoOffsetHBS = 0
                }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseScaleHBS = 1.15
                }
            }
        }
    }

    func openSettingsHBS() {
        showSettingsHBS = true
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            settingsScaleHBS = 1.0
            settingsOpacityHBS = 1.0
            backgroundOpacityHBS = 0.4
        }
    }

    func closeSettingsHBS() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            settingsScaleHBS = 0.1
            settingsOpacityHBS = 0.0
            backgroundOpacityHBS = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSettingsHBS = false
        }
    }
}

struct MenuViewHBS_Previews: PreviewProvider {
    static var previews: some View {
        MenuViewHBS()
    }
}
