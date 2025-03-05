import SwiftUI

struct OnboardingViewHBS: View {
    var onFinishHBS: () -> Void
    @EnvironmentObject var shopManagerHBS: ShopManagerHBS
    @Environment(\.dismiss) private var closeHBS
    @State private var selectedAvatarHBS: String = UserDefaults.standard.string(forKey: "selAvHBS") ?? "av2HBS"
    @State private var currentPageHBS = 1
    @State private var isContentVisibleHBS = false

    var body: some View {
        GeometryReader { geometry in
            let screenWidthHBS = geometry.size.width
            let isIpadHBS = screenWidthHBS > 768
            let scaleFactorHBS: CGFloat = isIpadHBS ? 1.5 : 1.0

            ZStack {
                Image("bg_onbHBS")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack {
                    HStack(spacing: 0) {
                        Button {
                            closeHBS()
                        } label: {
                            Image("btn_homeHBS")
                                .resizable()
                                .frame(width: 60 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                                .opacity(UserDefaults.standard.bool(forKey: "firstLaunchGameHBS") ? 1 : 0)
                        }
                        Spacer()
                        ZStack {
                            Image("roundHBS")
                                .resizable()
                                .frame(width: 140 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                                .opacity(UserDefaults.standard.bool(forKey: "firstLaunchGameHBS") ? 0 : 1)
                            Text("Welcome")
                                .font(FontManagerHBS.h30)
                                .foregroundStyle(.white)
                                .shadow(color: Color(hex: "#733F00"), radius: 4)
                                .scaleEffect(scaleFactorHBS)
                                .minimumScaleFactor(0.4)
                                .opacity(UserDefaults.standard.bool(forKey: "firstLaunchGameHBS") ? 0 : 1)
                        }

                        Spacer()
                        Button {
                            closeHBS()
                        } label: {
                            Image("btn_homeHBS")
                                .resizable()
                                .frame(width: 60 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                                .hidden()
                        }
                    }
                    .padding(.horizontal, 20 * scaleFactorHBS)
                    .padding(.top, 4 * scaleFactorHBS)
                    Spacer()
                    ZStack {
                        if currentPageHBS == 1 {
                            page1ViewHBS(scaleFactorHBS: scaleFactorHBS)
                                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        } else if currentPageHBS == 2 {
                            page2ViewHBS(scaleFactorHBS: scaleFactorHBS)
                                .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .move(edge: .trailing).combined(with: .opacity)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.5), value: currentPageHBS)
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    isContentVisibleHBS = true
                }
            }
        }
    }

    @ViewBuilder
    private func page1ViewHBS(scaleFactorHBS: CGFloat) -> some View {
        VStack(spacing: 0 * scaleFactorHBS) {
            Spacer()
            VStack(spacing: 20 * scaleFactorHBS) {
                Image("onb_rules1")
                    .resizable()
                    .scaledToFit()
                    .transition(.opacity)
                    .opacity(isContentVisibleHBS ? 1 : 0)
                    .animation(.easeIn(duration: 0.5), value: isContentVisibleHBS)
            }
            Spacer()
            Button {
                withAnimation {
                    currentPageHBS = 2
                }
            } label: {
                ZStack {
                    Image("btn_purpleHBS")
                        .resizable()
                        .frame(width: 120 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                    Text("NEXT")
                        .font(FontManagerHBS.h30)
                        .foregroundStyle(.white)
                        .scaleEffect(scaleFactorHBS)
                        .minimumScaleFactor(0.5)
                        .shadow(color: .black, radius: 2)
                }
                .transition(.scale)
            }
        }
        .opacity(isContentVisibleHBS ? 1 : 0)
        .animation(.easeIn(duration: 0.5), value: isContentVisibleHBS)
    }

    @ViewBuilder
    private func page2ViewHBS(scaleFactorHBS: CGFloat) -> some View {
        VStack(spacing: 10 * scaleFactorHBS) {
            Image("logo_gameHBS")
                .resizable()
                .scaledToFit()
                .transition(.opacity)
                .opacity(isContentVisibleHBS ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: isContentVisibleHBS)
            Spacer()
            ZStack {
                Image("window_avatarsHBS")
                    .resizable()
                    .frame(width: 360 * scaleFactorHBS, height: 180 * scaleFactorHBS)
                VStack(spacing: 0 * scaleFactorHBS) {
                    ZStack {
                        Image("header_blueHBS")
                        Text("Choose Your Hero")
                            .font(FontManagerHBS.h25)
                            .foregroundStyle(.white)
                            .scaleEffect(scaleFactorHBS)
                            .minimumScaleFactor(0.5)
                            .shadow(color: .black, radius: 2)
                    }
                    Spacer()
                    HStack(spacing: 0 * scaleFactorHBS) {
                        avatarButtonHBS(imageNameHBS: "av1HBS", scaleFactorHBS: scaleFactorHBS)
                        Spacer()
                        avatarButtonHBS(imageNameHBS: "av2HBS", scaleFactorHBS: scaleFactorHBS)
                        Spacer()
                        avatarButtonHBS(imageNameHBS: "av3HBS", scaleFactorHBS: scaleFactorHBS)
                    }
                }
                .frame(width: 280 * scaleFactorHBS, height: 130 * scaleFactorHBS)
            }
            Spacer()
            Button(action: {
                saveDataHBS()
                onFinishHBS()
                closeHBS()
            }) {
                ZStack {
                    Image("btn_purpleLongHBS")
                        .resizable()
                        .frame(width: 180 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                    Text("Let's Go!")
                        .font(FontManagerHBS.h30)
                        .foregroundStyle(.white)
                        .scaleEffect(scaleFactorHBS)
                        .minimumScaleFactor(0.5)
                        .shadow(color: .black, radius: 2)
                }
                .transition(.scale)
            }
        }
        .opacity(isContentVisibleHBS ? 1 : 0)
        .animation(.easeIn(duration: 0.5), value: isContentVisibleHBS)
    }

    @ViewBuilder
    private func avatarButtonHBS(imageNameHBS: String, scaleFactorHBS: CGFloat) -> some View {
        Button(action: {
            selectedAvatarHBS = imageNameHBS
        }) {
            Image(imageNameHBS)
                .resizable()
                .frame(width: 70, height: 70)
                .overlay(
                    Image("checkmarkHBS")
                        .resizable()
                        .frame(width: 30, height: 22)
                        .offset(y: 32)
                        .opacity(selectedAvatarHBS == imageNameHBS ? 1 : 0)
                )
                .scaleEffect(scaleFactorHBS)
                .transition(.move(edge: .bottom))
        }
    }

    private func saveDataHBS() {
        UserDefaults.standard.set(selectedAvatarHBS, forKey: "selAvHBS")
        UserDefaults.standard.set(true, forKey: "firstLaunchGameHBS")
    }
}

struct OnboardingViewHBS_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingViewHBS(onFinishHBS: {})
    }
}
