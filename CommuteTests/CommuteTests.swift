//
//  CommuteTests.swift
//  CommuteTests
//
//  Created by Boris Yurkevich on 27/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import XCTest
@testable import Commute

class CommuteTests: XCTestCase {

    let timeOut = 60.0
    var tabBarController: MenuTabBarController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        tabBarController = storyboard.instantiateInitialViewController() as! MenuTabBarController
        
        UIApplication.shared.keyWindow!.rootViewController = tabBarController
        let _ = tabBarController.view
    }
    
    override func tearDown() {
        
        CoreDataManager.sharedInstance.removeImages()
        CoreDataManager.sharedInstance.remove(type: .train)
        CoreDataManager.sharedInstance.remove(type: .bus)
        CoreDataManager.sharedInstance.remove(type: .plain)
    
        super.tearDown()
    }
    
    func testMockupNetwork() {
        
        class MockupNetworkManager: NetworkManager {
        
            var getDataCalled = false
            var getImagesCalled = false
            
            override func request(commuteOption: Transport,
                                  completion: @escaping (Bool, Error?, [[String : AnyObject]]?) -> Void) {
            
                getDataCalled = true
                let result = [["provider_logo" : "https://cdn-goeuro.com/static_content/web/logos/63/deutsche_bahn.png",
                               "id" : Int64(0), "number_of_stops" : Int16(0), "arrival_time": "", "departure_time" : "", "price_in_euros" : "0"]]
                
                completion(true, nil, result as [[String : AnyObject]]?)
            }
            
            override func downloadImage(url: URL, completion: @escaping (UIImage) -> Void) {
            
                getImagesCalled = true
                let result = UIImage()
                completion(result)
            }
        }
        
        let mockupNetworkManager = MockupNetworkManager()
         // Dependency Injection
        tabBarController.model.update(networkManager: mockupNetworkManager)
        
        XCTAssert(mockupNetworkManager.getDataCalled)
        XCTAssert(mockupNetworkManager.getImagesCalled)
    }
    
}
