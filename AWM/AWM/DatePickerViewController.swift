//
//  DatePickerViewController.swift
//  Regimen
//
//  Created by Alex Lai on 31/8/21.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet weak var dateTextField : UITextField!
    let datePicker = UIDatePicker()
    var callback : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
    }
    
    func createDatePicker() {
        dateTextField.textAlignment = .center
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([btnDone], animated: true)
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        dateTextField.inputView = datePicker
        
        datePicker.datePickerMode = .date
    }
    
    override func viewDidDisappear(_ animated : Bool) {
        super.viewDidDisappear(animated)
        callback?()
    }
    
    @objc func donePressed(){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        dateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
        defaults.set(formatter.string(from: datePicker.date), forKey: "UserDOB")
        dismiss(animated: true, completion: nil)
    }
}
