//
//  SignUpViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/28/24.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameRequiredMessage: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailFormatMessage: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordFormatMessage: UILabel!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordFormatMessage: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        // Set text field delegates
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        // Hide error messages initially
        usernameRequiredMessage.isHidden = true
        emailFormatMessage.isHidden = true
        passwordFormatMessage.isHidden = true
        confirmPasswordFormatMessage.isHidden = true
        
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(confirmPasswordTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardUp(notification:NSNotification) {
        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            UIView.animate(
                withDuration: 0.3
                , animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -100)
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }
    
    
    // MARK: - Validation methods
    
    func isValidEmail(_ email: String) -> Bool {
        // Regular expression to validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        // Check if the password length is between 6 to 12 characters
        if password.count < 6 || password.count > 12 {
            return false
        }
        
        // Check if the password contains both alphabets and numbers
        let alphabetSet = CharacterSet.letters
        let numberSet = CharacterSet.decimalDigits
        
        let containsAlphabets = password.rangeOfCharacter(from: alphabetSet)
        let containsNumbers = password.rangeOfCharacter(from: numberSet)
        
        return containsAlphabets != nil && containsNumbers != nil
    }
    
    @IBAction func nextClicked(_ sender: UIButton) {
        // Check if any of the text fields are empty
        guard let username = usernameTextField.text, !username.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            // Show an error message or handle empty fields as needed
            usernameRequiredMessage.isHidden = usernameTextField.text?.isEmpty == false
            return
        }
        
        // Validate password format
        if !isValidPassword(password) {
            passwordFormatMessage.isHidden = false
            return
        }
        
        // Check if passwords match
        if password != confirmPassword {
            confirmPasswordFormatMessage.isHidden = false
            return
        }
        
        let userInfo = UserInfoManager.shared
        
        userInfo.setUserName(username)
        userInfo.setUserEmail(email)
        userInfo.setUserPassword(password)
        userInfo.printUserInfo()
        //        if let userInfo = UserInfoManager.shared.getUserInfo() {
        //            print("User Information:")
        //            print("Name: \(userInfo.name)")
        //            print("Email: \(userInfo.email)")
        //            // Print other user information as needed
        //        } else {
        //            print("User information is not set")
        //        }
        
        // Perform signup action since all required fields are filled and valid
        print("Signup successful")
        self.performSegue(withIdentifier: "goToNext", sender: self)
    }
    
    
    // MARK: - Action methods
    
    @objc func emailTextFieldDidChange(_ textField: UITextField) {
        // Validate email format when text changes
        if let email = textField.text, !email.isEmpty {
            if isValidEmail(email) {
                emailFormatMessage.isHidden = true
            } else {
                emailFormatMessage.isHidden = false
            }
        }
    }
    
    @objc func passwordTextFieldDidChange(_ textField: UITextField) {
        if let password = textField.text, !password.isEmpty {
            if isValidPassword(password) {
                passwordFormatMessage.isHidden = true
            } else {
                passwordFormatMessage.isHidden = false
            }
        }
    }
    
    @objc func confirmPasswordTextFieldDidChange(_ textField: UITextField) {
        if let confirmPassword = textField.text, let password = passwordTextField.text {
            if confirmPassword == password {
                confirmPasswordFormatMessage.isHidden = true
            } else {
                confirmPasswordFormatMessage.isHidden = false
            }
        }
    }
    
}
