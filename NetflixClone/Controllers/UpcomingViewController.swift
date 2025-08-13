import UIKit

class UpcomingViewController: UIViewController {
    
    private let upcomingTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        table.backgroundColor = .black
        return table
    }()
    
    override func viewDi