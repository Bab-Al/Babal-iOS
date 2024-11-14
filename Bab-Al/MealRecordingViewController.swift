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
    var ngrokURL: String?
    
    @IBOutlet weak var mealtypeLabel: UILabel!
    
    @IBOutlet weak var uploadedImageView: UIImageView!
    
    @IBOutlet weak var foodnameTextField: UITextField!
    @IBOutlet weak var kcalTextField: UITextField!
    @IBOutlet weak var carbohydrateTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        mealtypeLabel.text = mealType
        
        fetchNgrokURLFromGoogleDrive { [weak self] url in
            self?.ngrokURL = url
            print("Fetched ngrok URL: \(url ?? "No URL")")
        }
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
                    self.view.transform = CGAffineTransform(translationX: 0, y: -130)
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }
    
    @IBAction func uploadPhotoButton(_ sender: UIButton) {
        showPhotoOptions()
    }
    
    func fetchNgrokURLFromGoogleDrive(completion: @escaping (String?) -> Void) {
        let googleDriveURL = "https://drive.google.com/uc?export=downloads&id=10aijQIdVoTc1Umfm864ObXNgxD81i7lJ"
        
        AF.request(googleDriveURL, method: .get, headers: ["accept":"application/json"])
            .validate(statusCode: 200..<300) // Validates the response
            .responseDecodable(of: NgrokResponse.self) { response in
                switch response.result {
                case .success(let data):
                    completion(data.public_url)
                case .failure(let error):
                    print("Error fetching URL from Google Drive: \(error)")
                    completion(nil)
                }
        }
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
              let carbohydrateText = carbohydrateTextField.text, let carbohydrate = Float(carbohydrateText)?.rounded(.down),
              let proteinText = proteinTextField.text, let protein = Float(proteinText)?.rounded(.down),
              let fatText = fatTextField.text, let fat = Float(fatText)?.rounded(.down),
              let caloriesText = kcalTextField.text, let calories = Float(caloriesText)?.rounded(.down),
              let foodName = foodnameTextField.text else {
            print("Error: Invalid input")
            return
        }
        
        // Convert floored `Float` values to `Int`
        let flooredCarbohydrate = Int(carbohydrate)
        let flooredProtein = Int(protein)
        let flooredFat = Int(fat)
        let flooredCalories = Int(calories)
        
        // Create the parameters dictionary (JSON)
        let parameters: [String: Any] = [
            "mealtime": mealtime,
            "carbohydrate": flooredCarbohydrate,
            "protein": flooredProtein,
            "fat": flooredFat,
            "calories": flooredCalories,
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
    func uploadImage(image: UIImage) {
        // Convert the UIImage to Data (JPEG or PNG format)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to data.")
            return
        }
        
        guard let ngrokURL = ngrokURL else {
            print("Ngrok URL is not available")
            return
        }
        
        // Append "/predict" to the ngrok URL
        let url = "\(ngrokURL)/predict"
        print("Using fetched ngrok URL: \(url)")
        
        // Set up the headers, including the authorization token
        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data"
        ]
        
        // Generate a random file name
        let fileName = "meal_photo_\(UUID().uuidString).jpg"
        
        // Use Alamofire to upload the image
        AF.upload(multipartFormData: { multipartFormData in
            // Add the image data as multipart form data
            multipartFormData.append(imageData, withName: "image", fileName: fileName, mimeType: "image/jpeg")
        }, to: url, method: .post, headers: headers)
        .responseDecodable(of: ImageUploadResponse.self) { response in
            switch response.result {
            case .success(let uploadResponse):
                print("Upload success: \(uploadResponse)")
                
                // If detected_classes is available, get the food_name and set it in the text field
                if let detectedClass = uploadResponse.detected_classes.first {
                    self.foodnameTextField.text = detectedClass.food_name
                }
                self.carbohydrateTextField.text = String(uploadResponse.carb)
                self.proteinTextField.text = String(uploadResponse.protein)
                self.fatTextField.text = String(uploadResponse.fat)
                self.kcalTextField.text = String(uploadResponse.kcal)
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        uploadedImageView.image = selectedImage
        
        picker.dismiss(animated: true, completion: nil)
        
        if let imageToUpload = selectedImage {
            uploadImage(image: imageToUpload)
        }
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

struct NgrokResponse: Decodable {
    let public_url: String
}

struct ImageUploadResponse: Decodable {
    let detected_classes: [DetectedClass]
    let carb: Float
    let protein: Float
    let fat: Float
    let kcal: Float
}

struct DetectedClass: Decodable {
    let food_name: String
}
