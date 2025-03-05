import SwiftUI

struct BallHBS: Identifiable {
    let id: String
    let imageNameHBS: String
    let priceHBS: Int
}

private struct AlertActionKey: EnvironmentKey {
    static let defaultValue: (String, String) -> Void = { _, _ in }
}

extension EnvironmentValues {
    var showAlertAction: (String, String) -> Void {
        get { self[AlertActionKey.self] }
        set { self[AlertActionKey.self] = newValue }
    }
}

struct ShopViewHBS: View {
    @EnvironmentObject var shopManagerHBS: ShopManagerHBS
    @Environment(\.dismiss) private var dismissHBS

    @State private var isContentVisibleHBS = false
    @State private var showAlertHBS = false
    @State private var alertScaleHBS: CGFloat = 0.1
    @State private var alertOpacityHBS = 0.0
    @State private var backgroundOpacityHBS = 0.0
    @State private var alertMessageHBS = ""
    @State private var alertTitleHBS = ""
    @State private var cardsAnimationHBS = false

    let ballsHBS: [BallHBS] = [
        BallHBS(id: "ball1HBS", imageNameHBS: "ball1HBS", priceHBS: 0),
        BallHBS(id: "ball2HBS", imageNameHBS: "ball2HBS", priceHBS: 100),
        BallHBS(id: "ball3HBS", imageNameHBS: "ball3HBS", priceHBS: 100),
        BallHBS(id: "ball4HBS", imageNameHBS: "ball4HBS", priceHBS: 100),
        BallHBS(id: "ball5HBS", imageNameHBS: "ball5HBS", priceHBS: 100),
        BallHBS(id: "ball6HBS", imageNameHBS: "ball6HBS", priceHBS: 100),
        BallHBS(id: "ball7HBS", imageNameHBS: "ball7HBS", priceHBS: 100),
        BallHBS(id: "ball8HBS", imageNameHBS: "ball8HBS", priceHBS: 100)
    ]

    var body: some View {
        GeometryReader { geometryHBS in
            let isIpadHBS = geometryHBS.size.width > 768
            let scaleFactorHBS: CGFloat = isIpadHBS ? 1.5 : 1.0
            let gridColumnsHBS = isIpadHBS ? 3 : 2
            
            ZStack {
                Image("bg_mainHBS")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                VStack(spacing: 24 * scaleFactorHBS) {
                    HStack(spacing: 0) {
                        Button {
                            dismissHBS()
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
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isContentVisibleHBS)
                        }
                        Spacer()
                        ZStack {
                            Image("roundHBS")
                                .resizable()
                                .frame(width: 140 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                            Text("SHOP")
                                .font(FontManagerHBS.h30)
                                .foregroundStyle(.white)
                                .shadow(color: .black, radius: 4)
                                .scaleEffect(scaleFactorHBS)
                        }
                        .opacity(isContentVisibleHBS ? 1 : 0)
                        .scaleEffect(isContentVisibleHBS ? 1 : 0.3)
                        .rotation3DEffect(
                            .degrees(isContentVisibleHBS ? 0 : 180),
                            axis: (x: 1, y: 0, z: 0)
                        )
                        .animation(.spring(response: 0.7, dampingFraction: 0.7), value: isContentVisibleHBS)
                        Spacer()
                        HStack(spacing: 10 * scaleFactorHBS) {
                            Image("coinHBS")
                                .resizable()
                                .frame(width: 40 * scaleFactorHBS, height: 29 * scaleFactorHBS)
                            Text("\(shopManagerHBS.balanceCoinHBS)")
                                .font(FontManagerHBS.h30)
                                .foregroundStyle(.white)
                                .shadow(color: .black, radius: 4)
                                .scaleEffect(scaleFactorHBS)
                        }
                        .opacity(isContentVisibleHBS ? 1 : 0)
                        .offset(x: isContentVisibleHBS ? 0 : 200 * scaleFactorHBS)
                        .rotation3DEffect(
                            .degrees(isContentVisibleHBS ? 0 : -180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isContentVisibleHBS)
                    }
                    .padding(.horizontal, 20 * scaleFactorHBS)
                    .padding(.top, 4 * scaleFactorHBS)
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16 * scaleFactorHBS), count: gridColumnsHBS), spacing: 16 * scaleFactorHBS) {
                            ForEach(Array(ballsHBS.enumerated()), id: \.element.id) { index, ballHBS in
                                BallViewHBS(ballHBS: ballHBS)
                                    .frame(width: 160 * scaleFactorHBS, height: 160 * scaleFactorHBS)
                                    .environment(\.showAlertAction, showAlertHBS)
                                    .opacity(cardsAnimationHBS ? 1 : 0)
                                    .scaleEffect(cardsAnimationHBS ? 1 : 0.1)
                                    .rotation3DEffect(
                                        .degrees(cardsAnimationHBS ? 0 : 360),
                                        axis: (x: 1, y: 1, z: 0)
                                    )
                                    .offset(y: cardsAnimationHBS ? 0 : 300)
                                    .animation(
                                        .spring(
                                            response: 0.7,
                                            dampingFraction: 0.6,
                                            blendDuration: 0.1
                                        )
                                        .delay(Double(index) * 0.1),
                                        value: cardsAnimationHBS
                                    )
                            }
                        }
                        .padding(.horizontal, 20 * scaleFactorHBS)
                        .padding(.bottom, 20 * scaleFactorHBS)
                    }
                }

