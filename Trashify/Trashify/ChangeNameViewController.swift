//
//  ChangeNameViewController.swift
//  Regimen
//
//  Created by Alex Lai on 23/9/21.
//

import UIKit

class ChangeNameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField : UITextField!
    var callback : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self
    }
    
    
    override func viewDidDisappear(_ animated : Bool) {
        super.viewDidDisappear(animated)
        callback?()
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == false {
            if nameTextField.text?.isStringAnInt() == false {
                if containsLetters(input: nameTextField.text!){
                    self.view.endEditing(true)
                    defaults.set(nameTextField.text, forKey: "UserName")
                    callback?()
                    dismiss(animated: true, completion: nil)
                    return true
                }
                else{
                    let alert = UIAlertController(title: "Name Error", message: "Please Enter a Valid Name. Name cannot only contain symbols", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Okay", style: .default)
                    alert.addAction(okayAction)
                    present(alert, animated: true, completion: nil)
                    return false
                }
                
            }
            else {
                let alert = UIAlertController(title: "Name Error", message: "Please Enter a Valid Name. Using numbers as name is now allowed", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default)
                alert.addAction(okayAction)
                present(alert, animated: true, completion: nil)
                return false
            }
                
        }
        else {
            let alert = UIAlertController(title: "Name Error", message: "Please Enter a Valid Name. Using space as name is now allowed", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default)
            alert.addAction(okayAction)
            present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
        
    func containsLetters(input: String) -> Bool {
        if input.rangeOfCharacter(from: CharacterSet.letters) != nil {
            return true
        }
       return false
    }


}; extension String
{
    func isStringAnInt() -> Bool {
        
        if let _ = Int(self) {
            return true
        }
        return false
    }
}
