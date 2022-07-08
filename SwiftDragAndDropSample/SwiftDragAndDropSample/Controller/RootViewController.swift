//
//  RootViewController.swift
//  SwiftDragAndDropSample
//
//  Created by Panha Uy on 5/7/22.
//

import UIKit

class RootViewController: UITableViewController {
    
    enum Row: Int {
        case collectionView = 0
        case scrollView
        
        case count
        
        var viewController: UIViewController? {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            switch self {
            case .collectionView:
                return sb.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController
            case .scrollView:
                return sb.instantiateViewController(withIdentifier: "ScrollViewController") as? ScrollViewController
            default:
                return nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SwiftDragAndDrop"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension RootViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch Row(rawValue: indexPath.row) ?? .count {
        case .collectionView:
            cell.textLabel?.text = "With UICollectionView"
        case .scrollView:
            cell.textLabel?.text = "With UIScrollView"
        case .count:
            break
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = Row(rawValue: indexPath.row) ?? .count
        if let viewController = row.viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
