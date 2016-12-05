//
//  NetworkManager.swift
//  Commute
//
//  Created by Boris Yurkevich on 29/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import Foundation
import UIKit

class NetworkManager {

    private struct URLPath {
        static let plain = "https://api.myjson.com/bins/w60i"
        static let train = "https://api.myjson.com/bins/3zmcy"
        static let bus = "https://api.myjson.com/bins/37yzm"
    }
    
    func request(commuteOption: Transport,
                 completion: @escaping (_ success: Bool,
                                        _ error: Error?,
                                        _ result: [[String: AnyObject]]?) -> Void) {
        
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
            
            completion(true, nil, rows)
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

}
