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
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var results = [[String:String]]()
    
    private var hasFetched = false
    
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
        
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        seacthBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = seacthBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismisSelf))
        seacthBar.becomeFirstResponder()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    @objc private func dismisSelf() {
        dismiss(animated: true,completion: nil )
    }
    
}


extension NewConversationViewController: UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension NewConversationViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty , !text.replacingOccurrences(of: "", with: "").isEmpty else{
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        self.searchUsers(quey: text)
    }
    
    func searchUsers(quey:String) {
        if hasFetched{
            filterUsers(with: quey)
        }
        else{
            DatabaseMenager.shared.getAllUsers(completion: {[weak self] result in
                switch result{
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.results = usersCollection
                    self?.filterUsers(with: quey)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
    }
    
    func filterUsers(with term:String){
        guard hasFetched else {
            return
        }
        
        self.spinner.dismiss()
        
        var results: [[String:String]] = self.results.filter({
            guard let name = $0["name"]?.lowercased() as? String else{
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        
        self.results = results
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty{
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true

        }
        else{
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
