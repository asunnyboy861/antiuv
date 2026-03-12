import Foundation
import Combine
import WatchConnectivity

class WatchUVViewModel: ObservableObject {
    @Published var uvData: WatchUVData?
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isTimerRunning: Bool = false
    @Published var timerText: String = "00:00"
    @Published var timerProgress: Double = 0.0
    
    private var timer: Timer?
    private var timeRemaining: Int = 0
    private var totalTime: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupWatchConnectivity()
        loadCachedData()
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = WatchSessionDelegate.shared
            session.activate()
            
            WatchSessionDelegate.shared.uvDataPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    self?.uvData = data
                    self?.isLoading = false
                    self?.error = nil
                }
                .store(in: &cancellables)
        }
    }
    
    private func loadCachedData() {
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.data(forKey: "cachedUVData"),
           let cachedData = try? JSONDecoder().decode(WatchUVData.self, from: data) {
            self.uvData = cachedData
        }
    }
    
    func fetchUVData() {
        isLoading = true
        error = nil
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["request": "uvData"]) { replyData in
                DispatchQueue.main.async {
                    if let data = replyData["uvData"] as? [String: Any],
                       let jsonData = try? JSONSerialization.data(withJSONObject: data),
                       let uvData = try? JSONDecoder().decode(WatchUVData.self, from: jsonData) {
                        self.uvData = uvData
                        self.cacheData(uvData)
                        self.isLoading = false
                        self.error = nil
                    }
                }
            } errorHandler: { error in
                DispatchQueue.main.async {
                    self.error = "Failed to fetch data"
                    self.isLoading = false
                }
            }
        } else {
            error = "iPhone not reachable"
            isLoading = false
        }
    }
    
    private func cacheData(_ data: WatchUVData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "cachedUVData")
        }
    }
    
    func startQuickTimer() {
        let defaultDuration = uvData != nil ? calculateSafeTime(for: uvData!.uvIndex) : 30
        startTimer(duration: defaultDuration)
    }
    
    func startTimer(duration: Int) {
        stopTimer()
        
        totalTime = duration * 60
        timeRemaining = totalTime
        isTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 1
            self.updateTimerDisplay()
            
            if self.timeRemaining <= 0 {
                self.timerCompleted()
            }
        }
        
        updateTimerDisplay()
        
        WCSession.default.sendMessage(["request": "startTimer", "duration": duration]) { _ in }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        
        WCSession.default.sendMessage(["request": "pauseTimer"]) { _ in }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 0
        totalTime = 0
        isTimerRunning = false
        timerText = "00:00"
        timerProgress = 0.0
        
        WCSession.default.sendMessage(["request": "stopTimer"]) { _ in }
    }
    
    private func updateTimerDisplay() {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        timerText = String(format: "%02d:%02d", minutes, seconds)
        timerProgress = Double(totalTime - timeRemaining) / Double(totalTime)
    }
    
    private func timerCompleted() {
        stopTimer()
        
        WKInterfaceDevice.current().play(.notification)
        
        WCSession.default.sendMessage(["request": "timerCompleted"]) { _ in }
    }
    
    private func calculateSafeTime(for uvIndex: Double) -> Int {
        return max(15, min(120, Int(120 / max(uvIndex, 1.0))))
    }
}

struct WatchUVData: Codable {
    let uvIndex: Double
    let uvLevel: String
    let locationName: String
    let temperature: Double
    let timestamp: Date
}

class WatchSessionDelegate: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionDelegate()
    
    let uvDataPublisher = PassthroughSubject<WatchUVData, Never>()
    
    private override init() {
        super.init()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activated: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let data = message["uvData"] as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: data),
           let uvData = try? JSONDecoder().decode(WatchUVData.self, from: jsonData) {
            uvDataPublisher.send(uvData)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let data = applicationContext["uvData"] as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: data),
           let uvData = try? JSONDecoder().decode(WatchUVData.self, from: jsonData) {
            uvDataPublisher.send(uvData)
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch session reachability changed: \(session.isReachable)")
    }
}
