import UIKit

class HomeViewController: UIViewController {
    
    private var homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()
    
    private let networkManager = NetworkManager.shared
    private var isNetworkConnected = true
    
    private let noConnectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "wifi.slash")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "No Internet Connection"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        retryButton.backgroundColor = .systemRed
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 8
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            retryButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 100),
            retryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        retryButton.addTarget(self, action: #selector(retryConnection), for: .touchUpInside)
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupNetworkMonitoring()
        testInitialConnection()
    }
    
    private func setupTableView() {
        view.addSubview(homeFeedTable)
        view.addSubview(noConnectionView)
        
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        homeFeedTable.translatesAutoresizingMaskIntoConstraints = false
        noConnectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            homeFeedTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            homeFeedTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeFeedTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeFeedTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            noConnectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            noConnectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noConnectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noConnectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNetworkMonitoring() {
        networkManager.onNetworkStatusChanged = { [weak self] isConnected in
            self?.handleNetworkStatusChange(isConnected: isConnected)
        }
    }
    
    private func testInitialConnection() {
        // Test connection to a reliable endpoint
        let testURL = "https://api.themoviedb.org/3/movie/popular"
        
        networkManager.testConnection(to: testURL) { [weak self] isReachable, error in
            DispatchQueue.main.async {
                if isReachable {
                    self?.handleNetworkStatusChange(isConnected: true)
                    self?.loadContent()
                } else {
                    self?.handleNetworkStatusChange(isConnected: false)
                    print("Connection test failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func handleNetworkStatusChange(isConnected: Bool) {
        isNetworkConnected = isConnected
        
        UIView.animate(withDuration: 0.3) {
            self.homeFeedTable.isHidden = !isConnected
            self.noConnectionView.isHidden = isConnected
        }
        
        if isConnected {
            loadContent()
        }
    }
    
    @objc private func retryConnection() {
        testInitialConnection()
    }
    
    private func loadContent() {
        // Simulate loading content from API
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.homeFeedTable.reloadData()
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isNetworkConnected ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Trending Movies"
        case 1:
            return "Popular"
        case 2:
            return "Trending TV"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .label
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
}

extension String {
    func capitalizeFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}