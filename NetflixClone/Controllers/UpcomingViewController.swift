import UIKit

class UpcomingViewController: UIViewController {
    
    private var movies: [String] = []
    
    private let upcomingTable: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🎭 UpcomingViewController: viewDidLoad started")
        
        view.backgroundColor = .systemBackground
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(upcomingTable)
        upcomingTable.delegate = self
        upcomingTable.dataSource = self
        
        fetchUpcoming()
        
        print("🎭 UpcomingViewController: viewDidLoad completed")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTable.frame = view.bounds
        print("🎭 UpcomingViewController: Layout updated - table frame: \(upcomingTable.frame)")
    }
    
    private func fetchUpcoming() {
        print("🎭 UpcomingViewController: Fetching upcoming movies")
        
        // Simulate API call with mock data
        movies = [
            "Avatar: The Way of Water",
            "Black Panther: Wakanda Forever",
            "Thor: Love and Thunder",
            "Doctor Strange in the Multiverse of Madness",
            "Spider-Man: No Way Home",
            "The Batman",
            "Jurassic World Dominion",
            "Top Gun: Maverick"
        ]
        
        DispatchQueue.main.async { [weak self] in
            print("🎭 UpcomingViewController: Upcoming movies fetched - \(self?.movies.count ?? 0) items")
            self?.upcomingTable.reloadData()
        }
    }
}

extension UpcomingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("🎭 UpcomingViewController: numberOfRowsInSection called - returning \(movies.count)")
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🎭 UpcomingViewController: cellForRowAt row \(indexPath.row)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = movies[indexPath.row]
        cell.imageView?.image = UIImage(systemName: "photo")
        cell.imageView?.tintColor = .white
        
        print("🎭 UpcomingViewController: Cell configured with title: '\(movies[indexPath.row])'")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = 140
        print("🎭 Up