//
//  Animal.swift
//  21-swift-imageClassifier
//
//  Created by Liu Ziyi on 19/12/23.
//

import Foundation
import CoreML
import Vision

struct Result: Identifiable {
    var imageLabel: String
    var confidence: Double
    var id = UUID() 
}

class Animal {
    
    // url for the image
    var imageUrl: String
    
    // image data
    var imageData: Data?
    
    var results: [Result]
    
    let modelFile = try! MobileNetV2(configuration: MLModelConfiguration())
//    let modelFile = try! CatOrDog_1(configuration: MLModelConfiguration())
    
    init() {
        self.imageUrl = ""
        self.imageData = nil
        self.results = []
    }
    
    init?(json: [String: Any]) {
        // check that JSON has a url
        guard let imageUrl = json["url"] as? String else {
            return nil
        }
        
        // Set the animal properties
        self.imageUrl = imageUrl
        self.imageData = nil
        self.results = []
        
        // Download the image data
        getImage()
    }
    
    func getImage() {
        
        // Create a URL object
        let url = URL(string: imageUrl)
        
        // Check that the url isn't nil
        guard url != nil else {
            print("Couldn't get URL object")
            return 
        }
        
        // Get a URL session
        let session = URLSession.shared
        
        // Create the data task
        let dataTask = session.dataTask(with: url!) { data, response, error in
            
            // Check that there are no errors and that there was data
            if error == nil && data != nil {
                self.imageData = data
                self.classifyAnimal()
            }
            
        }
        
        // Start the data task
        dataTask.resume()
        
    }
    
    func classifyAnimal() {
        
        // Get a reference to the model
        let model = try! VNCoreMLModel(for: modelFile.model)
        
        // Create an image handler
        let handler = VNImageRequestHandler(data: imageData!)
        
        // Create a request to the model
        let request = VNCoreMLRequest(model: model) { request, error in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                print("Couldn't classify animal")
                return
            }
            
            // Update the results
            for classification in results {
                
                var identifier = classification.identifier
                identifier = identifier.prefix(1).capitalized + identifier.dropFirst()
                self.results.append(Result(imageLabel: identifier, confidence: Double(classification.confidence)))
                
            }
            
        }
        
        // Execute the request
        do {
            try handler.perform([request])
        } catch {
            print("Invalid image")
        }
        
    }
    
}
