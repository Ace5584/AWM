//
//  PersonalViewController.swift
//  Regimen
//
//  Created by Alex Lai on 26/8/21.
//

import UIKit

class PersonalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelRegion: UILabel!
    
    var userName = "#Name"
    var userRegion = "#Region"
    var userDOB = "#Date of Birth"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.layer.cornerRadius = profilePicture.bounds.width / 2
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderWidth = 3
        profilePicture.layer.borderColor = UIColor.systemTeal.cgColor
        
        checkData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkData()
    }
    
    private func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    private func checkData(){
        if(isKeyPresentInUserDefaults(key: "ProfilePicture")){
            let data = UserDefaults.standard.object(forKey: "ProfilePicture") as! NSData
            profilePicture.image = UIImage(data: data as Data)
        }
        else{
            let imageData = profilePicture.image!.pngData()! as NSData
            defaults.set(imageData, forKey: "ProfilePicture")
        }
        
        if(isKeyPresentInUserDefaults(key: "UserName")){
            let data = UserDefaults.standard.object(forKey: "UserName") as! String
            userName = data
        }
        else{
            defaults.set(userName, forKey: "UserName")
        }
        
        if(isKeyPresentInUserDefaults(key: "UserRegion")){
            let data = UserDefaults.standard.object(forKey: "UserRegion") as! String
            userRegion = data
        }
        else{
            defaults.set(userRegion, forKey: "UserRegion")
        }
        
        if(isKeyPresentInUserDefaults(key: "UserDOB")){
            let data = UserDefaults.standard.object(forKey: "UserDOB") as! String
            userDOB = data
        }
        else{
            defaults.set(userDOB, forKey: "UserDOB")
        }
        
        labelUserName.text = userName
        labelRegion.text = userRegion
    }
}
