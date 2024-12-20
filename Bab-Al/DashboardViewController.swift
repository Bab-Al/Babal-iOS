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
    
    @IBOutlet weak var nutriView: UIView!
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
        weeklyCalendarView.appearance.borderRadius = 0.5
        weeklyCalendarView.appearance.calendar.headerHeight = 26
        weeklyCalendarView.appearance.calendar.weekdayHeight = 30
        weeklyCalendarView.appearance.titleFont = .systemFont(ofSize: 18.0)
        weeklyCalendarView.appearance.todayColor = UIColor(red: 156/255, green: 174/255, blue: 172/255, alpha: 1)
        weeklyCalendarView.appearance.selectionColor = UIColor(red: 253/255, green: 177/255, blue: 55/255, alpha: 1)
                
        configureNutriView()
        configureMealViews()
//        let today = Date()
//        fetchData(for: today)
    }
    
    func configureNutriView() {
        nutriView.layer.cornerRadius = 10
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
        self.userTotalKcalLabel.text = data.userTotalKcal.map { "\($0) kcal" } ?? "..."
        self.userNowKcalLabel.text = data.userNowKcal.map { "\($0)" } ?? "..."
        self.userCarboLabel.text = data.userCarbo.map { "\($0) g" } ?? "..."
        self.userProteinLabel.text = data.userProtein.map { "\($0) g" } ?? "..."
        self.userFatLabel.text = data.userFat.map { "\($0) g" } ?? "..."
        
        self.breakfastNameLabel.text = data.breakfastName?.isEmpty == false ? data.breakfastName : "Not recorded yet..."
        self.breakfastKcalLabel.text = data.breakfastKcal.map { "\($0) kcal" } ?? "0 kcal"
        
        self.lunchNameLabel.text = data.lunchName?.isEmpty == false ? data.lunchName : "Not recorded yet..."
        self.lunchKcalLabel.text = data.lunchKcal.map { "\($0) kcal" } ?? "0 kcal"
        
        self.dinnerNameLabel.text = data.dinnerName?.isEmpty == false ? data.dinnerName : "Not recorded yet..."
        self.dinnerKcalLabel.text = data.dinnerKcal.map { "\($0) kcal" } ?? "0 kcal"
        
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
