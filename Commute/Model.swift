//
//  Model.swift
//  Commute
//
//  Created by Boris Yurkevich on 28/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import UIKit

protocol ModelDelegate {
    
    func newDataAvailable(dataType: Transport)
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
    
    var delegate: ModelDelegate?
    var network = NetworkManager()
    
    func update(type: Transport) {
        
        network.request(commuteOption: type, completion: { (success, error, result) in
            
            if success {
            
                switch type {
                    case .bus:
                    self.busTrips = result!
                    case .plain:
                    self.plainTrips = result!
                    case .train:
                    self.trainTrips = result!
                }
                self.delegate?.newDataAvailable(dataType: type)
                
            } else {
                
                self.delegate?.handleNetwork(error: error)
            }
        })
    }
}
