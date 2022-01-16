//
//  StaticTableViewController.swift
//  Regimen
//
//  Created by Alex Lai on 29/8/21.
//

import UIKit

class StaticTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cells = [["Profile"], ["ChangeName", "ChangeProfile", "ChangeRegion", "ChangeDOB"]]
    var userName = "#Name"
    var userRegion = "#Region"
    var userDOB = "#Date of Birth"
    
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelRegion: UILabel!
    @IBOutlet weak var labelDOB: UILabel!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = profilePicture.bounds.width / 2
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderWidth = 3
        profilePicture.layer.borderColor = UIColor.systemTeal.cgColor
        checkData()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DateSelectorSegue"{
            let destination = segue.destination as! DatePickerViewController // change that to the real class
            destination.callback = {
                self.checkData()
            }
        }
        else if segue.identifier == "ChangeNameSegue"{
            let destination = segue.destination as! ChangeNameViewController // change that to the real class
            destination.callback = {
                self.checkData()
            }
        }
        else if segue.identifier == "ChangeRegionSegue"{
            let destination = segue.destination as! ChangeRegionViewController // change that to the real class
            destination.callback = {
                self.checkData()
            }
        }
        else{
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return cells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cells[section].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == [1, 0]{
            self.performSegue(withIdentifier: "ChangeNameSegue", sender: self)

        }
        else if indexPath == [1, 1]{
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            present(picker, animated: true)
        }
        else if indexPath == [1, 2]{
            self.performSegue(withIdentifier: "ChangeRegionSegue", sender: self)
        }
        else if indexPath == [1, 3]{
            self.performSegue(withIdentifier: "DateSelectorSegue", sender: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        profilePicture.image = image
        
        let imageData = profilePicture.image!.pngData()! as NSData
        defaults.set(imageData, forKey: "ProfilePicture")
        
        dismiss(animated: true)
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
        labelDOB.text = userDOB
    }
}
