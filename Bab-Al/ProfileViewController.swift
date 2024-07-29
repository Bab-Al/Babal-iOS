//
//  ProfileViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/30/24.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var heightTextLabel: UILabel!
    @IBOutlet weak var weightTextLabel: UILabel!
    @IBOutlet weak var profileTableView: UITableView!
    
    
 
    struct Icon {
        let title: String
        let imageName: String
    }
    
    let data: [Icon] = [
        Icon(title: "Edit Profile", imageName: "user"),
        Icon(title: "Edit Food Category", imageName: "star"),
        Icon(title: "Logout", imageName: "exit"),
        Icon(title: "Delete Account", imageName: "delete"),
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTableView.dataSource = self
        profileTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let icon = data[indexPath.row]
        let cell = profileTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.label.text = icon.title
        cell.iconImageView.image = UIImage(named: icon.imageName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIcon = data[indexPath.row]
            
        if selectedIcon.title == "Logout" {
            logout()
        }
    }
        
    func logout() {
        // Clear user data
        UserInfoManager.shared.clearAuthToken()
        UserInfoManager.shared.userInfo = UserInfo() // Reset user info

        // Navigate to login screen
        if let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            view.window?.rootViewController = loginViewController
            view.window?.makeKeyAndVisible()
        }
    }

}
