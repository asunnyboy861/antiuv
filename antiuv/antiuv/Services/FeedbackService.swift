import Foundation

class FeedbackService {
    static let shared = FeedbackService()
    
    private let workerURL = "https://feedback-board.iocompile67692.workers.dev"
    private let appName = "AntiUV"
    
    private init() {}
    
    func submitFeedback(
        name: String,
        email: String,
        subject: String,
        message: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        guard let url = URL(string: "\(workerURL)/api/feedback") else {
            completion(.failure(FeedbackError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "subject": subject,
            "message": message,
            "app_name": appName
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(FeedbackError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(FeedbackError.noData))
                return
            }
            
            do {
                if httpResponse.statusCode == 200 {
                    let result = try JSONDecoder().decode(FeedbackResponse.self, from: data)
                    completion(.success(result.id))
                } else {
                    let errorResponse = try JSONDecoder().decode(FeedbackErrorResponse.self, from: data)
                    completion(.failure(FeedbackError.serverError(errorResponse.error)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func submitFeedbackAsync(
        name: String,
        email: String,
        subject: String,
        message: String
    ) async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            submitFeedback(name: name, email: email, subject: subject, message: message) { result in
                switch result {
                case .success(let id):
                    continuation.resume(returning: id)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

struct FeedbackResponse: Codable {
    let success: Bool
    let id: Int
}

struct FeedbackErrorResponse: Codable {
    let error: String
}

enum FeedbackError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid feedback URL"
        case .invalidResponse:
            return "Invalid server response"
        case .noData:
            return "No data received from server"
        case .serverError(let message):
            return message
        }
    }
}
