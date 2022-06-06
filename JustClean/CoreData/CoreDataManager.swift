//
//  CoreDataManager.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 11/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    let migrator: CoreDataMigratorProtocol
    private let storeType: String
    
    lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "JustClean")
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.shouldInferMappingModelAutomatically = true 
        description?.shouldMigrateStoreAutomatically = true
        description?.type = storeType
        
        return persistentContainer
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        
        return context
    }()
    
    // MARK: - Singleton
    
    static let shared = CoreDataManager()
    
    // MARK: - Init
    
    init(storeType: String = NSSQLiteStoreType, migrator: CoreDataMigratorProtocol = CoreDataMigrator()) {
        self.storeType = storeType
        self.migrator = migrator
    }
    
    // MARK: - SetUp
    
    func setup(completion: @escaping () -> Void) {
        loadPersistentStore {
            completion()
        }
    }
    
    // MARK: - Loading
    
    private func loadPersistentStore(completion: @escaping () -> Void) {
        migrateStoreIfNeeded {
            self.persistentContainer.loadPersistentStores { description, error in
                guard error == nil else {
                    fatalError("was unable to load store \(error!)")
                }
                
                completion()
            }
        }
    }
    
    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            fatalError("persistentContainer was not set up properly")
        }
        
        if migrator.requiresMigration(at: storeURL, toVersion: CoreDataMigrationVersion.current) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.migrator.migrateStore(at: storeURL, toVersion: CoreDataMigrationVersion.current)
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            completion()
        }
    }
    
    // MARK: - Core Data Saving support

    /**
        Saves changes from the Main Context to the Master Managed Object Context.
    
        - Returns: Void
    */
    func saveContext() {
        defer {
            do {
                try mainContext.save()
            } catch let masterMocSaveError as NSError {
                print("Master Managed Object Context save error: \(masterMocSaveError.localizedDescription)")
            } catch {
                print("Master Managed Object Context save error.")
            }
        }

        if mainContext.hasChanges {
            mergeChangesFromMainContext()
        }
    }

    /**
        Merge Changes on the Main Context to the Master Context.
    
        - Returns: Void
    */
    fileprivate func mergeChangesFromMainContext() {
        DispatchQueue.main.async(execute: {
            do {
                try self.mainContext.save()
            } catch let mocSaveError as NSError {
                print("Master Managed Object Context error: \(mocSaveError.localizedDescription)")
            }
        })
    }
}

