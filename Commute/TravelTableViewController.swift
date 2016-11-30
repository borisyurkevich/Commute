//
//  TravelTableViewController.swift
//  Commute
//
//  Created by Boris Yurkevich on 28/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import UIKit

class TravelTableViewController: UITableViewController {

    var dataSource = [TripEntity]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
     //   tableView.register(TravelTableViewCell, forCellReuseIdentifier: "")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TravelCell", for: indexPath) as? TravelTableViewCell else {
            fatalError("Couldn't unwrap the cell")
        }

        let trip = dataSource[indexPath.row]
        cell.priceLabel.text = String("\(trip.id)")

        return cell
    }
}
