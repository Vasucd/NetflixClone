import UIKit

class SearchViewController: UIViewController {
    
    private let discoverTable: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search for a Movie or TV show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    private let networkManager = NetworkManager.shared
    private var movies: [String] = []
    private var isNetworkConnected = true
    
    private let noConnectionLabel: UILabel = {
        let label = UILabel()
        label.text = "No internet connection. Please check your network settings."
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        setupViews()
        setupNetworkMonitoring()
        testConnectionAndLoadData()
    }
    
    private func setupViews() {
        view.addSubview(discoverTable)
        view.addSubview(noConnectionLabel)
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        discoverTable.delegate = self
        discoverTable.dataSource = self
        
        discoverTable.translatesAutoresizingMaskIntoConstraints = false
        noConnectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            discoverTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            discoverTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            discoverTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            discoverTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            noConnectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noConnectionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noConnectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noConnectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupNetworkMonitoring() {
        networkManager.onNetworkStatusChanged = { [weak self] isConnected in
            self?.handleNetworkStatusChange(isConnected: isConnected)
        }
    }
    
    private func testConnectionAndLoadData() {
        let testURL = "https://api.themoviedb.org/3/discover/movie"
        
        networkManager.testConnection(to: testURL) { [weak self] isReachable, error in
            DispatchQueue.main.async {
                if isReachable {
                    self?.