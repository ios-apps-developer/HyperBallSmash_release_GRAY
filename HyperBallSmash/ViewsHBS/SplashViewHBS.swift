import SwiftUI

struct SplashViewHBS: View {
    @State private var ballOffsetHBS: CGFloat = -40
    @State private var dotsCountHBS = 0
    @State private var isContentVisibleHBS = false
    let timerHBS = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometryHBS in
            let isIpadHBS = geometryHBS.size.width > 768
            let scaleFactorHBS: CGFloat = isIpadHBS ? 1.5 : 1.0

            ZStack {
                Image("bg_mainHBS")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 140 * scaleFactorHBS) {
                    Image("logo_gameHBS")
                        .resizable()
                        .scaledToFit()
                        .opacity(isContentVisibleHBS ? 1 : 0)
                        .scaleEffect(isContentVisibleHBS ? 1 : 0.7)
                        .offset(y: isContentVisibleHBS ? 0 : -50)
                    VStack(spacing: 10 * scaleFactorHBS) {
                        VStack(spacing: 0) {
                            Image("ball_splHBS")
                                .resizable()
                                .frame(width: 40 * scaleFactorHBS, height: 40 * scaleFactorHBS)
                                .offset(y: -40 * scaleFactorHBS)
                                .offset(y: ballOffsetHBS * scaleFactorHBS)
                                .opacity(isContentVisibleHBS ? 1 : 0)
                                .scaleEffect(isContentVisibleHBS ? 1 : 0.5)
                                .rotation3DEffect(
                                    .degrees(isContentVisibleHBS ? 360 : 0),
                                    axis: (x: 0, y: 1, z: 0)
                                )

                            Image("block_splHBS")
                                .resizable()
                                .frame(width: 100 * scaleFactorHBS, height: 20 * scaleFactorHBS)
                                .opacity(isContentVisibleHBS ? 1 : 0)
                                .scaleEffect(isContentVisibleHBS ? 1 : 0.5)
                        }
                        Text("LOADING\(String(repeating: ".", count: dotsCountHBS))")
                            .font(FontManagerHBS.h20)
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 2)
                            .scaleEffect(scaleFactorHBS)
                            .minimumScaleFactor(0.4)
                            .opacity(isContentVisibleHBS ? 1 : 0)
                            .scaleEffect(isContentVisibleHBS ? 1 : 0.7)
                            .offset(y: isContentVisibleHBS ? 0 : 20)
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    isContentVisibleHBS = true
                }

                withAnimation(
                    .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                ) {
                    ballOffsetHBS = 40
                }
            }
            .onReceive(timerHBS) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    dotsCountHBS = (dotsCountHBS + 1) % 4
                }
            }
        }
    }
}

struct SplashViewHBS_Previews: PreviewProvider {
    static var previews: some View {
        SplashViewHBS()
    }
}
