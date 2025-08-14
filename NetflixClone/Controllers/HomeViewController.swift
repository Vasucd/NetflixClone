import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var heroPlayButton: UIButton!
    
    private var viewModel: HomeViewModel?
    private var heroVideoPlayer: AVPlayer?
    private var heroVideoPlayerLayer: AVPlayerLayer?
    private var heroVideoObserver: Any?
    
    // Use weak references for delegates
    weak var networkManager: NetworkManager?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startHeroVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopHeroVideo()
    }
    
    deinit {
        // Clean up observers
        if let observer = heroVideoObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // Clean up video player
        heroVideoPlayer?.pause()
        heroVideoPlayerLayer?.removeFromSuperlayer()
        heroVideoPlayer = nil
        heroVideoPlayerLayer = nil
        
        // Remove table view delegate and data source
        tableView?.delegate = nil
        tableView?.dataSource = nil
        
        print("HomeViewController deallocated")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .black
        heroPlayButton.addTarget(self, action: #selector(heroPlayButtonTapped), for: .touchUpInside)
    }
    
    private func setupViewModel() {
        viewModel = HomeViewModel()
        // Use weak self in closures
        viewModel?.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        viewModel?.loadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieRowTableViewCell.self, forCellReuseIdentifier: "MovieRowCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
    
    // MARK: - Video Methods
    private func startHeroVideo() {
        guard let videoURL = URL(string: "https://example.com/hero-video.mp4") else { return }
        
        heroVideoPlayer = AVPlayer(url: videoURL)
        heroVideoPlayerLayer = AVPlayerLayer(player: heroVideoPlayer)
        heroVideoPlayerLayer?.frame = heroImageView.bounds
        heroVideoPlayerLayer?.videoGravity = .resizeAspectFill
        
        if let playerLayer = heroVideoPlayerLayer {
            heroImageView.layer.addSublayer(playerLayer)
        }
        
        // Use weak self in notification observer
        heroVideoObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: heroVideoPlayer?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.heroVideoPlayer?.seek(to: CMTime.zero)
            self?.heroVideoPlayer?.play()
        }
        
        heroVideoPlayer?.play()
    }
    
    private func stopHeroVideo() {
        heroVideoPlayer?.pause()
        if let observer = heroVideoObserver {
            NotificationCenter.default.removeObserver(observer)
            heroVideoObserver = nil
        }
    }
    
    // MARK: - Actions
    @objc private func heroPlayButtonTapped() {
        let playerVC = VideoPlayerViewController()
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.movieSections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieRowCell", for: indexPath) as! MovieRowTableViewCell
        
        if let section = viewModel?.movieSections[indexPath.row] {
            cell.configure(with: section)
            // Use weak self in cell callbacks
            cell.onMovieSelected = { [weak self] movie in
                let detailVC = MovieDetailViewController()
                detailVC.movie = movie
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}