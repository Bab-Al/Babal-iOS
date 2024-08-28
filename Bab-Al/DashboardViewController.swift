//
//  DashboardViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/29/24.
//

import UIKit
import FSCalendar
import Foundation
import Alamofire

class DashboardViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, CalendarDelegate {

    @IBOutlet weak var statsButton: UIButton!
    
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var weeklyCalendarView: FSCalendar!
    
    @IBOutlet weak var userTotalKcalLabel: UILabel!
    @IBOutlet weak var userNowKcalLabel: UILabel!
    @IBOutlet weak var userCarboLabel: UILabel!
    @IBOutlet weak var userProteinLabel: UILabel!
    @IBOutlet weak var userFatLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var breakfastView: UIView!
    @IBOutlet weak var lunchView: UIView!
    @IBOutlet weak var dinnerView: UIView!
    
    
    @IBOutlet weak var breakfastImageView: UIImageView!
    @IBOutlet weak var breakfastNameLabel: UILabel!
    @IBOutlet weak var breakfastKcalLabel: UILabel!
    @IBOutlet weak var breakfastUploadButton: UIButton!
    
    @IBOutlet weak var lunchImageView: UIImageView!
    @IBOutlet weak var lunchNameLabel: UILabel!
    @IBOutlet weak var lunchKcalLabel: UILabel!
    @IBOutlet weak var lunchUploadButton: UIButton!
    
    @IBOutlet weak var dinnerImageView: UIImageView!
    @IBOutlet weak var dinnerNameLabel: UILabel!
    @IBOutlet weak var dinnerKcalLabel: UILabel!
    @IBOutlet weak var dinnerUploadButton: UIButton!
    
    
    var selectedImageView: UIImageView?
    var selectedUploadButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        weeklyCalendarView.dataSource = self
        weeklyCalendarView.delegate = self
        weeklyCalendarView.scope = .week
                
        configureMealViews()
    }
    
    func configureMealViews() {        
        breakfastView.layer.cornerRadius = 10
        lunchView.layer.cornerRadius = 10
        dinnerView.layer.cornerRadius = 10
    }
    
    
    private func configureItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: nil)
    }
    
    
    @IBAction func StatsClicked(_ sender: UIButton) {
    }
    
    
    @IBAction func CalendarClicked(_ sender: UIButton) {
        print("Calendar Button clicked")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let monthlyCalendarVC = storyboard.instantiateViewController(withIdentifier: "MonthlyCalendarViewController") as? MonthlyCalendarViewController {
            monthlyCalendarVC.modalPresentationStyle = .popover
            monthlyCalendarVC.popoverPresentationController?.sourceView = sender
            monthlyCalendarVC.popoverPresentationController?.sourceRect = sender.bounds
            monthlyCalendarVC.delegate = self // Set the delegate
            present(monthlyCalendarVC, animated: true, completion: nil)
        }
    }
    
    // CalendarDelegate method
    func didSelectDate(_ date: Date) {
        weeklyCalendarView.setCurrentPage(date, animated: true)
        weeklyCalendarView.select(date)
    }
    
    // FSCalendar delegate method
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        fetchData(for: date)
    }
    
    @IBAction func uploadBreakfastImage(_ sender: UIButton) {
//        performSegue(withIdentifier: "showBreakfast", sender: sender)
    }
    
    @IBAction func uploadLunchImage(_ sender: UIButton) {
//        performSegue(withIdentifier: "showLunch", sender: sender)
    }

    @IBAction func uploadDinnerImage(_ sender: UIButton) {
//        performSegue(withIdentifier: "showDinner", sender: sender)
    }
    
    func presentImagePicker(for imageView: UIImageView, uploadButton: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        // Pass the imageView and button to be updated
        self.selectedImageView = imageView
        self.selectedUploadButton = uploadButton
        present(imagePicker, animated: true, completion: nil)
    }
    
}

protocol CalendarDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}


extension DashboardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func fetchData(for date: Date) {
        // Format the date as a string in the format required by API
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // Construct the URL with the date
        let urlString = "http://hongik-babal.ap-northeast-2.elasticbeanstalk.com/main/history?date=\(dateString)"
        
        // Retrieve the token from UserInfoManager
        let token = UserInfoManager.shared.token!
        print("Token sending: \(token)")
                
