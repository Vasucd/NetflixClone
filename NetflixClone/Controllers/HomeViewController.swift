//
//  HomeViewController.swift
//  NetflixClone
//
//  Created by Vasu Chand on 16/10/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let homefeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        view.backgroundColor = .gray
        view.addSubview(homefeedTable)
        homefeedTable.delegate = self
        homefeedTable.dataSource = self
        homefeedTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 450))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homefeedTable.frame = view.bounds
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let tableViewCell = tableView.dequeueReusableCell(
                                            withIdentifier: CollectionViewTableViewCell.identifier,
                                            for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        tableViewCell.textLabel?.text = "Hello world"
        return tableViewCell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
}
