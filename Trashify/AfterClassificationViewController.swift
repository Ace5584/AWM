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
        let dataPhoto = UserDefaults.standard.object(forKey: "ClassifyPicture") as! [NSData]
        let dataLabel = UserDefaults.standard.object(forKey: "ClassifyResult") as! [String]
        let splitLabel = dataLabel[index ?? 0].components(separatedBy: "|")
        
        if splitLabel[1] == "battery"{
            binColor = "Special"
        }
        else if splitLabel[1] == "biological"{
            binColor = "Green"
        }
        else if splitLabel[1] == "cardboard"{
            binColor = "Yellow"
        }
        else if splitLabel[1] == "clothes"{
            binColor = "Red"
        }
        else if splitLabel[1] == "glass"{
            binColor = "Red"
        }
        else if splitLabel[1] == "metal"{
            binColor = "Yellow"
        }
        else if splitLabel[1] == "paper"{
            binColor = "Yellow"
        }
        else if splitLabel[1] == "plastic"{
            binColor = "Yellow"
        }
        
        print(binColor + " - " + splitLabel[1])
        
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
