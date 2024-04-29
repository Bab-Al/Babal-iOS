//
//  SignUpOneViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/28/24.
//

import UIKit

class SignUpOneViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var ageRequiredMessage: UILabel!
    
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var heightRequiredMessage: UILabel!
    
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var weightRequiredMessage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let userInfo = UserInfoManager.shared.userInfo

        
        // Set text field delegates
        ageTextField.delegate = self
        heightTextField.delegate = self
        weightTextField.delegate = self
        
        // Hide error messages initially
        ageRequiredMessage.isHidden = true
        heightRequiredMessage.isHidden = true
        weightRequiredMessage.isHidden = true
    }
    
    @IBAction func nextClicked(_ sender: UIButton) {
        // Check if any of the text fields are empty
        guard let age = ageTextField.text, !age.isEmpty,
            let height = heightTextField.text, !height.isEmpty,
            let weight = weightTextField.text, !weight.isEmpty else {
            // Show an error message or handle empty fields as needed
            ageRequiredMessage.isHidden = ageTextField.text?.isEmpty == false
            heightRequiredMessage.isHidden = heightTextField.text?.isEmpty == false
            weightRequiredMessage.isHidden = weightTextField.text?.isEmpty == false
            return
        }
        
        
        UserInfoManager.shared.setUserAge(Int(age)!)
        UserInfoManager.shared.setUserGender(genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex)!)
        UserInfoManager.shared.setUserHeight(Int(height)!)
        UserInfoManager.shared.setUserWeight(Int(weight)!)
        UserInfoManager.shared.printUserInfo()


        self.performSegue(withIdentifier: "goToNext", sender: self)

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
