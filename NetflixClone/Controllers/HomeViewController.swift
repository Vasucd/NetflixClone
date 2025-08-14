import UIKit

class HomeViewController: UIViewController {
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()
    
    private let sectionTitles: [String] = ["Trending Movies", "Trending TV", "Popular", "Upcoming Movies", "Top Rated"]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🏠 HomeViewController: viewDidLoad started")
        
        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        configureNavbar()
        
        print("🏠 HomeViewController: Table view configured with \(sectionTitles.count) sections")
        print("🏠 HomeViewController: viewDidLoad completed")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
        print("🏠 HomeViewController: Layout updated - table frame: \(homeFeedTable.frame)")
    }
    
    private func configureNavbar() {
        print("🏠 HomeViewController: Configuring navigation bar")
        
        var image = UIImage(named: "netflixLogo")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: #selector(profileTapped)),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: #selector(playTapped))
        ]
        
        navigationController?.navigationBar.tintColor = .white
        
        print("🏠 HomeViewController: Navigation bar configured successfully")
    }
    
    @objc private func profileTapped() {
        print("🏠 HomeViewController: Profile button tapped")
    }
    
    @objc private func playTapped() {
        print("🏠 HomeViewController: Play button tapped")
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("🏠 HomeViewController: numberOfSections called - returning \(sectionTitles.count)")
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("🏠 HomeViewController: numberOfRowsInSection \(section) called - returning 1")
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🏠 HomeViewController: cellForRowAt section \(indexPath.section), row \(indexPath.row)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            print("❌ HomeViewController: Failed to dequeue CollectionViewTableViewCell")
            return UITableViewCell()
        }
        
        print("✅ HomeViewController: Successfully configured cell for section \(indexPath.section)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = 200
        print("🏠 HomeViewController: heightForRowAt section \(indexPath.section) - returning \(height)")
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height: CGFloat = 40
        print("🏠 HomeViewController: heightForHeaderInSection \(section) - returning \(height)")
        return height
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = sectionTitles[section]
        print("🏠 HomeViewController: titleForHeaderInSection \(section) - returning '\(title)'")
        return title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        print("🏠 HomeViewController: willDisplayHeaderView for section \(section)")
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
}