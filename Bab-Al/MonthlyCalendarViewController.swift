//
//  MontlyCalendarViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 7/31/24.
//

import UIKit
import FSCalendar

class MonthlyCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    var calendar: FSCalendar!
    weak var delegate: CalendarDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calendar = FSCalendar(frame: CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        self.view.addSubview(calendar)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // FSCalendar delegate method
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        delegate?.didSelectDate(date)
        dismiss(animated: true, completion: nil)
    }

}
