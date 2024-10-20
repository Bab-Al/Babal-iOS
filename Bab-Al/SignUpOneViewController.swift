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
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white

        // Set text field delegates
        ageTextField.delegate = self
        heightTextField.delegate = self
        weightTextField.delegate = self
        
        // Hide error messages initially
        ageRequiredMessage.isHidden = true
        heightRequiredMessage.isHidden = true
        weightRequiredMessage.isHidden = true
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
