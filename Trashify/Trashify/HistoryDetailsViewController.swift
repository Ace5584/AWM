//
//  HistoryDetailsViewController.swift
//  Trashify
//
//  Created by Alex Lai on 22/1/2022.
//

import UIKit

class HistoryDetailsViewController: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var label: UILabel!
    var index: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        let dataLabel = UserDefaults.standard.object(forKey: "ClassifyResult") as! [String]
        label.text = dataLabel[index ?? 0]
        let dataPhoto = UserDefaults.standard.object(forKey: "ClassifyPicture") as! [NSData]
        photo.image = UIImage(data: dataPhoto[index ?? 0] as Data)

        // Do any additional setup after loading the view.
    }
    

}