                if showAlertHBS {
                    ZStack {
                        Color.black.opacity(backgroundOpacityHBS)
                            .edgesIgnoringSafeArea(.all)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .animation(.easeInOut(duration: 0.5), value: backgroundOpacityHBS)
                            .onTapGesture {
                                closeAlertHBS()
                            }
                        
                        ZStack {
                            Image("window_avatarsHBS")
                                .resizable()
                                .frame(width: 252 * scaleFactorHBS, height: 228 * scaleFactorHBS)
                            
                            VStack(spacing: 0 * scaleFactorHBS) {
                                ZStack {
                                    Image("header_blueHBS")
                                        .resizable()
                                        .frame(width: 242 * scaleFactorHBS, height: 30 * scaleFactorHBS)
                                    Text(alertTitleHBS)
                                        .font(FontManagerHBS.h28)
                                        .foregroundStyle(.white)
                                        .scaleEffect(scaleFactorHBS)
                                        .minimumScaleFactor(0.5)
                                        .shadow(color: .black, radius: 2)
                                }
                                Spacer()
                                Text(alertMessageHBS)
                                    .font(FontManagerHBS.h23)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .scaleEffect(scaleFactorHBS)
                                    .minimumScaleFactor(0.5)
                                    .shadow(color: .black, radius: 2)
                                    .padding(.horizontal, 20 * scaleFactorHBS)
                                Spacer()
                                Button { closeAlertHBS() } label: {
                                    ZStack {
                                        Image("btn_purpleHBS")
                                            .resizable()
                                            .frame(width: 120 * scaleFactorHBS, height: 60 * scaleFactorHBS)
                                        Text("OK")
                                            .font(FontManagerHBS.h30)
                                            .foregroundStyle(.white)
                                            .scaleEffect(scaleFactorHBS)
                                            .minimumScaleFactor(0.5)
                                            .shadow(color: .black, radius: 2)
                                    }
                                }
                            }
                            .frame(width: 252 * scaleFactorHBS, height: 200 * scaleFactorHBS)
                        }
                        .scaleEffect(alertScaleHBS)
                        .opacity(alertOpacityHBS)
                    }
                }
            }
            .onAppear {
                withAnimation {
                    isContentVisibleHBS = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    cardsAnimationHBS = true
                }
            }
            .onDisappear {
                isContentVisibleHBS = false
                cardsAnimationHBS = false
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    func showAlertHBS(title: String, message: String) {
        alertTitleHBS = title
        alertMessageHBS = message
        showAlertHBS = true
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            alertScaleHBS = 1.0
            alertOpacityHBS = 1.0
            backgroundOpacityHBS = 0.4
        }
    }

    func closeAlertHBS() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            alertScaleHBS = 0.1
            alertOpacityHBS = 0.0
            backgroundOpacityHBS = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showAlertHBS = false
        }
    }
}

