//
//  Laundry.swift
//  JustClean
//
//  Created by wuchang on 2022/5/30
//  
//

import Foundation

enum V1 {
    final class LaundryItem: CoreStoreObject {
         @Field.Stored("name")
            var name: String?
         @Field.Stored("price")
            var price: Double?
         
         @Field.Relationship("master")
             var master: Laundry?
     }

     final class Laundry: CoreStoreObject {
         @Field.Stored("id")
            var id: Int?
         @Field.Stored("name")
            var name: String?
         @Field.Stored("photo")
            var photo: String?
         
         @Field.Relationship("items", inverse: \.$master)
             var items: Array<LaundryItem>
         
         @Field.Relationship("master")
             var master: LaundryData?
     }
     
     final class LaundryData:CoreStoreObject {
         @Field.Stored("code")
            var code: Int?
         @Field.Stored("status")
            var status: String?
         
         @Field.Relationship("data", inverse: \.$master)
             var data: Array<Laundry>
     }
}

enum V2 {
    class LaundryItem: CoreStoreObject {
        @Field.Stored("name")
           var name: String?
        @Field.Stored("price")
           var price: Double?
        
        @Field.Relationship("master")
            var master: Laundry?
    }

    class Laundry: CoreStoreObject {
        @Field.Stored("id")
           var id: Int?
        @Field.Stored("name")
           var name: String?
        @Field.Stored("photo")
           var photo: String?
        
        @Field.Relationship("items", inverse: \.$master)
            var items: Array<LaundryItem>
        
        @Field.Relationship("master")
            var master: LaundryDetail?
    }
    

    
    class LaundryFailure:CoreStoreObject {
        @Field.Stored("id")
           var id: Int?
        @Field.Stored("date")
           var date: Date?
        
        @Field.Relationship("master")
            var master: LaundryDetail?
    }
    
    class LaundryDetail:CoreStoreObject {
        @Field.Relationship("success", inverse: \.$master)
            var success: Array<Laundry>
        
        @Field.Relationship("failure", inverse: \.$master)
            var failure: LaundryFailure?
        
        @Field.Relationship("master")
            var master: LaundryData?
    }
    
    class LaundryData:CoreStoreObject {
        @Field.Stored("code")
           var code: Int?
        
        @Field.Relationship("data", inverse: \.$master)
            var data: LaundryDetail?
    }
}

enum JustClean {
    // MARK: Internal
    
    static let dataStack: DataStack = {
        
        let dataStack =  DataStack(
            CoreStoreSchema(
                modelVersion: "V1",
                entities: [
//                    Entity<V1.Laundry>("Laundry"),
//                    Entity<V1.LaundryData>("LaundryData"),
                    Entity<V1.LaundryItem>("LaundryItem")
                ]
            ),
//            CoreStoreSchema(
//                modelVersion: "V2",
//                entities: [
//                    Entity<V2.Laundry>("Laundry"),
//                    Entity<V2.LaundryData>("LaundryData"),
//                    Entity<V2.LaundryItem>("Person")
//                ]
//            ),
            migrationChain: ["V1", "V2"]
        )
        
        /**
         - Important: `addStorageAndWait(_:)` was used here to simplify initializing the demo, but in practice the asynchronous function variants are recommended.
         */
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "Modern.ColorsDemo.sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        return dataStack
    }()
}
