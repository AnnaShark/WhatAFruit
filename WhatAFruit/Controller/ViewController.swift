//
//  ViewController.swift
//  WhatAFruit
//
//  Created by Anna Shark on 16/9/21.
//

import UIKit
import CoreML
import Vision
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    let imagePicker = UIImagePickerController()
    var wikiManager = WikiManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        wikiManager.delegate = self
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert image to CIImage")
            }
            detect(image: ciImage)
            //imageVIew.image = userPickedImage

        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage ) {
        
        do {
            let model = try VNCoreMLModel(for: WhatFruit1(configuration: MLModelConfiguration()).model)
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let classification = request.results?.first as? VNClassificationObservation else {
                    fatalError("Classification error")
                }
                let fruit = classification.identifier
                self.navigationItem.title = fruit.capitalized
                self.wikiManager.getWikiInfo(fruit: fruit)
            }
            let handler = VNImageRequestHandler(ciImage: image)
            do {
                try handler.perform([request])
            }
            catch {
                print(error)
            }
        } catch {
            print("Cannot import model")
        }
        
    }

    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

//MARK: - WikiManagerDelegate
extension ViewController: WikiManagerDelegate {
    func didUpdateFruit(_ wikiManager: WikiManager, extract: String, pic: String){
        DispatchQueue.main.async {
            print("I am inside didUpdateFlower in the view controller ")
            self.label.text = extract
            self.imageView.sd_setImage(
                with: URL(string: pic),
                placeholderImage: UIImage(named: "App-Default"),
                options: SDWebImageOptions(rawValue: 0),
                completed: { image, error, cacheType, imageURL in
                    print("hi")
                   }
           )
        }
    }
    
    func didFailWithError(error: Error) {
        print("Here is my error \(error)")
    }
}

