//
//  RemoteReplicator.swift
//  CoreDataCRUD
//
//  Copyright © 2016 Jongens van Techniek. All rights reserved.
//

import CoreData
import Foundation
// Methods that must be implemented by every class that extends it.
protocol ReplicatorProtocol {
    func fetchData()
    func processData(_ jsonResult: AnyObject?)
}

/**
 Remote Replicator handles calling remote datasource and parsing response JSON data and calls the Core Data Stack,
 (via EventAPI) to actually create Core Data Entities and persist to SQLite Datastore.
 */

class RemoteReplicator: ReplicatorProtocol {
    fileprivate var laundryAPI: LaundryAPI!
    fileprivate var httpClient: HTTPClient!

    private let justCleanApiV1 = "https://miroda.github.io/Laundry.json"
    private let justCleanApiV2 = "https://miroda.github.io/LaundryV2.json"
    // Utilize Singleton pattern by instanciating Replicator only once.
    class var sharedInstance: RemoteReplicator {
        enum Singleton {
            static let instance = RemoteReplicator()
        }

        return Singleton.instance
    }

    init() {
        laundryAPI = LaundryAPI.sharedInstance
        httpClient = HTTPClient()
    }

    /**
         Pull event data from a given Remote resource, posts a notification to update
         datasource of a given/listening ViewController/UITableView.

         - Returns: Void
     */
    func fetchData() {
        // Remote resource
        let request = URLRequest(url: URL(string: justCleanApiV2)!)

        httpClient.doGet(request) { data, _, httpStatusCode in
            if httpStatusCode!.rawValue != HTTPStatusCode.ok.rawValue {
                print("\(httpStatusCode!.rawValue) \(String(describing: httpStatusCode))")
                if data == nil {
                    print("data is nil")
                }
            } else {
                // Read JSON response in seperate thread
                DispatchQueue.global().async {
                    // read JSON file, parse JSON data
                    self.processData(data as AnyObject?)

                    // Post notification to update datasource of a given ViewController/UITableView
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .updateEventTableData, object: nil)
                    }
                }
            }
        }
    }

    /**
         Process data from a given resource Event objects and assigning
         (additional) property values and calling the Event API to persist Events
         to the datastore.

         - Parameter jsonResult: The JSON content to be parsed and stored to Datastore.
         - Returns: Void
     */
    internal func processData(_ jsonResponse: AnyObject?) {
        let jsonData: Data? = jsonResponse as? Data
        var jsonResult: JSON?

        do {
            if let jsonData = jsonData {
                jsonResult = try JSONDecoder().decode(JSON.self, from: jsonData)
            }
        } catch let fetchError as NSError {
            print("pull error: \(fetchError.localizedDescription)")
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let context = CoreDataManager.shared.backgroundContext
            context.performAndWait {
                if let laundryList = jsonResult?.object?["data"]?.object?["success"] {
                    if let array = laundryList.array {
                        for data in array {
                            let laundry = NSEntityDescription.insertNewObject(forEntityName: EntityTypes.laundry.rawValue, into: context) as! Laundry
                            laundry.id = Int64((data.object?["id"]?.int)!)
                            laundry.name = data.object?["name"]?.string
                            laundry.photo = data.object?["photo"]?.string
                            laundry.favorite = data.object?["favorite"]?.bool ?? false
                            
                            if let itemArray = data.object?["items"]?.array {
                                for item in itemArray {
                                    let laundryItem = NSEntityDescription.insertNewObject(forEntityName: "LaundryItem", into: context) as! LaundryItem
                                    laundryItem.name = item.object?["name"]?.string
                                    laundryItem.price = item.object?["price"]?.double ?? 0.0
                                    laundryItem.laundry = laundry
                                    laundry.addToItems(laundryItem)
                                }
                            }
                            
                            try? context.save()
                        }
                    }
                }
            }
        }
    }
}
