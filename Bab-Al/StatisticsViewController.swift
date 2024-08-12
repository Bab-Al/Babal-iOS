//
//  StatisticsViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 8/12/24.
//

import UIKit
import FSCalendar

class StatisticsViewController: UIViewController {

    @IBOutlet weak var dashboardButton: UIButton!
    
    @IBOutlet weak var weekLabel: UILabel!
    
    var currentWeekStartDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        currentWeekStartDate = getStartOfWeek(date: Date()) // Set to current week's Monday
        updateWeekLabel()
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

}
