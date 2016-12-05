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
    
    var busTripsImages = [ImageEntity]()
    var trainTripsImages = [ImageEntity]()
    var plainTripsImages = [ImageEntity]()
    
    var delegate: ModelDelegate?
    var network = NetworkManager()
    
    // Requests are chained to avoid CoreData crash
    // Train -> Bus -> Flight -> Images
    func update(type: Transport = .train) {
        
        network.request(commuteOption: type, completion: { (success, error, result) in
            
            if success {
            
                // Remove Core Data Cache
                CoreDataManager.sharedInstance.remove(type: type)
                CoreDataManager.sharedInstance.removeImages()
                
                // Parse new data
                let context = CoreDataManager.sharedInstance.managedContext
                guard let entity = NSEntityDescription.entity(forEntityName: CoreDataManager.enitiyId, in: context) else {
                    fatalError("Couldn't load Trip entity")
                }
                
                var trips = [TripEntity]()
                for row in result! {
                    
                    let aTrip = self.parse(dictionary: row, context: context, entity: entity)
                    aTrip.type = Int16(type.rawValue)
                    trips.append(aTrip)
                }
                
                switch type {
                case .train:
                    self.trainTrips = trips
                    self.update(type: .bus)
                    
                case .bus:
                    self.busTrips = trips
                    self.update(type: .plain)
                    
                case .plain:
                    self.plainTrips = trips
                    // All data loaded, now load images
                    self.loadImgages(tripsArray: self.trainTrips)
                }
                
                self.delegate?.newDataAvailable(dataType: type)
                
            } else {
                
                if let myError  = error as? NSError {
                    if myError.code == -1009 {
                        // We are offline, try to laod Core Data
                        self.loadDataLocally()
                        return
                    }
                }
                self.delegate?.handleNetwork(error: error)
            }
        })
    }
    
    private func loadDataLocally() {
        
        let tripRequest = NSFetchRequest<TripEntity>(entityName: CoreDataManager.enitiyId)
        do {
            let result = try CoreDataManager.sharedInstance.managedContext.fetch(tripRequest)
            
            var localTrainTrips = [TripEntity]()
            var localBusTrips = [TripEntity]()
            var localPlainTrips = [TripEntity]()
            
            for trip in result {
            
                guard let type = Transport(rawValue: Int(trip.type)) else {
                    fatalError("Wrong type")
                }
                switch type {
                case .train:
                    localTrainTrips.append(trip)
                case .bus:
                    localBusTrips.append(trip)
                case .plain:
                    localPlainTrips.append(trip)
                }
            }
            
            // Sort by ID
            localTrainTrips.sort(by: { $0.id < $1.id })
            localBusTrips.sort(by: { $0.id < $1.id })
            localPlainTrips.sort(by: { $0.id < $1.id })

            self.trainTrips = localTrainTrips
            self.delegate?.newDataAvailable(dataType: .train)
            self.busTrips = localBusTrips
            self.delegate?.newDataAvailable(dataType: .bus)
            self.plainTrips = localPlainTrips
            self.delegate?.newDataAvailable(dataType: .plain)
            self.loadLoacalImages()

        } catch let error as NSError {
            print("Could not fetch posts: \(error), \(error.userInfo)")
            delegate?.handleNetwork(error: error)
        }
    }

    private func loadLoacalImages() {
    
        let imageRequest = NSFetchRequest<ImageEntity>(entityName: CoreDataManager.imageEnitiyId)
        do {
            let images = try CoreDataManager.sharedInstance.managedContext.fetch(imageRequest)
            
            var localTrainTripsImages = [ImageEntity]()
            var localBusTripsImages = [ImageEntity]()
            var localPlainTripsImages = [ImageEntity]()
            
            for image in images {
                
                guard let t = Transport(rawValue: Int(image.type)) else {
                    fatalError("Wrong type")
                }
                switch t {
                case .train:
                    localTrainTripsImages.append(image)
                case .bus:
                    localBusTripsImages.append(image)
                case .plain:
                    localPlainTripsImages.append(image)
                }
            }
            
            trainTripsImages = localTrainTripsImages
            self.delegate?.newImagesAvailable(dataType: .train)
            busTripsImages = localBusTripsImages
            self.delegate?.newImagesAvailable(dataType: .bus)
            plainTripsImages = localPlainTripsImages
            self.delegate?.newImagesAvailable(dataType: .plain)

        } catch let error as NSError {
        
            print("Could not fetch posts: \(error), \(error.userInfo)")
            delegate?.handleNetwork(error: error)
        }
    }

    private func loadImgages(of type: Transport = .train, tripsArray: [TripEntity]) {
        
        var newImagesCollection = [ImageEntity]()
        
        
        let context = CoreDataManager.sharedInstance.managedContext
        guard let entity = NSEntityDescription.entity(forEntityName: CoreDataManager.imageEnitiyId, in: context) else {
            fatalError("Couldn't load Image entity")
        }
        
        for (index, trip) in tripsArray.enumerated() {
            
            let newImage = ImageEntity(entity: entity, insertInto: context)
            newImage.id = trip.id
            newImage.type = Int16(type.rawValue)
            
            if let logoPath = trip.providerLogo {
                
                // Need to modify path to include size
                let correctPath = logoPath.replacingOccurrences(of: "{size}", with: "63")
                let secureCorrectPath = correctPath.replacingOccurrences(of: "http", with: "https")
                
                if let url = URL(string: secureCorrectPath) {
                    self.network.downloadImage(url: url, completion: { (image) in
                        
                        newImage.imageData = UIImageJPEGRepresentation(image, 1.0) as NSData?
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
                                // All images and data loaded
                                CoreDataManager.sharedInstance.saveContext()
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
    
    private func parse(dictionary: Dictionary<String, Any>,
                           context: NSManagedObjectContext,
                           entity: NSEntityDescription) -> TripEntity {
        
        let aTrip = TripEntity(entity: entity, insertInto: context)
        
        guard let id = dictionary["id"] as? Int64 else {
            fatalError("Couldn't map id")
        }
        guard let logo = dictionary["provider_logo"] as? String else {
            fatalError("Couldn't map logo")
        }
        guard let departureTime = dictionary["departure_time"] as? String else {
            fatalError("Couldn't map departureTime")
        }
        guard let arrivalTime = dictionary["arrival_time"] as? String else {
            fatalError("Couldn't map arrivalTime")
        }
        guard let stoppsCount = dictionary["number_of_stops"] as? Int16 else {
            fatalError("Couldn't map stoppsCount")
        }
        
        // Because of the error in API, price can be eather String or Int
        let priceKey = "price_in_euros"
        if let price = dictionary[priceKey] as? String {
            aTrip.priceInEuros = price
        } else if let priceInt = dictionary[priceKey] as? Int {
            aTrip.priceInEuros = "\(priceInt)"
        } else {
            fatalError("Couldn't map price")
        }
        
        aTrip.id = id
        aTrip.providerLogo = logo
        aTrip.numberOfStops = stoppsCount
        aTrip.arrivalTime = arrivalTime
        aTrip.departureTime = departureTime
        
        return aTrip
    }
}
