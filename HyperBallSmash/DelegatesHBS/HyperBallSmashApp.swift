import SwiftUI
import OneSignalFramework

enum AppStateHBS {
    case splashHBS, onboardHBS, mainMenuHBS, mainVMenuHBS
}

@main
struct HyperBallSmashApp: App {
    @UIApplicationDelegateAdaptor(HyperBallNotificationWizard.self) var notificationWizard
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


final class HyperBallNotificationWizard: NSObject, UIApplicationDelegate {
    static private(set) var shared: HyperBallNotificationWizard?

    private let storage = UserDefaults.standard
    private let deviceKey = "hyperball_unique_device_id"
    private let notificationKey = "hyperball_notification_permission"
    private let oneSignalAppKey = "e3e5f74d-8e51-404f-8dfb-12aa81cfb8a1"
    internal var screenOrientation: UIInterfaceOrientationMask = .portrait

    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        HyperBallNotificationWizard.shared = self
        setupNotificationMagic()
        return true
    }
    
    internal func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return screenOrientation
    }
    
    private func setupNotificationMagic() {
        OneSignal.initialize(oneSignalAppKey)
        let deviceId = createOrFetchDeviceSpell()
        print("🎮 HyperBall Device Signature: \(deviceId)")
        print("HOT: \(deviceId)")
        OneSignal.login(deviceId)
        castNotificationPermissionSpell()
    }
    
    private func createOrFetchDeviceSpell() -> String {
        if let existingId = storage.string(forKey: deviceKey) {
            return existingId
        }
        let newId = craftUniqueDeviceSignature()
        storage.set(newId, forKey: deviceKey)
        return newId
    }
    
    private func craftUniqueDeviceSignature() -> String {
        let vendorID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let timeStamp = Int(Date().timeIntervalSince1970)
        let randomComponent = String(format: "%08x", arc4random())
        return "hyperball_\(vendorID)_\(timeStamp)_\(randomComponent)"
    }
    
    private func castNotificationPermissionSpell() {
        guard !storage.bool(forKey: notificationKey) else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in
            OneSignal.Notifications.requestPermission({ accepted in
                self?.storage.set(true, forKey: self?.notificationKey ?? "")
            }, fallbackToSettings: false)
        }
    }
    
    func updateScreenOrientation() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.windows.forEach { window in
                window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        }
    }
}
