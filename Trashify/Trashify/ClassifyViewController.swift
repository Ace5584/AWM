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

// Create a variable defaults to access the name space UserDefaults.standard quicker
public let defaults = UserDefaults.standard

class ClassifyViewController: UIViewController {
    
    // Initialize and link elements inside of the view controller
    @IBOutlet weak var imageView: UIImageView!       // An image view that displays the image of the classified trash
    @IBOutlet weak var classificationLabel: UILabel! // A label that displays the result of the classification
    @IBOutlet weak var cameraButton: UIButton!       // A button that pulls up image picker or camera when pressed
    
    // Overriding prepare function that prepares to open the next screen depending on which screen is selected
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // A code protection that makes sure the selected item is a valid integer
        guard let selectedItem = sender as? Int else{
            return
        }
        
        // Check if the segue that is being passed through is the segue that is wanted and in result prepare the segue
        if segue.identifier == "AfterClassificationSegue"{
            guard let destinationVC = segue.destination as? AfterClassificationViewController else{
                return
            }
            destinationVC.index = selectedItem
        }
    }
    
    // Function that runs as soon as this screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creating an observation that emables AfterClassification screen when it is requested throughout the program
        NotificationCenter.default.addObserver(self, selector: #selector(enableAfterClassificationScene(_:)), name: Notification.Name("AfterClassification"), object: nil)
    }
    
    // Creating a lazy var (a variable that will process only when requested to) that gets the request for the trained
    // Machine learning file
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // Create a configuration for the Machine Learning model to be inputted in
            let config = MLModelConfiguration()
            // attempt to import the model, will have a failsafe that errors out without crashing the app if the file
            // doesn't exist or is corrupted
            let model = try VNCoreMLModel(for: EightClassClassification(configuration: config).model)
            
            // Create a request for the Machine Learning Model so it can be used for classification
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            
            // Crop the image to the required scale
            request.imageCropAndScaleOption = .centerCrop
            
            // Return the Machine Learning Model Request created earlier
            return request
            
        } catch {
            // Display Error
            fatalError("Failed to load ML Model: \(error)")
        }
    }()
    
    // This function upadtes the classification of the iamge
    func updateClassifications(for image: UIImage) {
        
        classificationLabel.text = "Classifying..."
        
        // Get the correct orientation of the image
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        // Convert the UIImage into ciImage and creates a failsafe if the convertion is unsuccessful without crashing
        // the application
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).")}
        
        // This queues the tasks of performing classification in an async mode
        DispatchQueue.global(qos: .userInitiated).async{
            // Creating a image request handle to perform the classification
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do{
                // Attemp to perform the classification
                try handler.perform([self.classificationRequest])
                
                // Checks whether the key stores previously classified photos exist
                if(self.isKeyPresentInUserDefaults(key: "ClassifyPicture")){
                    // If the key exists, create a temporary variable that stores it and then append the new data
                    var data = UserDefaults.standard.object(forKey: "ClassifyPicture") as! [NSData]
                    data.append(image.pngData()! as NSData)
                    defaults.set(data, forKey: "ClassifyPicture")
                    print("Save Image Exist")
                }
                else{
                    // If the previous key does not exist, create the key and save the image as a list
                    let imageData = [image.pngData()! as NSData]
                    defaults.set(imageData, forKey: "ClassifyPicture")
                    print("Save Image New")
                }
            } catch {
                print("Failed to perform classification. \n \(error.localizedDescription)")
            }
        }
        
    }
    
    // Function that processes the classification when an image is imported
    func processClassifications(for request: VNRequest,  error: Error?){
        // Where the classification happens
        DispatchQueue.main.async {
            // Attemps to classify the image, with a failsafe to assign label if classification cannot be done
            guard let results = request.results else{
                self.classificationLabel.text = "Unable to classify Image. \n\(error!.localizedDescription)"
                return
            }
            
            // Make classification as VNClassification Type
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                // Format the results of the classification
                let topClassifications = classifications.prefix(1)                          // Get only top one result
                var confidence = String(format: "%.2f", topClassifications[0].confidence)
                var fConfidence = Float(confidence)
                fConfidence = (fConfidence ?? 0)*100.0
                confidence = String(describing: round(fConfidence!))
                let classification = String(format: "%@", topClassifications[0].identifier)
                var description = confidence+"%|"+classification
                
                // Assign the formatted result to a text label
                self.classificationLabel.text = "Classification: \n" + description
                
                // Get system date and then add it into the description for accessing this information in history page
                let formatter = DateFormatter()
                let currentDateTime = Date()
                formatter.timeStyle = .medium
                formatter.dateStyle = .medium
                let DateTime = formatter.string(from: currentDateTime)
                description = description+"|"+DateTime
                description = description+"|"+self.binColor(trashType: classification)
                
                // Checks whether ClassifyResult key exists in the system:
                    // - If it does exist, then it appends the data from this current classification
                    // - If it does not exist, create a new key that stores this result
                var index = 0
                if(self.isKeyPresentInUserDefaults(key: "ClassifyResult")){
                    var data = UserDefaults.standard.object(forKey: "ClassifyResult") as! [String]
                    index = data.count
                    data.append(description)
                    defaults.set(data, forKey: "ClassifyResult")
                    NotificationCenter.default.post(name: Notification.Name("AfterClassification"), object: index)
                }
                else{
                    defaults.set([description], forKey: "ClassifyResult")
                    NotificationCenter.default.post(name: Notification.Name("AfterClassification"), object: index)
                }
                
            }
        }
    }
    
    // A function that triggers when the button that takes the picture is clicked
    @IBAction func takePicture() {
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        // Options for the different options including photo picker and camera
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        // set and present the options
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(photoSourcePicker, animated: true)
    }
    
    // This function presents the photo picker
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    // This function enables and opens the next screen when triggered
    @objc func enableAfterClassificationScene(_ notification: Notification){
        if(isEditing == false){
            let index = notification.object as? Int ?? 0
            
            self.performSegue(withIdentifier: "AfterClassificationSegue", sender: index)
            
        }
    }
    
    // A function that checks whether something exist inside of userDefaults
    private func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil // Check whether the key exists and return boolean
    }
    
    // A function that determines which bin the classified trash should be in
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

// A function that requires other classes to controll the image picker
extension ClassifyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // update the classification box and the image of the classification
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        updateClassifications(for: image)
    }
}
