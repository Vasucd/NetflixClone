import UIKit

class SearchViewController: UIViewController {
    
    private let discoverTable: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search for a Movie or a TV show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    private var movies: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 SearchViewController: viewDidLoad started")
        
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(discoverTable)
        discoverTable.delegate = self
        discoverTable.dataSource = self
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        
        searchController.searchResultsUpdater = self
        
        fetchDiscoverMovies()
        
        print("🔍 SearchViewController: viewDidLoad completed")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
        print("🔍 SearchViewController: Layout updated - table frame: \(discoverTable.frame)")
    }
    
    private func fetchDiscoverMovies() {
        print("🔍 SearchViewController: Fetching discover movies")
        
        // Simulate API call with mock data
        movies = ["The Matrix", "Inception", "Interstellar", "The Dark Knight", "Pulp Fiction"]
        
        DispatchQueue.main.async { [weak self] in
            print("🔍 SearchViewController: Movies fetched - \(self?.movies.count ?? 0) items")
            self?.discoverTable.reloadData()
        }
    }
    
    private func search(with query: String) {
        print("🔍 SearchViewController: Searching with query: '\(query)'")
        
        // Simulate search API call
        let filteredMovies = movies.filter { $0.lowercased().contains(query.lowercased()) }
        
        print("🔍 SearchViewController: Search completed - found \(filteredMovies.count) results")
        
        DispatchQueue.main.async { [weak self] in
            self?.movies = filteredMovies
            self?.discoverTable.reloadData()
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("🔍 SearchViewController: numberOfRowsInSection called - returning \(movies.count)")
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🔍 SearchViewController: cellForRowAt row \(indexPath.row)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = movies[indexPath.row]
        
        print("🔍 SearchViewController: Cell configured with title: '\(movies[indexPath.row])'")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = 140
        print("🔍 SearchViewController: heightForRowAt row \(indexPath.row) - returning \(height)")
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMovie = movies[indexPath.row]
        print("🔍 SearchViewController: Movie selected: '\(selectedMovie)' at row \(indexPath.row)")
    }
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3 else {
            print("🔍 SearchViewController: Search query too short or empty")
            return
        }
        
        print("🔍 SearchViewController: updateSearchResults called with query: '\(query)'")
        search(with: query)
    }
}