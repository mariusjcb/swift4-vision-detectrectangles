//
//  ViewController.swift
//  CoreML WWDC Day1 15:30
//
//  Created by Marius Ilie on 06/08/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    
    var image: CIImage? {
        didSet {
            updateUI()
            
            guard image != nil else {
                return
            }
            
            image!.oriented(.downMirrored)
            analyseImage()
        }
    }
    
    //MARK: Outlets
    
    @IBOutlet private weak var targetImageView: UIImageView!
    
    //MARK: Overriden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentImagePicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateUI()
    }
    
    //MARK: Methods
    
    @IBAction func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        
        present(imagePicker, animated: false)
    }
    
    private func analyseImage() {
        guard image != nil else {
            print("No input image")
            return
        }
        
        let rectanglesRequest = VNDetectRectanglesRequest(
            completionHandler: detectRectanglesCompletionHandler
        )
        
        rectanglesRequest.maximumObservations = 100
        
        let requestHandler = VNImageRequestHandler(
            ciImage: image!,
            orientation: CGImagePropertyOrientation.downMirrored
        )
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([rectanglesRequest])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateUI() {
        targetImageView?.layer.sublayers = [CALayer]()
        
        if image != nil {
            targetImageView?.image = UIImage(ciImage: image!)
        }
    }
    
    //MARK: Vision Methods
    
    private func drawObservedRectangle(_ rectangle: VNRectangleObservation) {
        guard let targetSize = targetImageView?.frame.size else {
            print("targetImageView doesn't exist")
            return
        }
        
        let rectangleShape = CAShapeLayer()
        rectangleShape.opacity = 0.5
        rectangleShape.lineWidth = 5
        rectangleShape.lineJoin = kCALineJoinRound
        rectangleShape.strokeColor = UIColor.blue.cgColor
        rectangleShape.fillColor = UIColor.blue.withAlphaComponent(0.6).cgColor
        
        let rectanglePath = UIBezierPath()
        rectanglePath.move(to: rectangle.topLeft.scaled(to: targetSize))
        rectanglePath.addLine(to: rectangle.topRight.scaled(to: targetSize))
        rectanglePath.addLine(to: rectangle.bottomRight.scaled(to: targetSize))
        rectanglePath.addLine(to: rectangle.bottomLeft.scaled(to: targetSize))
        rectanglePath.close()
        
        rectangleShape.path = rectanglePath.cgPath
        targetImageView?.layer.addSublayer(rectangleShape)
    }
    
    private func detectRectanglesCompletionHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let count = request.results?.count,
                count > 0 else {
                print("No results")
                return
            }
            
            guard let observations = request.results as? [VNRectangleObservation] else {
                print("No rectangles")
                return
            }
            
            for observation in observations {
                self?.drawObservedRectangle(observation)
            }
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        image = CIImage(image: selectedImage)
        picker.dismiss(animated: true)
    }
}

