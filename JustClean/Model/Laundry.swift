//
//  Laundry.swift
//  JustClean
//
//  Created by wuchang on 2022/5/30
//
//

import CoreData
import Foundation

/**
 Enum for holding different entity type names (Coredata Models)
 */
enum EntityTypes: String {
    case
        laundry = "Laundry",
        laundryItem = "LaundryItem",
        laundryData = "LaundryData",
        laundryDetail = "LaundryDetail",
        laundryFailure = "LaundryFailure"
}

/**
 Enum for Laundry Entity member fields
 */
enum LaundryAttributes: String {
    case
        laundryId = "id",
        name,
        photo,
        favorite,
        items

    static let getAll = [
        laundryId,
        name,
        photo,
        favorite,
        items,
    ]
}

/**
 Enum for LaundryItem Entity member fields
 */
enum LaundryItemAttributes: String {
    case
        name,
        price

    static let getAll = [
        name,
        price,
    ]
}

class LaundryAPI {
    // Utilize Singleton pattern by instanciating LaundryAPI only once.
    class var sharedInstance: LaundryAPI {
        enum Singleton {
            static let instance = LaundryAPI()
        }

        return Singleton.instance
    }

    init() {}

    /**
         Retrieve an Laundry, found by it's laundryId.

         - Parameter laundryId: id of Laundry item to retrieve
         - Returns: Laundry
     */
    func getLaundryById(_ laundryId: Int64) -> Laundry? {
        var fetchedResults: Laundry?

        // Create request on Event entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityTypes.laundry.rawValue)

        // Add a predicate to filter by eventId
        let findByIdPredicate =
            NSPredicate(format: "id = %d", laundryId)
        fetchRequest.predicate = findByIdPredicate

        // Execute Fetch request
        do {
            let results = try CoreDataManager.shared.mainContext.fetch(fetchRequest) as? [Laundry]
            fetchedResults = results?.first // we assume id of each Laundry is different
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
        }

        return fetchedResults
    }

    /**
         Retrieve an Laundry, found by it's laundryId.

         - Parameter laundryId: id of Laundry item to retrieve
         - Parameter favorite: wether love this laundry
         - Returns: Laundry
     */
    func updateLaundryFavoriteById(_ laundryId: Int64, favorite: Bool) {
        guard let laundry = getLaundryById(laundryId) else {
            return
        }
        laundry.favorite = favorite
        CoreDataManager.shared.saveContext()
        // Post notification to update datasource of a given ViewController/UITableView
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .updateEventTableData, object: nil)
        }
    }

    /**
         Retrieve an LaundryItem, found by it's laundryItemName.

         - Parameter laundryItemName: id of LaundryItem to retrieve
         - Returns: Laundry
     */
    func getLaundryItemById(_ laundryItemName: String) -> LaundryItem? {
        var fetchedResults: LaundryItem?

        // Create request on Event entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityTypes.laundryItem.rawValue)

        // Add a predicate to filter by eventId
        let findByIdPredicate =
            NSPredicate(format: "name = %@", laundryItemName)
        fetchRequest.predicate = findByIdPredicate

        // Execute Fetch request
        do {
            let results = try CoreDataManager.shared.mainContext.fetch(fetchRequest) as? [LaundryItem]
            fetchedResults = results?.first // we assume name of each LaundryItem is different
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
        }

        return fetchedResults
    }

    /**
     Retrieve an LaundryData

     Scenario:
     Given that there there is only a single LaundryData in the datastore
     Let say we only created one event in the datastore, then this function will get that single persisted event
     Thus calling this method multiple times will result in getting always the same event.

     - Returns: a found LaundryData , or nil
     */
    func getSingleAndOnlyEvent() -> LaundryData? {
        var fetchedResultEvent: LaundryData?

        // Create request on Event entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityTypes.laundryData.rawValue)

        // Execute Fetch request
        do {
            let fetchedResults = try CoreDataManager.shared.mainContext.fetch(fetchRequest) as? [LaundryData]
            fetchRequest.fetchLimit = 1

            if fetchedResults?.isEmpty != true {
                fetchedResultEvent = fetchedResults?.first
            }
        } catch let fetchError as NSError {
            print("retrieve single event error: \(fetchError.localizedDescription)")
        }

        return fetchedResultEvent
    }

    // MARK: Read

    /**
         Retrieves all laundry items stored in the persistence layer, default (overridable)
         parameters:
         - Returns: Array<Event> with found events in datastore
     */
    func getAllLaundrys() -> [Laundry] {
        var fetchedResults = [Laundry]()

        // Create request on Event entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityTypes.laundry.rawValue)

        // Execute Fetch request
        do {
            fetchedResults = try CoreDataManager.shared.mainContext.fetch(fetchRequest) as! [Laundry]
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = [Laundry]()
        }

        return fetchedResults
    }

    /**
         Delete all Laundry items from persistence layer.
         - Returns: Void
     */
    func deleteAllLaundrys() {
        let retrievedItems = getAllLaundrys()

        // Delete all event items from persistance layer
        for item in retrievedItems {
            deleteLaundry(item)
        }
    }

    /**
         Delete a single Laundry item from persistence layer.
         - Parameter Laundry: Laundry to be deleted
         - Returns: Void
     */
    func deleteLaundry(_ eventItem: Laundry) {
        // Delete event item from persistance layer
        CoreDataManager.shared.mainContext.delete(eventItem)
        CoreDataManager.shared.saveContext()
        // Post notification to update datasource of a given ViewController/UITableView
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .updateEventTableData, object: nil)
        }
    }
}
