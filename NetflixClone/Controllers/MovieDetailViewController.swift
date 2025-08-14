import UIKit
import AVFoundation

class MovieDetailViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addToListButton: UIButton!
    @IBOutlet weak var similarMoviesCollectionView: UICollectionView!
    
    var movie: Movie?
    private var viewModel: MovieDetailViewModel?
    private weak var imageLoader: ImageLoader?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        setupCollectionView()
        loadMovieDetails()
    }
    
    deinit {
        // Clean up collection view
        similarMoviesCollectionView?.delegate = nil
        similarMoviesCollectionView?.dataSource = nil
        
        // Cancel any ongoing image loading
        imageLoader?.cancelAllTasks()
        
        print("MovieDetailViewController deallocated")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white
        
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        addToListButton.addTarget(self, action: #selector(addToListButtonTapped), for: .touchUpInside)
    }
    
    private func setupViewModel() {
        guard let movie = movie else { return }
        
        viewModel = MovieDetailViewModel(movie: movie)
        viewModel?.onSimilarMoviesLoaded = { [weak self] in
            DispatchQueue.main.async {
                self?.similarMoviesCollectionView.reloadData()
            }
        }
        
        viewModel?.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showError(error)
            }
        }
    }
    
    private func setupCollectionView() {
        similarMoviesCollectionView.delegate = self
        similarMoviesCollectionView.dataSource = self
        similarMoviesCollectionView.register(MoviePosterCollectionViewCell.self, 
                                           forCellWithReuseIdentifier: "MoviePosterCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 180)
        layout.minimumLineSpacing = 10
        similarMoviesCollectionView.collectionViewLayout = layout
    }
    
    private func loadMovieDetails() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        descriptionLabel.text = movie.description
        
        // Load poster image with proper cleanup
        imageLoader = ImageLoader.shared
        imageLoader?.loadImage(from: movie.posterURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.posterImageView.image = image
            }
        }
        
        viewModel?.loadSimilarMovies()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", 
                                    message: error.localizedDescription, 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func playButtonTapped() {
        let playerVC = VideoPlayerViewController()
        playerVC.movie = movie
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
    
    @objc private func addToListButtonTapped() {
        guard let movie = movie else { return }
        WatchlistManager.shared.addToWatchlist(movie)
        
        // Show confirmation
        let alert = UIAlertController(title: "Added to List", 
                                    message: "\(movie.title) has been added to your watchlist", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MovieDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.similarMovies.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCell", for: indexPath) as! MoviePosterCollectionViewCell
        
        if let movie = viewModel?.similarMovies[indexPath.item] {
            cell.configure(with: movie)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MovieDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedMovie = viewModel?.similarMovies[indexPath.item] else { return }
        
        let detailVC = MovieDetailViewController()
        detailVC.movie = selectedMovie
        navigationController?.pushViewController(detailVC, animated: true)
    }
}