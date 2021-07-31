//
//  ViewController.swift
//  SeeFood
//
//  Created by JI XIANG on 31/7/21.
//

import UIKit
import CoreML
import Vision //help us process images more easily and allow us to use images to work with CoreML without writing alot of codes

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController() //to use the camera function.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self //self means this class.
        imagePicker.sourceType = .camera //sets the imagepicker source to the phone's camera.
        //imagePicker.sourceType = .photoLibrary //to use photos from the photo library
        imagePicker.allowsEditing = false //but you can make it true if you want to enable user to crop the image
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage { //downcast to UIImage
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {fatalError("Could not convert UIImage into CIImage")}
            //converting userPickedImage into a Core Image image (CIImage)
            //CIImage allow us to use the vision framwork and the CoreML framework in order to get an interpretation from ML model
            
            detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        //Load up the Inceptionv3 model
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: MLModelConfiguration()).model) else {//write the model name
            fatalError("Loading CoreML Model Failed.")
        }
        
        //try? is going to attempt to perform this operation that might throw an error.If this operation succeeds, then the result is going to be wrapped as a optional. But if it fails, then the result of this line will be nil.
        //VNCoreMLModel comes from the Vision framework and allow us to perform an image analysis requests that uses our CoreML Model to process images.
        
        //Create a request that asked the model to classify whatever data that we pass in.
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else { //downcast to an array of VNClassi...
                fatalError("Model failed to process image.")
            }
            
            // print(results) //to see what we get back from the model
            if let firstResult = results.first { //the model returns the first result which is the highest confidence
                if firstResult.identifier.contains("hotdog") { //check if the first result contains the word: hotdog
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                }
            }
        }
        
         //Create a handler that specifies the image we want to classify
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request]) //perform the request to classify the image
        } catch {
            print(error)
        }
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil) //completion set to nil becuz we dont want anything to happen after finish presenting that imagePicker.
        //present the imagePicker to the user so that they can use the camera or use the photo album to pick an image
        
        
    }
    
}


