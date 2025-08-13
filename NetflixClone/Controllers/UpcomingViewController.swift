import UIKit

class UpcomingViewController: UIViewController {
    
    private let upcomingTable: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .black
        return table
    }()