struct BallViewHBS: View {
    @EnvironmentObject var shopManagerHBS: ShopManagerHBS
    @Environment(\.showAlertAction) var showAlert
    let ballHBS: BallHBS

    var body: some View {
        GeometryReader { geometryHBS in
            let isIpadHBS = geometryHBS.size.width > 768
            let scaleFactorHBS: CGFloat = isIpadHBS ? 1.5 : 1.0
            
            ZStack {
                Image("card_shopHBS")
                    .resizable()
                    .frame(width: 160 * scaleFactorHBS, height: 160 * scaleFactorHBS)
                VStack(spacing: 16 * scaleFactorHBS) {
                        Image(ballHBS.imageNameHBS)
                            .resizable()
                            .frame(width: 80 * scaleFactorHBS, height: 80 * scaleFactorHBS)
                        
                    
                    if shopManagerHBS.isOwnedBallHBS(imageName: ballHBS.id) {
                        Button {
                            shopManagerHBS.selectBallHBS(imageName: ballHBS.id)
                        } label: {
                            ZStack {
                                Image(ballHBS.id == shopManagerHBS.selectedBallHBS ? "btn_selectedHBS" : "btn_selectHBS")
                                    .resizable()
                                    .frame(width: 140 * scaleFactorHBS, height: 40 * scaleFactorHBS)
                                Text(ballHBS.id == shopManagerHBS.selectedBallHBS ? "selected" : "select")
                                    .font(FontManagerHBS.h25)
                                    .foregroundStyle(.white)
                                    .offset(y: -2 * scaleFactorHBS)
                                    .shadow(color: .black, radius: 4)
                                    .scaleEffect(scaleFactorHBS)
                                    .minimumScaleFactor(0.4)
                            }
                        }
                    } else {
                        Button {
                            if shopManagerHBS.canAffordBallHBS(price: ballHBS.priceHBS) {
                                shopManagerHBS.purchaseBallHBS(imageName: ballHBS.id, price: ballHBS.priceHBS)
                                showAlert("congratulations!", "You have successfully \npurchased this ball!")
                            } else {
                                let coinsNeeded = ballHBS.priceHBS - shopManagerHBS.balanceCoinHBS
                                showAlert("NOT ENOUGH COINS", "You need \(coinsNeeded) more \ncoins to buy this ball")
                            }
                        } label: {
                            ZStack {
                                Image("btn_buyHBS")
                                    .resizable()
                                    .frame(width: 140 * scaleFactorHBS, height: 40 * scaleFactorHBS)
                                HStack(spacing: 12 * scaleFactorHBS) {
                                    Image("coinHBS")
                                        .resizable()
                                        .frame(width: 30 * scaleFactorHBS, height: 22 * scaleFactorHBS)
                                    Text("100")
                                        .font(FontManagerHBS.h25)
                                        .foregroundStyle(.white)
                                        .shadow(color: .black, radius: 4)
                                        .scaleEffect(scaleFactorHBS)
                                        .minimumScaleFactor(0.4)
                                }
                                .offset(y: -2 * scaleFactorHBS)
                            }
                        }
                    }
                }
                .frame(height: 140 * scaleFactorHBS)
            }
        }
    }
}

struct ShopViewHBS_Previews: PreviewProvider {
    static var previews: some View {
        ShopViewHBS()
            .environmentObject(ShopManagerHBS())
    }
}
