import Foundation
import WatchConnectivity

class iPhoneWatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = iPhoneWatchConnector()
    
    @Published var uvData: UVData?
    
    private override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendUVDataToWatch(_ data: UVData) {
        guard WCSession.default.isReachable else {
            saveUVDataToAppGroup(data)
            return
        }
        
        let watchData: [String: Any] = [
            "uvIndex": data.uvIndex,
            "uvLevel": data.uvLevel,
            "locationName": data.locationName,
            "temperature": data.temperature,
            "timestamp": data.timestamp.timeIntervalSince1970
        ]
        
        WCSession.default.sendMessage(["uvData": watchData], replyHandler: nil) { error in
            print("Failed to send UV data to Watch: \(error.localizedDescription)")
            self.saveUVDataToAppGroup(data)
        }
    }
    
    private func saveUVDataToAppGroup(_ data: UVData) {
        let userDefaults = UserDefaults(suiteName: "group.com.zzsutuo.antiuv")
        
        let watchData: [String: Any] = [
            "uvIndex": data.uvIndex,
            "uvLevel": data.uvLevel,
            "locationName": data.locationName,
            "temperature": data.temperature,
            "timestamp": data.timestamp.timeIntervalSince1970
        ]
        
        userDefaults?.set(watchData, forKey: "cachedUVData")
        userDefaults?.synchronize()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iPhone Watch session activated: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let request = message["request"] as? String {
            switch request {
            case "uvData":
                if let uvData = uvData {
                    sendUVDataToWatch(uvData)
                }
            case "startTimer":
                if let duration = message["duration"] as? Int {
                    print("Watch requested to start timer: \(duration) minutes")
                }
            case "pauseTimer":
                print("Watch requested to pause timer")
            case "stopTimer":
                print("Watch requested to stop timer")
            case "timerCompleted":
                print("Watch timer completed")
            default:
                break
            }
        }
    }
}
