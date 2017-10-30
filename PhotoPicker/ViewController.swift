//
//  ViewController.swift
//  PhotoPicker
//
//  Created by Taiwen Jin on 10/18/17.
//  Copyright © 2017 Virginia Tech. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    let imagePicker = UIImagePickerController()

    @IBOutlet var chooseButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Photo Source", message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) -> Void in
            self.openPhotoLibrary()
        })
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            self.openCamera()
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelButton)
        alertController.popoverPresentationController?.sourceView = sender
        alertController.popoverPresentationController?.sourceRect = sender.bounds
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        if let chosenImage = imageView.image {
            let imageData = UIImageJPEGRepresentation(chosenImage, 1)
            let base64String = imageData!.base64EncodedString()
            let parameters = ["imageString" : base64String] as [String : Any]
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            let request = NSMutableURLRequest(url: URL(string: "http://192.168.1.202:8080/InstantPhoto/PhotoPickerServlet")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                if let requestError = error {
                    let alertController = UIAlertController(title: "Http Request Error", message: "\(requestError)", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                        self.chooseButton.isEnabled = true
                        self.uploadButton.isEnabled = true
                    })
                    alertController.addAction(okButton)
                    alertController.popoverPresentationController?.sourceView = sender
                    alertController.popoverPresentationController?.sourceRect = sender.bounds
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                if let httpURLResponse = response as? HTTPURLResponse {
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    alertController.popoverPresentationController?.sourceView = sender
                    alertController.popoverPresentationController?.sourceRect = sender.bounds
                    let successButton = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                        self.imageView.image = nil
                        self.chooseButton.isEnabled = true
                        self.uploadButton.isEnabled = true
                    })
                    let errorButton = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                        self.chooseButton.isEnabled = true
                        self.uploadButton.isEnabled = true
                    })
                    if (httpURLResponse.statusCode == 200) {
                        alertController.title = "Upload Success"
                        alertController.addAction(successButton)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        alertController.title = "Upload Failed"
                        alertController.message = "Please try to upload again"
                        alertController.addAction(errorButton)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            task.resume()
            chooseButton.isEnabled = false
            uploadButton.isEnabled = false
        
        } else {
            print("No image")
        }
        
        
    }
    
    func openPhotoLibrary() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    

}

