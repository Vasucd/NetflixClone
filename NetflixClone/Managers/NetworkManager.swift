import Foundation
import Network
import SystemConfiguration

class NetworkManager {
    static let shared = NetworkManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var isConnected = false
    
    var onNetworkStatusChanged: ((Bool) -> Void)?
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.onNetworkStatusChanged?(self?.isConnected ?? false)
            }
        }
        monitor.start(queue: queue)
    }
    
    func isNetworkAvailable() -> Bool {
        return isConnected
    }
    
    func testConnection(to urlString: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false, NetworkError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10.0
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    let isReachable = (200...299).contains(httpResponse.statusCode)
                    completion(isReachable, nil)
                } else {
                    completion(false, NetworkError.invalidResponse)
                }
            }
        }.resume()
    }
    
    func fetchData(from urlString: String, completion: @escaping (Data?, Error?) -> Void) {
        guard isNetworkAvailable() else {
            completion(nil, NetworkError.noConnection)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil, NetworkError.invalidURL)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(nil, NetworkError.invalidResponse)
                    return
                }
                
                completion(data, nil)
            }
        }.resume()
    }
}

enum NetworkError: Error, LocalizedError {
    case noConnection
    case invalidURL
    case invalidResponse
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .timeout:
            return "Request timed out"
        }
    }
}