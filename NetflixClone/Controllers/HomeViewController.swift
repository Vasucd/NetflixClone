import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTv = 1
    case Popular = 2
    case Upcoming = 3
    case TopRated = 4
}

class HomeViewController: UIViewController {
    
    private var randomTrendingMovie: Title?
    private var headerView: HeroHeaderUIView?
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavbar()
        setupUI()
        configureHeroHeaderView()
        fetchData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeFeedTable.tableHeaderView = headerView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
    
    private func configureHeroHeaderView() {
        Task {
            do {
                let titles = try await APICaller.shared.getTrendingMovies()
                if let selectedTitle = titles.randomElement() {
                    await MainActor.run {
                        self.randomTrendingMovie = selectedTitle
                        self.headerView?.configure(with: TitleViewModel(
                            titleName: selectedTitle.original_title ?? selectedTitle.original_name ?? "Unknown",
                            posterURL: selectedTitle.poster_path ?? ""
                        ))
                    }
                }
            } catch {
                print("Failed to fetch trending movies for hero header: \(error)")
            }
        }
    }
    
    private func fetchData() {
        // This method can be used for additional data fetching if needed
        // Currently, data is fetched per section in the table view cells
    }
    
    private func configureNavbar() {
        var image = UIImage(named: "netflixLogo")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)
        ]
        
        navigationController?.navigationBar.tintColor = .label
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        switch indexPath.section {
        case Sections.TrendingMovies.rawValue:
            Task {
                do {
                    let titles = try await APICaller.shared.getTrendingMovies()
                    await MainActor.run {
                        cell.configure(with: titles)
                    }
                } catch {
                    print("Failed to fetch trending movies: \(error)")
                }
            }
            
        case Sections.TrendingTv.rawValue:
            Task {
                do {
                    let titles = try await APICaller.shared.getTrendingTvs()
                    await MainActor.run {
                        cell.configure(with: titles)
                    }
                } catch {
                    print("Failed to fetch trending TV shows: \(error)")
                }
            }
            
        case Sections.Popular.rawValue:
            Task {
                do {
                    let titles = try await APICaller.shared.getPopular()
                    await MainActor.run {
                        cell.configure(with: titles)
                    }
                } catch {
                    print("Failed to fetch popular titles: \(error)")
                }
            }
            
        case Sections.Upcoming.rawValue:
            Task {
                do {
                    let titles = try await APICaller.shared.getUpcomingMovies()
                    await MainActor.run {
                        cell.configure(with: titles)
                    }
                } catch {
                    print("Failed to fetch upcoming movies: \(error)")
                }
            }
            
        case Sections.TopRated.rawValue:
            Task {
                do {
                    let titles = try await APICaller.shared.getTopRated()
                    await MainActor.run {
                        cell.configure(with: titles)
                    }
                } catch {
                    print("Failed to fetch top rated titles: \(error)")
                }
            }
            
        default:
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .label
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Sections.TrendingMovies.rawValue:
            return "Trending Movies"
        case Sections.TrendingTv.rawValue:
            return "Trending TV"
        case Sections.Popular.rawValue:
            return "Popular"
        case Sections.Upcoming.rawValue:
            return "Upcoming Movies"
        case Sections.TopRated.rawValue:
            return "Top rated"
        default:
            return "Popular"
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

extension HomeViewController: CollectionViewTableViewCellDelegate {
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Supporting Classes and Extensions

class HeroHeaderUIView: UIView {
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "heroImage")
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heroImageView)
        addGradient()
        addSubview(playButton)
        addSubview(downloadButton)
        applyConstraints()
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    public func configure(with model: TitleViewModel) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run {
                    self.heroImageView.image = UIImage(data: data)
                }
            } catch {
                print("Failed to load hero image: \(error)")
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.frame = bounds
    }
    
    private func applyConstraints() {
        let playButtonConstraints = [
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 70),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            playButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        let downloadButtonConstraints = [
            downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70),
            downloadButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            downloadButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        NSLayoutConstraint.activate(playButtonConstraints)
        NSLayoutConstraint.activate(downloadButtonConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

struct TitleViewModel {
    let titleName: String
    let posterURL: String
}

struct TitlePreviewViewModel {
    let title: String
    let youtubeView: VideoElement
    let titleOverview: String
}

class TitlePreviewViewController: UIViewController {
    func configure(with model: TitlePreviewViewModel) {
        // Implementation for title preview
    }
}

struct VideoElement {
    let id: String
    let name: String
    let key: String
    let site: String
    let type: String
}

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}

// MARK: - API Models

struct Title: Codable {
    let id: Int
    let media_type: String?
    let original_name: String?
    let original_title: String?
    let poster_path: String?
    let overview: String?
    let vote_count: Int
    let release_date: String?
    let vote_average: Double
}

struct TrendingTitleResponse: Codable {
    let results: [Title]
}

// MARK: - API Caller

class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let API_KEY = "YOUR_API_KEY_HERE"
        static let baseURL = "https://api.themoviedb.org"
        static let YouTubeAPI_KEY = "YOUR_YOUTUBE_API_KEY_HERE"
        static let YouTubeBaseURL = "https://youtube.googleapis.com/youtube/v3/search?"
    }
    
    private init() {}
    
    func getTrendingMovies() async throws -> [Title] {
        guard let url = URL(string: "\(Constants.baseURL)/3/trending/movie/day?api_key=\(Constants.API_KEY)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
        return results.results
    }
    
    func getTrendingTvs() async throws -> [Title] {
        guard let url = URL(string: "\(Constants.baseURL)/3/trending/tv/day?api_key=\(Constants.API_KEY)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.