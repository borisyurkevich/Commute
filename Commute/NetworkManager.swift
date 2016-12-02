//
//  NetworkManager.swift
//  Commute
//
//  Created by Boris Yurkevich on 29/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class NetworkManager {

    private struct URLPath {
        static let plain = "https://api.myjson.com/bins/w60i"
        static let train = "https://api.myjson.com/bins/3zmcy"
        static let bus = "https://api.myjson.com/bins/37yzm"
    }
    
    func request(commuteOption: Transport,
                 completion: @escaping (_ success: Bool, _ error: Error?, _ result: [TripEntity]?) -> Void) {
        
        var path = ""
        switch commuteOption {
        case .bus:
            path = URLPath.bus
        case .plain:
            path = URLPath.plain
        case .train:
            path = URLPath.train
        }
        guard let url = URL(string: path) else {
            fatalError("Incorrect or missing URL path!")
        }
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10.0 * 1000)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let mySession = URLSession(configuration: .default)
        
        let task = mySession.dataTask(with: urlRequest)
        { (data, response, error) -> Void in
        
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
            guard error == nil else {
                print("Error while fetching remote trips: \(error)")
                completion(false, error, nil)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data!,
                                                               options: []) as? [[String: AnyObject]] else {
                                                                print("Nil data received from service")
                                                                completion(false, nil, nil)
                                                                return
            }
            
            guard let rows = json as [[String: AnyObject]]? else {
                print("Malformed data received from request service")
                completion(false, nil, nil)
                return
            }
            
            CoreDataManager.sharedInstance.remove(type: commuteOption)
            
            let context = CoreDataManager.sharedInstance.managedContext
            guard let entity = NSEntityDescription.entity(forEntityName: CoreDataManager.enitiyId, in: context) else {
                fatalError("Couldn't load Trip entity")
            }
            
            var trips = [TripEntity]()
            for row in rows {
                
                let aTrip = self.parse(dictionary: row, context: context, entity: entity)
                aTrip.type = Int16(commuteOption.rawValue)
                trips.append(aTrip)
            }
            
            completion(true, nil, trips)
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        task.resume()
    }
    
    func downloadImage(url: URL, completion: @escaping (UIImage) -> Void) {
    
        getDataFromUrl(url: url) { (data, response, error) -> Void in
        
            DispatchQueue.main.async {

                guard let data = data, error == nil else { return }
                
                if let image = UIImage(data: data as Data) {
                    completion(image)
                }
            }
        }
    }
    
    private func getDataFromUrl(url:URL,
                        completion: @escaping ((_ data: NSData?,
                                                _ response: URLResponse?,
                                                _ error: NSError? ) -> Void)) {
    
        URLSession.shared.dataTask(with: url) { (data, response, error) in
        
            completion(data as NSData?, response, error as NSError?)
            
            }.resume()
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
