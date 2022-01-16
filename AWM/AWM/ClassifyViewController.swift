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
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    return String(format: " (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.classificationLabel.text = "Classification: \n" + descriptions.joined(separator: "\n")
            }
        }
    }
    
    @IBAction func takePicture() {
        print("Hello. 2")
        // Show options for the source picker only if the camera is available.
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
        print("Hello. 1")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
}

extension ClassifyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Hello.")
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        updateClassifications(for: image)
    }
}
