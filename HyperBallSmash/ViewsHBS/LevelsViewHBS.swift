import SwiftUI

struct LevelsViewHBS: View {
    @EnvironmentObject var gameManagerHBS: GameManagerHBS
    @EnvironmentObject var shopManagerHBS: ShopManagerHBS
    @Environment(\.dismiss) var closeHBS
    @State private var isGameActiveHBS = false
    @State private var isContentVisibleHBS = false
    @State private var levelsAnimationHBS = false

    var body: some View {
        GeometryReader { geometry in
            let isIpadHBS = geometry.size.width > 768
            let scaleFactorHBS: CGFloat = isIpadHBS ? 1.5 : 1.0

            ZStack {
                Image("bg_mainHBS")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 20 * scaleFactorHBS) {
                    HStack(spacing: 0) {
                        Button {
                            closeHBS()
                        } label: {
                            Image("btn_homeHBS")
                                .resizable()
                                .frame(width: 60 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                                .opacity(isContentVisibleHBS ? 1 : 0)
                                .offset(x: isContentVisibleHBS ? 0 : -200 * scaleFactorHBS)
                                .rotation3DEffect(
                                    .degrees(isContentVisibleHBS ? 0 : 180),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        }
                        Spacer()
                        ZStack {
                            Image("roundHBS")
                                .resizable()
                                .frame(width: 140 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                            Text("levels")
                                .font(FontManagerHBS.h30)
                                .foregroundStyle(.white)
                                .shadow(color: .black, radius: 4)
                                .scaleEffect(scaleFactorHBS)
                        }
                        .opacity(isContentVisibleHBS ? 1 : 0)
                        .scaleEffect(isContentVisibleHBS ? 1 : 0.3)
                        .rotation3DEffect(
                            .degrees(isContentVisibleHBS ? 0 : 360),
                            axis: (x: 1, y: 1, z: 1)
                        )
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
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isContentVisibleHBS)

                    Spacer()
                    ScrollView {
                        VStack(spacing: 70 * scaleFactorHBS) {
                            ForEach(getDiamondRowsHBS(), id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(row.indices, id: \.self) { index in
                                        if index > 0 {
                                            Image("ball_splHBS")
                                                .resizable()
                                                .frame(width: 20 * scaleFactorHBS, height: 20 * scaleFactorHBS)
                                                .opacity(levelsAnimationHBS ? 1 : 0)
                                                .rotationEffect(.degrees(levelsAnimationHBS ? 360 : 0))
                                                .animation(
                                                    .spring(response: 0.6, dampingFraction: 0.7)
                                                    .delay(Double(row.first ?? 0) * 0.1 + Double(index) * 0.05),
                                                    value: levelsAnimationHBS
                                                )
                                                .padding(.horizontal, 15 * scaleFactorHBS)
                                        }
                                        
                                        LevelButtonHBS(
                                            levelHBS: row[index],
                                            scaleFactorHBS: scaleFactorHBS,
                                            isVisibleHBS: $levelsAnimationHBS,
                                            isGameActiveHBS: $isGameActiveHBS
                                        )
                                        .environmentObject(gameManagerHBS)
                                    }
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    Spacer()
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isContentVisibleHBS = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    levelsAnimationHBS = true
                }
            }
            .onDisappear {
                isContentVisibleHBS = false
                levelsAnimationHBS = false
            }
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $isGameActiveHBS) {
                GameViewHBS().environmentObject(gameManagerHBS)
            }
        }
    }

    private func getDiamondRowsHBS() -> [[Int]] {
        return [
            [1, 2, 3],
            [4, 5,],
            [6, 7, 8],
            [9, 10],
            [11, 12, 13],
            [14, 15],
            [16, 17, 18],
            [19, 20]
        ]
    }
}

struct LevelButtonHBS: View {
    @EnvironmentObject var gameManagerHBS: GameManagerHBS
    let levelHBS: Int
    let scaleFactorHBS: CGFloat
    @Binding var isVisibleHBS: Bool
    @Binding var isGameActiveHBS: Bool
    @State private var levelOffsetHBS: CGFloat = 500

    var body: some View {
        Button(action: {
            MusicManagerHBS.shared.triggerVibrationHBS()
            if gameManagerHBS.levelStatesHBS[levelHBS] != .notStarted {
                gameManagerHBS.currentLevelHBS = levelHBS
                isGameActiveHBS = true
            }
        }) {
            ZStack {
                Image("lvlHBS")
                    .resizable()
                    .frame(width: 82 * scaleFactorHBS, height: 82 * scaleFactorHBS)
                    .minimumScaleFactor(0.5)
                    .opacity(isVisibleHBS ? 1 : 0)
                    .scaleEffect(isVisibleHBS ? 1 : 0.1)
                    .rotation3DEffect(
                        .degrees(isVisibleHBS ? 0 : 360),
                        axis: (x: 1, y: 1, z: 0)
                    )
                    .offset(y: isVisibleHBS ? 0 : levelOffsetHBS)
                    .animation(
                        .spring(
                            response: 0.8,
                            dampingFraction: 0.6,
                            blendDuration: 0.8
                        )
                        .delay(Double(levelHBS) * 0.1),
                        value: isVisibleHBS
                    )
                    .grayscale(gameManagerHBS.levelStatesHBS[levelHBS] == .notStarted ? 1 : 0)

                Text("\(levelHBS)")
                    .font(FontManagerHBS.h48)
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 2, x: 2, y: 2)
                    .opacity(isVisibleHBS ? 1 : 0)
                    .scaleEffect(isVisibleHBS ? 1 : 0.1)
                    .rotation3DEffect(
                        .degrees(isVisibleHBS ? 0 : -360),
                        axis: (x: 1, y: 0, z: 1)
                    )
                    .animation(
                        .spring(
                            response: 0.8,
                            dampingFraction: 0.7,
                            blendDuration: 0.8
                        )
                        .delay(Double(levelHBS) * 0.1),
                        value: isVisibleHBS
                    )
                    .scaleEffect(scaleFactorHBS)
                    .minimumScaleFactor(0.6)
            }
        }
        .disabled(gameManagerHBS.levelStatesHBS[levelHBS] == .notStarted)
    }
}

struct LevelsViewHBS_Previews: PreviewProvider {
    static var previews: some View {
        LevelsViewHBS()
            .environmentObject(GameManagerHBS())
            .environmentObject(ShopManagerHBS())
    }
}
