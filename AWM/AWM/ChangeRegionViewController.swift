//
//  ChangeRegionViewController.swift
//  Regimen
//
//  Created by Alex Lai on 24/9/21.
//

import UIKit

class ChangeRegionViewController: UIViewController {
    
    @IBOutlet var pickerView: UIPickerView!
    
    var callback : (() -> Void)?
    
    @IBAction func btnSave(){
        defaults.set(selected, forKey: "UserRegion")
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated : Bool) {
        super.viewDidDisappear(animated)
        callback?()
    }

    var countries: [String] = []
    
    var selected: String {
        return defaults.string(forKey: "selected") ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
    }
    
    

}
extension ChangeRegionViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        defaults.set(countries[row], forKey: "selected")
    }
    
}

