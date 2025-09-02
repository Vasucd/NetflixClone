//
//  HomeViewController.swift
//  NetflixClone
//
//  Created by Developer on Date.
//  Copyright © 2023 NetflixClone. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        table.register(HeroHeaderUIView.self, forHeaderFooterViewReuseIdentifier: HeroHeaderUIView.identifier)
        return table
    }()
    
    private let sectionTitles: [String] = [
        "Trending Movies",
        "Trending TV",
        "Popular",
        "Upcoming Movies",
        "Top Rated"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTableView()
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        // Set the navigation title to match the tab name
        navigationItem.title = "Mobile" // Updated from "Home" to "Mobile"
    }
    
    private func setupNavigationBar() {
        var image = UIImage(named: "netflixLogo")
        image = image?.withRenderingMode(.alwaysOriginal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: image,
            style: .done,
            target: self,
            action: nil
        )
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "person"),
                style: .done,
                target: self,
                action: #selector(profileButtonTapped)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "play.rectangle"),
                style: .done,
                target: self,
                action: #selector(playButtonTapped)
            )
        ]
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        tableView.tableHeaderView = headerView
    }
    
    private func fetchData() {
        // Fetch trending movies, TV shows, etc.
        // Implementation depends on your networking layer
    }
    
    @objc private func profileButtonTapped() {
        // Handle profile button tap
        let profileVC = ProfileViewController()
        let navController = UINavigationController(rootViewController: profileVC)
        present(navController, animated: true)
    }
    
    @objc private func playButtonTapped() {
        // Handle play button tap
        print("Play something")
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CollectionViewTableViewCell.identifier,
            for: indexPath
        ) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        // Configure cell based on section
        switch indexPath.section {
        case 0:
            // Configure for trending movies
            break
        case 1:
            // Configure for trending TV
            break
        case 2:
            // Configure for popular
            break
        case 3:
            // Configure for upcoming movies
            break
        case 4:
            // Configure for top rated
            break
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizingFirstLetter()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

// MARK: - String Extension
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}