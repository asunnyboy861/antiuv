import Foundation

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private let sessionsKey = "exposureSessions"
    
    func save() {
        // No-op for UserDefaults implementation
    }
    
    func addExposureSession(session: ExposureSession) {
        var sessions = fetchAllSessions()
        sessions.insert(session, at: 0)
        
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }
    
    func fetchAllSessions() -> [ExposureSession] {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey) else {
            return []
        }
        
        return (try? JSONDecoder().decode([ExposureSession].self, from: data)) ?? []
    }
    
    func deleteSession(id: UUID) {
        var sessions = fetchAllSessions()
        sessions.removeAll { $0.id == id }
        
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }
    
    func deleteAllSessions() {
        UserDefaults.standard.removeObject(forKey: sessionsKey)
    }
}
