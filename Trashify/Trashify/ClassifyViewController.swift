//
//  ClassifyViewController.swift
//  AWM
//
//  Created by Alex Lai on 13/7/21.
//

import UIKit
import CoreML
import Vision
import ImageIO

public let defaults = UserDefaults.standard

class ClassifyViewController: UIViewController {
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedItem = sender as? Int else{
            return
        }
        if segue.identifier == "AfterClassificationSegue"{
            guard let destinationVC = segue.destination as? AfterClassificationViewController else{
                return
            }
            destinationVC.index = selectedItem
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableAfterClassificationScene(_:)), name: Notification.Name("AfterClassification"), object: nil)
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            print("Hello. 5")
            let config = MLModelConfiguration()
            let model = try VNCoreMLModel(for: EightClassClassification(configuration: config).model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
            
        } catch {
            fatalError("Failed to load ML Model: \(error)")
        }
    }()
    
    func updateClassifications(for image: UIImage) {
        print("Hello. 4")
        classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).")}
        
        DispatchQueue.global(qos: .userInitiated).async{
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do{
                try handler.perform([self.classificationRequest])
                if(self.isKeyPresentInUserDefaults(key: "ClassifyPicture")){
                    var data = UserDefaults.standard.object(forKey: "ClassifyPicture") as! [NSData]
                    data.append(image.pngData()! as NSData)
                    defaults.set(data, forKey: "ClassifyPicture")
                    print("Save Image Exist")
                }
                else{
                    let imageData = [image.pngData()! as NSData]
                    defaults.set(imageData, forKey: "ClassifyPicture")
                    print("Save Image New")
                }
            } catch {
                print("Failed to perform classification. \n \(error.localizedDescription)")
            }
        }
        
    }
    
    func processClassifications(for request: VNRequest,  error: Error?){
        print("Hello. 3")
        // Where the classification happens
        DispatchQueue.main.async {
            guard let results = request.results else{
                self.classificationLabel.text = "Unable to classify Image. \n\(error!.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                let topClassifications = classifications.prefix(1) // Get only top one result
//                let descriptions = topClassifications.map { classification in
//                    return String(format: " (%.2f) %@", classification.confidence, classification.identifier)
//                }
                print(topClassifications[0].confidence)
                var confidence = String(format: "%.2f", topClassifications[0].confidence)
                var fConfidence = Float(confidence)
                fConfidence = (fConfidence ?? 0)*100.0
                confidence = String(describing: round(fConfidence!))
                let classification = String(format: "%@", topClassifications[0].identifier)
                var description = confidence+"%|"+classification
                self.classificationLabel.text = "Classification: \n" + description
                let formatter = DateFormatter()
                let currentDateTime = Date()
                formatter.timeStyle = .medium
                formatter.dateStyle = .medium
                let DateTime = formatter.string(from: currentDateTime)
                description = description+"|"+DateTime
                description = description+"|"+self.binColor(trashType: classification)
                var index = 0
                if(self.isKeyPresentInUserDefaults(key: "ClassifyResult")){
                    var data = UserDefaults.standard.object(forKey: "ClassifyResult") as! [String]
                    index = data.count
                    data.append(description)
                    defaults.set(data, forKey: "ClassifyResult")
                    NotificationCenter.default.post(name: Notification.Name("AfterClassification"), object: index)
                    print("Save Data Exist", description)
                }
                else{
                    defaults.set([description], forKey: "ClassifyResult")
                    NotificationCenter.default.post(name: Notification.Name("AfterClassification"), object: index)
                    print("Save Data New", description)
                }
                
            }
        }
    }
    
    @IBAction func takePicture() {
        print("Take Picture Drop Down Menu")
        if(self.isKeyPresentInUserDefaults(key: "ClassifyResult")){
            let data = UserDefaults.standard.object(forKey: "ClassifyResult") as! [String]
            print(data)
        }
        else{
            print("ClassifyResult does not exist")
        }
        if(self.isKeyPresentInUserDefaults(key: "ClassifyPicture")){
            let data = UserDefaults.standard.object(forKey: "ClassifyPicture") as! [NSData]
            print(data.count)
        }
        else{
            print("ClassifyPicture does not exist")
        }
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    @objc func enableAfterClassificationScene(_ notification: Notification){
        if(isEditing == false){
            let index = notification.object as? Int ?? 0
            
            self.performSegue(withIdentifier: "AfterClassificationSegue", sender: index)
            
        }
    }
    
    private func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    private func binColor(trashType: String) -> String{
        var binColor: String!
        
        if trashType == "battery"{
            binColor = "Special"
        }
        else if trashType == "biological"{
            binColor = "Green"
        }
        else if trashType == "cardboard"{
            binColor = "Yellow"
        }
        else if trashType == "clothes"{
            binColor = "Red"
        }
        else if trashType == "glass"{
            binColor = "Red"
        }
        else if trashType == "metal"{
            binColor = "Yellow"
        }
        else if trashType == "paper"{
            binColor = "Yellow"
        }
        else if trashType == "plastic"{
            binColor = "Yellow"
        }
        
        return binColor
    }
}

extension ClassifyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        updateClassifications(for: image)
    }
}
