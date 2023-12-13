//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by İsmail Parlak on 11.12.2023.
//

import UIKit
import MessageKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD()
    
    private let seacthBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Seacrh for Users..."
        return searchBar
    }()
    
    private let tableView:UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    @objc override func viewDidLoad() {
        super.viewDidLoad()
        seacthBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = seacthBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismisSelf))
        seacthBar.becomeFirstResponder()
        
    }
    
    @objc private func dismisSelf() {
        dismiss(animated: true,completion: nil )
    }
}


extension NewConversationViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