        // Alamofire GET request
        AF.request(urlString, method: .get, headers: ["Authorization": "Bearer \(token)", "accept":"application/json"])
            .validate(statusCode: 200..<300) // Validates the response
            .responseDecodable(of: ResponseData.self) { response in
                switch response.result {
                case .success(let data):
                    print("Received decoded data: \(data)")
                    
                    // Update the UI on the main thread
                    DispatchQueue.main.async {
                        self.updateUI(with: data.result)
                    }
                    
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
    }
    
    func updateUI(with data: MealData?) {
        guard let data = data else {
            // Handle the case where data is nil
            self.userTotalKcalLabel.text = "no..."
            self.userNowKcalLabel.text = "no..."
            self.userCarboLabel.text = "no..."
            self.userProteinLabel.text = "no..."
            self.userFatLabel.text = "no..."
            
            self.breakfastNameLabel.text = "no..."
            self.breakfastKcalLabel.text = "no..."
                    
            self.lunchNameLabel.text = "no..."
            self.lunchKcalLabel.text = "no..."
                    
            self.dinnerNameLabel.text = "no..."
            self.dinnerKcalLabel.text = "no..."
            
            return
        }
        
        // Update UILabels with the data or "..." if the value is nil
        self.userTotalKcalLabel.text = data.userTotalKcal.map { "\($0)" } ?? "..."
        self.userNowKcalLabel.text = data.userNowKcal.map { "\($0)" } ?? "..."
        self.userCarboLabel.text = data.userCarbo.map { "\($0)g" } ?? "..."
        self.userProteinLabel.text = data.userProtein.map { "\($0)g" } ?? "..."
        self.userFatLabel.text = data.userFat.map { "\($0)g" } ?? "..."
        
        self.breakfastNameLabel.text = data.breakfastName?.isEmpty == false ? data.breakfastName : "..."
        self.breakfastKcalLabel.text = data.breakfastKcal.map { "\($0) kcal" } ?? "..."
        
        self.lunchNameLabel.text = data.lunchName?.isEmpty == false ? data.lunchName : "..."
        self.lunchKcalLabel.text = data.lunchKcal.map { "\($0) kcal" } ?? "..."
        
        self.dinnerNameLabel.text = data.dinnerName?.isEmpty == false ? data.dinnerName : "..."
        self.dinnerKcalLabel.text = data.dinnerKcal.map { "\($0) kcal" } ?? "..."
        
    }
    
    
    
    func updateImageView(_ imageView: UIImageView, with urlString: String) {
        // Load the image asynchronously
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
            
        // Update the appropriate image view and hide the upload button
        selectedImageView?.image = selectedImage
        selectedUploadButton?.isHidden = true
        
        picker.dismiss(animated: true, completion: nil)
        
        // Example data to send along with the image
        let mealtime: String
        let foodName: String = "Sample Food"
        let carbohydrate: Int = 30
        let protein: Int = 10
        let fat: Int = 5
        let date = Date() // Or use any specific date
                
//        if selectedImageView == breakfastImageView {
//            mealtime = "BREAKFAST"
//        } else if selectedImageView == lunchImageView {
//            mealtime = "LUNCH"
//        } else {
//            mealtime = "DINNER"
//        }
        
        // Upload the image along with the other data and the formatted date
//        uploadImage(selectedImage, for: mealtime, date: date, foodName: foodName, carbohydrate: carbohydrate, protein: protein, fat: fat)
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImage(_ image: UIImage, for mealtime: String, date: Date, foodName: String, carbohydrate: Int, protein: Int, fat: Int) {
        guard let url = URL(string: "http://hongik-babal.ap-northeast-2.elasticbeanstalk.com/main/history") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(String(describing: UserInfoManager.shared.getAuthToken()))", forHTTPHeaderField: "Authorization")
        
        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.9) else { return }
        
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // Create a unique boundary for the multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Append mealtime field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"mealtime\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(mealtime)\r\n".data(using: .utf8)!)
        
        // Append carbohydrate field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"carbohydrate\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(carbohydrate)\r\n".data(using: .utf8)!)
        
        // Append protein field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"protein\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(protein)\r\n".data(using: .utf8)!)
        
        // Append fat field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"fat\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(fat)\r\n".data(using: .utf8)!)
        
        // Append foodName field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"foodName\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(foodName)\r\n".data(using: .utf8)!)
        
        // Append image file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"foodImage\"; filename=\"\(dateString)_\(mealtime).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End the multipart form data
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Create a data task to send the POST request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            
            // Handle the response here
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Image and data uploaded successfully")
            } else {
                print("Failed to upload image and data")
            }
        }
        
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MealRecordingViewController {
            if segue.identifier == "showBreakfast" {
                destinationVC.mealType = "BREAKFAST"
            } else if segue.identifier == "showLunch" {
                destinationVC.mealType = "LUNCH"
            } else if segue.identifier == "showDinner" {
                destinationVC.mealType = "DINNER"
            }
        }
    }

}

// Define the struct matching your JSON structure
struct MealData: Decodable {
    let userTotalKcal: Int?
    let userNowKcal: Int?
    let userCarbo: Int?
    let userProtein: Int?
    let userFat: Int?
    let breakfastName: String?
    let breakfastKcal: Int?
    let lunchName: String?
    let lunchKcal: Int?
    let dinnerName: String?
    let dinnerKcal: Int?
}

struct ResponseData: Decodable {
    let result: MealData?
}
