import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerView: UIView!
    
    // MARK: - Properties
    private var movies: [Movie] = []
    private var featuredMovie: Movie?
    private var previewPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    // Use weak references for delegates and data sources
    private weak var networkManager: NetworkManager?
    private var refreshControl: UIRefreshControl?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        loadData()
        setupNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop video preview to prevent memory leaks
        stopPreview()
    }
    
    deinit {
        // Clean up resources
        removeNotifications()
        stopPreview()
        cleanupPlayer()
        collectionView?.delegate = nil
        collectionView?.dataSource = nil
        print("HomeViewController deallocated")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .white
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        // Register cells
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "MovieCell")
        collectionView.register(FeaturedMovieCell.self, forCellWithReuseIdentifier: "FeaturedCell")
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        networkManager = NetworkManager.shared
        
        // Use weak self to prevent retain cycles
        networkManager?.fetchMovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    self?.featuredMovie = movies.first
                    self?.collectionView.reloadData()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    @objc private func refreshData() {
        loadData()
        refreshControl?.endRefreshing()
    }
    
    @objc private func applicationDidEnterBackground() {
        stopPreview()
    }
    
    // MARK: - Video Preview Management
    private func setupPreview(for movie: Movie) {
        guard let previewURL = movie.previewURL else { return }
        
        cleanupPlayer()
        
        previewPlayer = AVPlayer(url: previewURL)
        playerLayer = AVPlayerLayer(player: previewPlayer)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = headerView.bounds
        
        if let playerLayer = playerLayer {
            headerView.layer.addSublayer(playerLayer)
        }
        
        previewPlayer?.play()
    }
    
    private func stopPreview() {
        previewPlayer?.pause()
    }
    
    private func cleanupPlayer() {
        previewPlayer?.pause()
        previewPlayer = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    // MARK: - Navigation
    private func showMovieDetail(_ movie: Movie) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController else {
            return
        }
        
        detailVC.movie = movie
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Featured section + Movies section
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return featuredMovie != nil ? 1 : 0
        }
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedCell", for: indexPath) as! FeaturedMovieCell
            if let movie = featuredMovie {
                cell.configure(with: movie)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
            cell.configure(with: movies[indexPath.item])
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = indexPath.section == 0 ? featuredMovie! : movies[indexPath.item]
        showMovieDetail(movie)
    }
}