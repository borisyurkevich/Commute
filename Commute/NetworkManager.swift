//
//  NetworkManager.swift
//  Commute
//
//  Created by Boris Yurkevich on 29/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import Foundation
import CoreData

class NetworkManager {

    struct urlPath {
        static let flight = "https://api.myjson.com/bins/w60i"
        static let train = "https://api.myjson.com/bins/3zmcy"
        static let bus = "https://api.myjson.com/bins/37yzm"
    }
    
    func request(path: String,
                 completion: @escaping (_ success: Bool, _ error: Error?, _ result: [Trip]?) -> Void) {
        
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
            guard error == nil else {
                print("Error while fetching remote trips: \(error)")
                completion(false, error, nil)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data!,
                                                               options: []) as? [[String: AnyObject]] else {
                                                                print("Nil data received from fetchAllRooms service")
                                                                completion(false, nil, nil)
                                                                return
            }
            
            guard let rows = json as [[String: AnyObject]]? else {
                print("Malformed data received from request service")
                completion(false, nil, nil)
                return
            }
            
            CoreDataManager.sharedInstance.removeAll()
            
            let context = CoreDataManager.sharedInstance.managedContext
            guard let entity = NSEntityDescription.entity(forEntityName: "Trip", in: context) else {
                fatalError("Couldn't load Trip entity")
            }
            
            var posts = [Trip]()
            for postDictionary in rows {
                
                let aTrip = Trip(entity: entity, insertInto: context)
                aTrip.id = postDictionary["id"] as! Int64
                posts.append(aTrip)
            }
            
            completion(true, nil, posts)
        }
        
        task.resume()
    }

}
