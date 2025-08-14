import UIKit
import AVFoundation

class MovieDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addToListButton: UIButton!
    @IBOutlet weak var similarMoviesCollectionView: UICollectionView!
    
    // MARK: - Properties
    var movie: Movie?
    private var similarMovies: [Movie] = []
    private var player: AVPlayer?
    private var playerViewController: AVPlayerViewController?
    
    // Use weak reference to prevent retain cycles
    private weak var networkManager: NetworkManager?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        configureWithMovie()
        loadSimilarMovies()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopVideo()
    }
    
    deinit {
        // Clean up resources
        cleanupPlayer()
        similarMoviesCollectionView?.delegate = nil
        similarMoviesCollectionView?.dataSource = nil
        NotificationCenter.default.removeObserver(self)
        print("MovieDetailViewController deallocated")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .white
        
        playButton.backgroundColor = .white
        playButton.setTitleColor(.black, for: .normal)
        playButton.layer.cornerRadius = 8
        
        addToListButton.backgroundColor = .darkGray
        addToListButton.setTitleColor(.white, for: .normal)
        addToListButton.layer.cornerRadius = 8
        
        // Setup notification observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    private func setupCollectionView() {
        similarMoviesCollectionView.delegate = self
        similarMoviesCollectionView.dataSource = self
        similarMoviesCollectionView.backgroundColor = .clear
        similarMoviesCollectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "MovieCell")
    }
    
    private func configureWithMovie() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        descriptionLabel.text = movie.description
        
        // Load image asynchronously
        ImageLoader.shared.loadImage(from: movie.imageURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.movieImageView.image = image
            }
        }
    }
    
    private func loadSimilarMovies() {
        guard let movie = movie else { return }
        
        networkManager = NetworkManager.shared
        networkManager?.fetchSimilarMovies(for: movie.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self?.similarMovies = movies
                    self?.similarMoviesCollectionView.reloadData()
                case .failure(let error):
                    print("Failed to load similar movies: \(error)")
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func playButtonTapped(_ sender: UIButton) {
        playMovie()
    }
    
    @IBAction func addToListButtonTapped(_ sender: UIButton) {
        // Implementation for adding to watchlist
        guard let movie = movie else { return }
        WatchlistManager.shared.addToWatchlist(movie)
        
        // Update button state
        addToListButton.setTitle("Added ✓", for: .normal)
        addToListButton.isEnabled = false
    }
    
    // MARK: - Video Playback
    private func playMovie() {
        guard let movie = movie, let videoURL = movie.videoURL else {
            showAlert(title: "Error", message: "Video not available")
            return
        }
        
        cleanupPlayer()
        
        player = AVPlayer(url: videoURL)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        
        if let playerVC = playerViewController {
            present(playerVC, animated: true) { [weak self] in
                self?.player?.play()
            }
        }
    }
    
    private func stopVideo() {
        player?.pause()
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player = nil
        playerViewController = nil
    }
    
    @objc private func playerDidFinishPlaying() {
        DispatchQueue.main.async { [weak self] in
            self?.playerViewController?.dismiss(animated: true)
            self?.cleanupPlayer()
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MovieDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
        cell.configure(with: similarMovies[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MovieDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = similarMovies[indexPath.item]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController else {
            return
        }
        
        detailVC.movie = selectedMovie
        navigationController?.pushViewController(detailVC, animated: true)
    }
}