//
//  DashboardViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/29/24.
//

import UIKit
import FSCalendar
import Foundation

class DashboardViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, CalendarDelegate {

    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var weeklyCalendarView: FSCalendar!
    
    @IBOutlet weak var userTotalKcalLabel: UILabel!
    @IBOutlet weak var userNowKcalLabel: UILabel!
    @IBOutlet weak var userCarboLabel: UILabel!
    @IBOutlet weak var userProteinLabel: UILabel!
    @IBOutlet weak var userFatLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
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
        
        weeklyCalendarView.dataSource = self
        weeklyCalendarView.delegate = self
        weeklyCalendarView.scope = .week
    }
    
    
    private func configureItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: nil)
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
    
    @IBAction func uploadBreakfastImage(_ sender: UIButton) {
        presentImagePicker(for: breakfastImageView, uploadButton: breakfastUploadButton)
    }
    @IBAction func uploadLunchImage(_ sender: UIButton) {
        presentImagePicker(for: lunchImageView, uploadButton: lunchUploadButton)
    }
    @IBAction func uploadDinnerImage(_ sender: UIButton) {
        presentImagePicker(for: dinnerImageView, uploadButton: dinnerUploadButton)
    }
    
    // CalendarDelegate method
    func didSelectDate(_ date: Date) {
        weeklyCalendarView.setCurrentPage(date, animated: true)
        weeklyCalendarView.select(date)
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
    

    
    // FSCalendar delegate method
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        fetchData(for: date)
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
        guard let url = URL(string: urlString) else { return }
        
        // Create a URLRequest and set the HTTP method to GET
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Retrieve the token from UserInfoManager
        let token = UserInfoManager.shared.getAuthToken()
        
        request.setValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        
        // Create the GET request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                // Parse JSON
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                // Update the UI on the main thread
                DispatchQueue.main.async {
                    self.updateUI(with: json)
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func updateUI(with data: [String: Any]?) {
        guard let data = data else {
            // Handle the case where data is nil (placeholders or error messages)
            return
        }
        
        // Update UILabels
        if let userTotalKcal = data["userTotalKcal"] as? Int {
            self.userTotalKcalLabel.text = "\(userTotalKcal)"
        }
            
        if let userNowKcal = data["userNowKcal"] as? Int {
            self.userNowKcalLabel.text = "\(userNowKcal)"
        }
            
        if let userCarbo = data["userCarbo"] as? Int {
            self.userCarboLabel.text = "\(userCarbo)g"
        }
            
        if let userProtein = data["userProtein"] as? Int {
            self.userProteinLabel.text = "\(userProtein)g"
        }
            
        if let userFat = data["userFat"] as? Int {
            self.userFatLabel.text = "\(userFat)g"
        }
            
        // Update views
        if let breakfastName = data["breakfastName"] as? String {
            self.breakfastNameLabel.text = breakfastName
        }
            
        if let breakfastKcal = data["breakfastKcal"] as? Int {
            self.breakfastKcalLabel.text = "\(breakfastKcal) kcal"
        }
            
        if let breakfastImage = data["breakfastImage"] as? String, !breakfastImage.isEmpty {
            self.updateImageView(self.breakfastImageView, with: breakfastImage)
            self.breakfastUploadButton.isHidden = true
        } else {
            self.breakfastImageView.image = nil
            self.breakfastUploadButton.isHidden = false
        }
            
        if let lunchName = data["lunchName"] as? String {
            self.lunchNameLabel.text = lunchName
        }
            
        if let lunchKcal = data["lunchKcal"] as? Int {
            self.lunchKcalLabel.text = "\(lunchKcal) kcal"
        }
            
        if let lunchImage = data["lunchImage"] as? String, !lunchImage.isEmpty {
            self.updateImageView(self.lunchImageView, with: lunchImage)
            self.lunchUploadButton.isHidden = true
        } else {
            self.lunchImageView.image = nil
            self.lunchUploadButton.isHidden = false
        }
            
        if let dinnerName = data["dinnerName"] as? String {
            self.dinnerNameLabel.text = dinnerName
        }
            
        if let dinnerKcal = data["dinnerKcal"] as? Int {
            self.dinnerKcalLabel.text = "\(dinnerKcal) kcal"
        }
            
        if let dinnerImage = data["dinnerImage"] as? String, !dinnerImage.isEmpty {
            self.updateImageView(self.dinnerImageView, with: dinnerImage)
            self.dinnerUploadButton.isHidden = true
        } else {
            self.dinnerImageView.image = nil
            self.dinnerUploadButton.isHidden = false
        }
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
        
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

