//
//  Model.swift
//  Commute
//
//  Created by Boris Yurkevich on 28/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import UIKit
import CoreData

protocol ModelDelegate {
    
    func newDataAvailable(dataType: Transport)
    func newImagesAvailable(dataType: Transport)
    func handleNetwork(error: Error?)
}

enum Transport: Int {
    case train
    case bus
    case plain
}

class Model {

    var busTrips = [TripEntity]()
    var trainTrips = [TripEntity]()
    var plainTrips = [TripEntity]()
    
    var busTripsImages = [LogoImage]()
    var trainTripsImages = [LogoImage]()
    var plainTripsImages = [LogoImage]()
    
    var delegate: ModelDelegate?
    var network = NetworkManager()
    
    // Requests are chained to avoid CoreData crash
    // Train -> Bus -> Flight
    func update(type: Transport = .train) {
        
        network.request(commuteOption: type, completion: { (success, error, result) in
            
            if success {
            
                switch type {
                    case .train:
                        self.trainTrips = result!
                        self.update(type: .bus)
                    
                    case .bus:
                        self.busTrips = result!
                        self.update(type: .plain)
                    
                    case .plain:
                        self.plainTrips = result!
                        // All data loaded, now load images
                        
                        self.loadImgages(tripsArray: self.trainTrips)
                }
                
                
                
                self.delegate?.newDataAvailable(dataType: type)
                
            } else {
                
                self.delegate?.handleNetwork(error: error)
            }
        })
    }
    
    func loadImgages(of type: Transport = .train, tripsArray: [TripEntity]) {
        
        var newImagesCollection = [LogoImage]()
        
        for (index, trip) in tripsArray.enumerated() {
            
            let newImage = LogoImage(type: type, id: index)
            
            if let logoPath = trip.providerLogo {
                
                // Need to modify path to include size
                let correctPath = logoPath.replacingOccurrences(of: "{size}", with: "63")
                let secureCorrectPath = correctPath.replacingOccurrences(of: "http", with: "https")
                
                if let url = URL(string: secureCorrectPath) {
                    self.network.downloadImage(url: url, completion: { (image) in
                        
                        newImage.image = image
                        newImagesCollection.append(newImage)
                        
                        if index == (self.trainTrips.count - 1) {
                            
                            // This is the last image
                            switch type {
                            case .train:
                                self.trainTripsImages = newImagesCollection
                                self.loadImgages(of: .bus, tripsArray: self.busTrips)
                                
                            case .bus:
                                self.busTripsImages = newImagesCollection
                                self.loadImgages(of: .plain, tripsArray: self.plainTrips)
                                
                            case .plain:
                                self.plainTripsImages = newImagesCollection
                                // All images loaded, now load images
                            }
                            
                            self.delegate?.newImagesAvailable(dataType: type)
                        }
                    })
                } else {
                    newImagesCollection.append(newImage)
                }
            } else {
                newImagesCollection.append(newImage)
            }
        }

    }
}
