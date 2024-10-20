//
//  LoginViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/28/24.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
            // Show an alert if email or password is empty
            showAlert(message: "Please enter both email and password.")
            return
        }
                
        UserInfoManager.shared.login(email: email, password: password) { result in
            switch result {
            case .success(let token):
                print("Login successful. Token: \(token)")
//                self.performSegue(withIdentifier: "goToNext", sender: self)
            case .failure(let error):
                // Show an alert for failed login
                switch error {
                case .member4001(let message), .member4004(let message), .unknownError(let message):
                    self.showAlert(message: message)
                default:
                    print("Login failed.")
                }
            }
        }
    }
    
    
    // Function to show an alert with a given message
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
