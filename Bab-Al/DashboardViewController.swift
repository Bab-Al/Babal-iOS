//
//  DashboardViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/29/24.
//

import UIKit
import FSCalendar

class DashboardViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, CalendarDelegate {

    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var weeklyCalendarView: FSCalendar!
    
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
    
    // CalendarDelegate method
    func didSelectDate(_ date: Date) {
        weeklyCalendarView.setCurrentPage(date, animated: true)
        weeklyCalendarView.select(date)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showMonthlyCalendar" {
//            if let monthlyCalendarVC = segue.destination as? MonthlyCalendarViewController {
//                monthlyCalendarVC.delegate = self
//                if let popoverPresentationController = monthlyCalendarVC.popoverPresentationController {
//                    popoverPresentationController.sourceView = calendarButton
//                    popoverPresentationController.sourceRect = calendarButton.bounds
//                }
//            }
//        }
//    }
    
}

protocol CalendarDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}
