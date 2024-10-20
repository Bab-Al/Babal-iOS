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
    
    @IBOutlet weak var carbohydrateChartView: LineChartView!
    @IBOutlet weak var proteinChartView: LineChartView!
    @IBOutlet weak var fatChartView: LineChartView!
    @IBOutlet weak var kcalChartView: LineChartView!
    
    var currentWeekStartDate: Date = Date()
    var currentWeekEndDate: Date = Date()
//    var token: String = UserInfoManager.shared.token ?? "n"
    let token = UserInfoManager.shared.token!

    
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
    
    @IBAction func moveToPreviousWeek() {
        // Move back one week
        currentWeekStartDate = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStartDate)!
        currentWeekEndDate = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekEndDate)!
        
        // Fetch data for the previous week
        fetchWeekData()
    }

    @IBAction func moveToNextWeek() {
        // Move forward one week
        currentWeekStartDate = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekStartDate)!
        currentWeekEndDate = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekEndDate)!
        
        // Fetch data for the next week
        fetchWeekData()
    }
    
    @IBAction func previousWeekButtonClicked(_ sender: UIButton) {
        currentWeekStartDate = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStartDate) ?? Date()
        updateWeekLabel()
    }
    
    @IBAction func nextWeekButtonClicked(_ sender: UIButton) {
        currentWeekStartDate = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekStartDate) ?? Date()
        updateWeekLabel()
    }
    
    func getCurrentWeek() {
        let calendar = Calendar.current
        let today = Date()

        // Get the start of the week (Monday)
        if let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) {
            currentWeekStartDate = weekStart
            // Get the end of the week (Sunday)
            currentWeekEndDate = calendar.date(byAdding: .day, value: 6, to: currentWeekStartDate)!
        }
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
        
        let url = "http://babal-env.ap-northeast-2.elasticbeanstalk.com/main/statistics"
        
        let parameters: [String: String] = [
            "startDate": startDateString,
            "endDate": endDateString
        ]
        
        print(startDateString)
        print(endDateString)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: StatisticsResponse.self) { response in
                switch response.result {
                case .success(let statisticsResponse):
                    if statisticsResponse.isSuccess {
                        DispatchQueue.main.async {
                            self.updateGraphs(with: statisticsResponse.result.data)
                        }
                    } else {
                        print("Request failed with message: \(statisticsResponse.message)")
                    }
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }
        
    }
    
    func updateGraphs(with data: [DayStatistics]) {
        let dates = data.map { $0.date }
        
        let carbohydrateValues = data.map { ChartDataEntry(x: Double(dates.firstIndex(of: $0.date) ?? 0), y: Double($0.carbohydrate)) }
        let proteinValues = data.map { ChartDataEntry(x: Double(dates.firstIndex(of: $0.date) ?? 0), y: Double($0.protein)) }
        let fatValues = data.map { ChartDataEntry(x: Double(dates.firstIndex(of: $0.date) ?? 0), y: Double($0.fat)) }
        let kcalValues = data.map { ChartDataEntry(x: Double(dates.firstIndex(of: $0.date) ?? 0), y: Double($0.kcal)) }
        
        updateChart(carbohydrateChartView, with: carbohydrateValues, dates: dates, label: "Carbohydrate")
        updateChart(proteinChartView, with: proteinValues, dates: dates, label: "Protein")
        updateChart(fatChartView, with: fatValues, dates: dates, label: "Fat")
        updateChart(kcalChartView, with: kcalValues, dates: dates, label: "Kcal")
    }
    
    func updateChart(_ chartView: LineChartView, with dataEntries: [ChartDataEntry], dates: [String], label: String) {
        let dataSet = LineChartDataSet(entries: dataEntries, label: label)
        dataSet.colors = [NSUIColor.blue]
        dataSet.circleColors = [NSUIColor.blue]
        
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
        
        // Set the custom x-axis formatter
            let dateFormatter = DateValueFormatter(dates: dates)
            chartView.xAxis.valueFormatter = dateFormatter
            chartView.xAxis.granularity = 1.0 // Ensure each label is shown
        
        chartView.notifyDataSetChanged()
    }
    
}

class DateValueFormatter: AxisValueFormatter {
    private let dateFormatter = DateFormatter()
    private var dates: [String]

    init(dates: [String]) {
        self.dates = dates
        dateFormatter.dateFormat = "MM/dd"
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        if index >= 0 && index < dates.count {
            return dateFormatter.string(from: convertToDate(from: dates[index]))
        } else {
            return ""
        }
    }

    private func convertToDate(from dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }
}


struct DayStatistics: Codable {
    let date: String
    let carbohydrate: Int
    let protein: Int
    let fat: Int
    let kcal: Int
}

struct StatisticsResult: Codable {
    let data: [DayStatistics]
}

struct StatisticsResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: StatisticsResult
}
