//
//  MealRecordingViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 8/23/24.
//

import UIKit
import Alamofire
import Foundation
import Photos

class MealRecordingViewController: UIViewController {
    
    var mealType: String?
    
    @IBOutlet weak var mealtypeLabel: UILabel!
    
    @IBOutlet weak var uploadedImageView: UIImageView!
    
    @IBOutlet weak var foodnameTextField: UITextField!
    @IBOutlet weak var carbohydrateTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealtypeLabel.text = mealType
    }
    
    @IBAction func uploadPhotoButton(_ sender: UIButton) {
        showPhotoOptions()
    }
    
    func showPhotoOptions() {
        let actionSheet = UIAlertController(title: "Upload Photo", message: "Choose an option", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Take picture", style: .default, handler: { action in
            self.openCamera()
        }))

        actionSheet.addAction(UIAlertAction(title: "Select from photos", style: .default, handler: { action in
            self.openPhotoLibrary()
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // For iPad compatibility
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
        }

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera not available", message: "The camera is not available on this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        guard let mealtime = mealtypeLabel.text,
              let carbohydrateText = carbohydrateTextField.text, let carbohydrate = Int(carbohydrateText),
              let proteinText = proteinTextField.text, let protein = Int(proteinText),
              let fatText = fatTextField.text, let fat = Int(fatText),
              let foodName = foodnameTextField.text else {
            print("Error: Invalid input")
            return
        }
        
        // Create the parameters dictionary (JSON)
        let parameters: [String: Any] = [
            "mealtime": mealtime,
            "carbohydrate": carbohydrate,
            "protein": protein,
            "fat": fat,
            "foodName": foodName
        ]
        
        // Define the URL for the POST request
        let url = "http://hongik-babal.ap-northeast-2.elasticbeanstalk.com/main/history"
        
        let token = UserInfoManager.shared.token!
        print("Token sending: \(token)")
        
        // Make the POST request using Alamofire
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(token)", "accept":"application/json"])
            .validate(statusCode: 200..<300)
            .responseDecodable(of: MealResponse.self) { response in
                switch response.result {
                case .success(let mealResponse):
                    // Successfully decoded the response
                    print("Success: \(mealResponse.isSuccess)")
                    print("Message: \(mealResponse.message)")
                    
                    // If the upload was successful, go back to the previous screen
                    if mealResponse.isSuccess {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
}


extension MealRecordingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            uploadedImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            uploadedImageView.image = originalImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

struct MealResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: String
}
