//
//  AnimalModel.swift
//  21-swift-imageClassifier
//
//  Created by Liu Ziyi on 19/12/23.
//

import Foundation

class AnimalModel: ObservableObject {
    
    @Published var animal = Animal()
    
    func getAnimal() {
        
        let stringUrl = Bool.random() ? catUrl : dogUrl
        
        // Create a URL object
        let url = URL(string: stringUrl)
        
        // Check that the URL isn't nil
        guard url != nil else {
            print("Couldn't create URL object")
            return
        }
        
        // Get a URL session
        let session = URLSession.shared
        
        // Create a data task
        let dataTask = session.dataTask(with: url!) { data, response, error in
            
            // If there is no error, and data was returned
            if error == nil && data != nil {
                
                // Attempt to parse JSON
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                        
                        let item = json.isEmpty ? [:] : json[0]
                        
                        if let animal = Animal(json: item) {
                            DispatchQueue.main.async {
                                while animal.imageData == nil {}
                                self.animal = animal
                            }
                        }
                        
                    }
                } catch {
                    print("Couldn't parse JSON")
                }
                
            }
            
        }
        
        // Start the data task
        dataTask.resume()
        
    }
    
}
