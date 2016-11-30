//
//  Model.swift
//  Commute
//
//  Created by Boris Yurkevich on 28/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import UIKit

protocol ModelDelegate {
    
    func newDataAvailable(dataType: DataType)
    func handleNetwork(error: Error?)
}

enum DataType {
    case bus
    case train
    case plain
}

class Model {

    var busTrips = [Trip]()
    var trainTrips = [Trip]()
    var plainTrips = [Trip]()
    
    var delegate: ModelDelegate?
    var network = NetworkManager()
    
    func update(type: DataType) {
        
        // Make a network request
        var path = ""
        
        switch type {
        case .bus:
            path = NetworkManager.urlPath.bus
            
        case .plain:
            path = NetworkManager.urlPath.flight
            
        case .train:
            path = NetworkManager.urlPath.train
            
        }
        
        network.request(path: path, completion: { (success, error, result) in
            
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
