//
//  SignUpTwoViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/28/24.
//

import UIKit

class SignUpTwoViewController: UIViewController {
    
 
        
    @IBOutlet weak var levelOneButton: UIButton!
    @IBOutlet weak var levelTwoButton: UIButton!
    @IBOutlet weak var levelThreeButton: UIButton!
    @IBOutlet weak var levelFourButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let userInfo = UserInfoManager.shared.userInfo

        // Add action targets for the buttons
        levelOneButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        levelTwoButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        levelThreeButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        levelFourButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        
        // Disable nextButton initially
        nextButton.isEnabled = false
    }

    // Action method for handling button taps
    @objc func optionButtonTapped(_ sender: UIButton) {
        // Get the index of the tapped button
        guard let index = [levelOneButton, levelTwoButton, levelThreeButton, levelFourButton].firstIndex(of: sender) else {
                return // Button not found in the array
        }
            
        // Update the selected button index in UserInfo
        UserInfoManager.shared.userInfo.activity = index
            
        // Update button states
        [levelOneButton, levelTwoButton, levelThreeButton, levelFourButton].forEach { $0.isSelected = false }
        
        // Select the tapped button
        sender.isSelected = true
        
        // Enable nextButton if any option is selected
        nextButton.isEnabled = true
            
//        // Perform actions based on the selected option
//        switch sender {
//        case levelOneButton:
//            // Handle selection of option 1
//            print("Option 1 selected")
//        case levelTwoButton:
//            // Handle selection of option 2
//            print("Option 2 selected")
//        case levelThreeButton:
//            // Handle selection of option 3
//            print("Option 3 selected")
//        case levelFourButton:
//            // Handle selection of option 4
//            print("Option 4 selected")
//        default:
//            break
//        }
    }
    
    
    @IBAction func nextClicked(_ sender: UIButton) {
        print("Next Button clicked")
        
        
        UserInfoManager.shared.printUserInfo()
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
