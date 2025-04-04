//
//  CreateCompViewController.swift
//  A3_IOS
//
//  Created by Eshitha B on 4/4/25.
//

import UIKit

class CreateCompViewController: UIViewController {

    @IBOutlet weak var dateField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let datePicker = UIDatePicker ()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector (dateChange (datePicker:)), for:
        UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        dateField.inputView = datePicker
        dateField.text = formatDate(date: Date()) // todays Date
    }
   
    @objc func dateChange(datePicker: UIDatePicker) {
        dateField.text = formatDate(date: datePicker.date)
    }
    
    func formatDate (date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        return formatter.string (from: date)
    }
    

}
