//
//  StatisticsViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 8/12/24.
//

import UIKit
import FSCalendar
import Foundation
import Alamofire
import Charts

class StatisticsViewController: UIViewController {

    @IBOutlet weak var dashboardButton: UIButton!
    
    @IBOutlet weak var weekLabel: UILabel!
    
    
    var currentWeekStartDate: Date = Date()
    var currentWeekEndDate: Date = Date()
    var token: String = UserInfoManager.shared.token ?? "n"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        currentWeekStartDate = getStartOfWeek(date: Date()) // Set to current week's Monday
        updateWeekLabel()
        fetchWeekData()
    }
    
    @IBAction func DashboardButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func previousWeekButtonClicked(_ sender: UIButton) {
        currentWeekStartDate = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStartDate) ?? Date()
        updateWeekLabel()
    }
    
    @IBAction func nextWeekButtonClicked(_ sender: UIButton) {
        currentWeekStartDate = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekStartDate) ?? Date()
        updateWeekLabel()
    }
    
    
    func getStartOfWeek(date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    func getEndOfWeek(startingFrom startDate: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: 6, to: startDate) ?? startDate
    }
    
    func updateWeekLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        
        let endOfWeekDate = getEndOfWeek(startingFrom: currentWeekStartDate)
        
        let startOfWeekString = dateFormatter.string(from: currentWeekStartDate)
        let endOfWeekString = dateFormatter.string(from: endOfWeekDate)
        
        weekLabel.text = "\(startOfWeekString) - \(endOfWeekString)"
    }
    
    func fetchWeekData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDateString = dateFormatter.string(from: currentWeekStartDate)
        let endDateString = dateFormatter.string(from: currentWeekEndDate)
        
        let url = "http://hongik-babal.ap-northeast-2.elasticbeanstalk.com/main/statistics"
        
        let parameters: [String: String] = [
            "startDate": startDateString,
            "endDate": endDateString
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, parameters: parameters, headers: headers).responseDecodable(of: StatisticsResponse.self) { response in
            switch response.result {
            case .success(let statisticsResponse):
                DispatchQueue.main.async {
                    self.updateGraphs(with: statisticsResponse.data)
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
        
    }
    
    func updateGraphs(with data: [DayStatistics]) {
        // Update your charts here
    }
}

struct DayStatistics: Codable {
    let date: String
    let carbohydrate: Int
    let protein: Int
    let fat: Int
    let kcal: Int
}

struct StatisticsResponse: Codable {
    let data: [DayStatistics]
}
