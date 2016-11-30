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
            case 0:
                trains = navigation.viewControllers.first as? TravelTableViewController
            case 1:
                buses = navigation.viewControllers.first as? TravelTableViewController
            case 2:
                flights = navigation.viewControllers.first as? TravelTableViewController
            default:
                break
            }
        }
        
        model.delegate = self
        model.update(type: .train)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MenuTabBarController: ModelDelegate {
    
    func newDataAvailable(dataType: DataType) {
        switch dataType {
        case .bus:
            buses?.dataSource = model.busTrips
            buses?.tableView.reloadData()
        case .plain:
            flights?.dataSource = model.plainTrips
            flights?.tableView.reloadData()
        case .train:
            trains?.dataSource = model.trainTrips
            trains?.tableView.reloadData()
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
