//
//  CoreDataManager.swift
//  Commute
//
//  Created by Boris Yurkevich on 22/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {

    static let enitiyId = "TripEntity"
    static let imageEnitiyId = "ImageEntity"

    static let sharedInstance : CoreDataManager = {
        let instance = CoreDataManager(modelName: "Commute")
        return instance
    }()

    private let modelName: String
    
    private init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    private lazy var storeContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext () {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func remove(type: Transport) {
        let postRequest = NSFetchRequest<TripEntity>(entityName: CoreDataManager.enitiyId)
        do {
            let results = try managedContext.fetch(postRequest)
            
            let filteredResult = results.filter{Int($0.type) == type.rawValue}
            
            for result in filteredResult {
                managedContext.delete(result)
            }
            
        } catch let error as NSError {
            print("Could not fetch users for deleting: \(error), \(error.userInfo)")
        }
        saveContext()
    }
    
    func removeAll() {
        let postRequest = NSFetchRequest<TripEntity>(entityName: CoreDataManager.enitiyId)
        do {
            let results = try managedContext.fetch(postRequest)
            for result in results {
                managedContext.delete(result)
            }
            
        } catch let error as NSError {
            print("Could not fetch users for deleting: \(error), \(error.userInfo)")
        }
        saveContext()
    }
    
}
