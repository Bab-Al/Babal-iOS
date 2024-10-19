//
//  ProfileViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/30/24.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var heightTextLabel: UILabel!
    @IBOutlet weak var weightTextLabel: UILabel!
    @IBOutlet weak var profileTableView: UITableView!
    
    
 
    struct Icon {
        let title: String
        let imageName: String
    }
    
    struct Profile: Codable {
        let username: String
        let height: Int
        let weight: Int
        let age: Int
        let gender: String
        let bmr: Int
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
        
        fetchProfileData()
    }
    
    // Update labels with the fetched JSON data
    func updateProfileData(profile: Profile) {
        DispatchQueue.main.async {
            self.heightTextLabel.text = "\(profile.height)"
            self.weightTextLabel.text = "\(profile.weight)"
        }
    }
    
    func fetchProfileData() {
        let url = "http://hongik-babal.ap-northeast-2.elasticbeanstalk.com/setting" // Replace with your actual API endpoint
            
        let token = UserInfoManager.shared.token!
        print("Token sending: \(token)")
        
        AF.request(url, method: .get, headers: ["Authorization": "Bearer \(token)", "accept":"application/json"])
            .validate(statusCode: 200..<300) // Validates the response
            .responseDecodable(of: Profile.self) { response in
                switch response.result {
                case .success(let profile):
                    self.updateProfileData(profile: profile)
                case .failure(let error):
                    print("Error fetching profile data: \(error)")
                }
            }
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

        // Instantiate the LoginViewController
        if let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                
            // Find the active UIWindowScene
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = scene.windows.first {
                
                // Set the rootViewController to the LoginViewController
                window.rootViewController = loginViewController
                window.makeKeyAndVisible()
            }
        }
    }

}
