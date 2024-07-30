//
//  DashboardViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 4/29/24.
//

import UIKit
import FSCalendar

class DashboardViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var CalendarButton: UIButton!
    @IBOutlet weak var WeeklyCalendarView: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WeeklyCalendarView.dataSource = self
        WeeklyCalendarView.delegate = self
        WeeklyCalendarView.scope = .week
    }
    
//    @IBAction func logoutClicked(_ sender: UIButton) {
//        UserInfoManager.shared.logout()
//        print("Logout successful")
//        
//        self.performSegue(withIdentifier: "goToLogin", sender: self)
//    }
    
    private func configureItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func CalendarClicked(_ sender: UIButton) {
        print("Calendar Button clicked")
    }
    
}
