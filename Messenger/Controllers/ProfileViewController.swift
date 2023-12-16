//
//  ProfileViewController.swift
//  Messenger
//
//  Created by İsmail Parlak on 12.12.2023.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHandler()
    }
    
    func createTableHandler() -> UIView{
         
        let email = UserDefaults.standard.value(forKey: "email") as? String
        let safeEmail = DatabaseMenager.safeEmail(emailAddress: email!)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150) / 2,
                                              y: 75,
                                              width: 150,
                                              height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result{
            case .success(let url):
                self!.dowloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("")
            }
            
        })

        return headerView
    }
    
    func dowloadImage(imageView:UIImageView,url:URL){
        URLSession.shared.dataTask(with: url,
                                   completionHandler: {data, _, error in
            guard let data = data, error == nil else{
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data:data)
                imageView.image = image
            }
        }
        ).resume()
    }
    
    
}

extension ProfileViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Log Out",
                                      style: .destructive,
                                      handler: {[weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            do{
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav,animated:true)
            }catch{
                print("Failed to log out")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert , animated: true)
        
        
        
    }
    
}
