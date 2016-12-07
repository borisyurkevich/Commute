//
//  MenuTabBarController.swift
//  Commute
//
//  Created by Boris Yurkevich on 29/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import UIKit

class MenuTabBarController: UITabBarController {

    var trains: TravelTableViewController?
    var buses: TravelTableViewController?
    var flights: TravelTableViewController?
    
    let model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()

        for (index, controller) in viewControllers!.enumerated() {
        
            let navigation = controller as! UINavigationController
        
            switch index {
            case Transport.train.rawValue:
                trains = navigation.viewControllers.first as? TravelTableViewController
                navigation.tabBarItem.title = NSLocalizedString("Train", comment: "Tab Bar Title")
                
            case Transport.bus.rawValue:
                buses = navigation.viewControllers.first as? TravelTableViewController
                navigation.tabBarItem.title = NSLocalizedString("Bus", comment: "Tab Bar Title")
                
            case Transport.plain.rawValue:
                flights = navigation.viewControllers.first as? TravelTableViewController
                navigation.tabBarItem.title = NSLocalizedString("Flight", comment: "Tab Bar Title")
            default:
                break
            }
        }
        
        model.delegate = self
        model.update()
    }
}

extension MenuTabBarController: ModelDelegate {
    
    func newDataAvailable(dataType: Transport) {
        switch dataType {
        case .train:
            trains?.dataSource = model.trainTrips
            DispatchQueue.main.async {
                self.trains?.tableView.reloadData()
            }
            
        case .bus:
            buses?.dataSource = model.busTrips
            DispatchQueue.main.async {
                self.buses?.tableView.reloadData()
            }
            
        case .plain:
            flights?.dataSource = model.plainTrips
            DispatchQueue.main.async {
                self.flights?.tableView.reloadData()
            }
        }
    }
    
    func newImagesAvailable(dataType: Transport) {
        
        switch dataType {
        case .train:
            trains?.images = model.trainTripsImages
            DispatchQueue.main.async {
                self.trains?.tableView.reloadData()
            }
            
        case .bus:
            buses?.images = model.busTripsImages
            DispatchQueue.main.async {
                self.buses?.tableView.reloadData()
            }
            
        case .plain:
            flights?.images = model.plainTripsImages
            DispatchQueue.main.async {
                self.flights?.tableView.reloadData()
            }

        }
    }
    
    func handleNetwork(error: Error?) {
        
        var description = NSLocalizedString("Couldn't load your data.",
                                            comment: "alert message")
        if let myDescription = error?.localizedDescription {
            description = myDescription
        }
        
        let alert = UIAlertController(title: NSLocalizedString("Network Error", comment: "alert title"),
                                      message: description,
                                      preferredStyle: .alert)
        
        let alertOption = UIAlertAction(title: NSLocalizedString("OK",
                                                                 comment: "alert ok btn"),
                                        style: .default, handler: nil)
        alert.addAction(alertOption)
        self.present(alert, animated: true, completion: nil)
    }
}
