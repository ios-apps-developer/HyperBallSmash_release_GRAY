import SwiftUI

struct CoordinatorViewHBS: View {
    @AppStorage("firstLaunchGameHBS") private var onboardDoneHBS: Bool = false
    @AppStorage("cns1HBS") private var con1HBS: Bool = false
    @AppStorage("cnss2HBS") private var con2HBS: Bool = false
    @State private var appStateHBS: AppStateHBS = .splashHBS
    var body: some View {
        ZStack {
            switch appStateHBS {
            case .splashHBS:
                SplashViewHBS()
            case .onboardHBS:
                OnboardingViewHBS(onFinishHBS: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onboardDoneHBS = true
                        UserDefaults.standard.set(true, forKey: "firstLaunchGameHBS")
                    }
                    handleOnboardingCompletionHBS()
                })
            case .mainMenuHBS:
                MenuViewHBS()
            case .mainVMenuHBS:
                MenuViewHBS()
            }
        }
        .onAppear {
            initializeAppState()
        }
    }

    private func initializeAppState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            appStateHBS = determineInitialState()
            UserDefaults.standard.set(onboardDoneHBS, forKey: "firstLaunchGameHBS")
        }
    }

    private func determineInitialState() -> AppStateHBS {
        if !onboardDoneHBS {
            return .onboardHBS
        } else if con1HBS || con2HBS {
            return .mainVMenuHBS
        } else {
            return .mainMenuHBS
        }
    }

    private func handleOnboardingCompletionHBS() {
        appStateHBS = .mainMenuHBS
    }
}

struct CoordinatorViewHBS_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatorViewHBS()
    }
}
