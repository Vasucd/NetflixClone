import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    enum AuthError: Error {
        case invalidCredentials
        case networkError
        case unknownError
        
        var localizedDescription: String {
            switch self {
            case .invalidCredentials:
                return "Invalid email or password"
            case .networkError:
                return "Network connection error"
            case .unknownError:
                return "An unknown error occurred"
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            // For demo purposes, accept any email/password combination
            // In a real app, this would make an actual API call
            if email.contains("@") && password.count >= 6 {
                // Save login state
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(email, forKey: "userEmail")
                completion(.success(()))
            } else {
                completion(.failure(.invalidCredentials))
            }
        }
    }
    
    func signOut() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
    
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func getCurrentUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: "userEmail")
    }
}