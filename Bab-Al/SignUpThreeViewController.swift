//
//  SignUpThreeViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/28/24.
//

import UIKit

class SignUpThreeViewController: UIViewController {
    
    
    @IBOutlet var optionButtons: [UIButton]!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var selectedOptions: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Add action targets for the buttons
        for button in optionButtons {
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        }
        
        // Disable nextButton initially
        signUpButton.isEnabled = false
    }
    
    // Action method for handling button taps
    @objc func optionButtonTapped(_ sender: UIButton) {
        // Toggle the selection state of the button
        sender.isSelected.toggle()
            
        if sender.isSelected {
            // Add the button to the selectedOptions array if it's selected
            selectedOptions.append(sender)
        } else {
            // Remove the button from the selectedOptions array if it's deselected
            if let index = selectedOptions.firstIndex(of: sender) {
                selectedOptions.remove(at: index)
            }
        }
            
        // Enable signUpButton if any option is selected, disable otherwise
        signUpButton.isEnabled = !selectedOptions.isEmpty
    }

    @IBAction func signUpButtonClicked(_ sender: UIButton) {
        let selectedTitles = selectedOptions.map { $0.titleLabel?.text ?? "" }
        
        
        let userInfo = UserInfoManager.shared

        userInfo.setUserFoodCategory(selectedTitles)

        userInfo.printUserInfo()
        
        userInfo.sendUserInfoToServer(userInfo: userInfo.userInfo) { result in
            switch result {
            case .success:
                print("User information sent successfully!")
                self.performSegue(withIdentifier: "goToNext", sender: self)
            case .failure(let error):
                print("Error sending user information: \(error)")
            }
        }
        
        print("Sign up button clicked")
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
