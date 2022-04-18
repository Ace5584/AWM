//
//  AfterClassificationViewController.swift
//  Trashify
//
//  Created by Alex Lai on 23/1/2022.
//

import UIKit

class AfterClassificationViewController: UIViewController {

    @IBOutlet weak var trashIcon: UIImageView!
    var index: Int?
    var binColor: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataLabel = UserDefaults.standard.object(forKey: "ClassifyResult") as! [String]
        let splitLabel = dataLabel[index ?? 0].components(separatedBy: "|")
        binColor = splitLabel[3]
        
        if binColor == "Green"{
            trashIcon.image = UIImage(named: "GreenTrashCan")
        }
        else if binColor == "Red"{
            trashIcon.image = UIImage(named: "RedTrashCan")
        }
        else if binColor == "Yellow"{
            trashIcon.image = UIImage(named: "YellowTrashCan")
        }
    }
    
}
