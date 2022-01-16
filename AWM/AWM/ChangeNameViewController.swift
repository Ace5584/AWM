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
        self.view.endEditing(true)
        defaults.set(nameTextField.text, forKey: "UserName")
        callback?()
        dismiss(animated: true, completion: nil)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}
