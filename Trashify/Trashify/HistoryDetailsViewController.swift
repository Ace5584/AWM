//
//  HistoryDetailsViewController.swift
//  Trashify
//
//  Created by Alex Lai on 22/1/2022.
//

import UIKit

class HistoryDetailsViewController: UIViewController {
    
    @IBOutlet weak var binColorPhoto: UIImageView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var label: UILabel!
    var index: Int?
    var binColor: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        let dataLabel = UserDefaults.standard.object(forKey: "ClassifyResult") as! [String]
        label.text = dataLabel[index ?? 0]
        let dataPhoto = UserDefaults.standard.object(forKey: "ClassifyPicture") as! [NSData]
        photo.image = UIImage(data: dataPhoto[index ?? 0] as Data)
        
        let splitLabel = dataLabel[index ?? 0].components(separatedBy: "|")
        binColor = splitLabel[3]
        
        if binColor == "Green"{
            binColorPhoto.image = UIImage(named: "GreenTrashCan")
        }
        else if binColor == "Red"{
            binColorPhoto.image = UIImage(named: "RedTrashCan")
        }
        else if binColor == "Yellow"{
            binColorPhoto.image = UIImage(named: "YellowTrashCan")
        }

        // Do any additional setup after loading the view.
    }
    

}
