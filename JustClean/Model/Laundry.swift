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
         
         @Field.Stored("favorite")
            var favorite: Bool = false
         
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
        
        @Field.Stored("favorite")
           var favorite: Bool = false
        
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
                    Entity<V1.Laundry>("Laundry"),
                    Entity<V1.LaundryData>("LaundryData"),
                    Entity<V1.LaundryItem>("LaundryItem")
                ],
                versionLock: [
                    "Laundry": [0x54e325a76c6e6e1, 0xc55cac3e61f0e384, 0xb982feb7c6e2548a, 0xa6a7db59e9b43874],
                    "LaundryData": [0x732f9a0f8966e5f, 0x843b503f365e4caa, 0xd0b3c809ed68ef56, 0xafd9ce676d91d49e],
                    "LaundryItem": [0x6b542efaca11071c, 0x2c3e3161b92b9235, 0xff5cec77db5a9315, 0x86eb7b83b7b950b0]
                ]
            ),
            CoreStoreSchema(
                modelVersion: "V2",
                entities: [
                    Entity<V2.Laundry>("Laundry"),
                    Entity<V2.LaundryData>("LaundryData"),
                    Entity<V2.LaundryItem>("LaundryItem"),
                    Entity<V2.LaundryDetail>("LaundryDetail"),
                    Entity<V2.LaundryFailure>("LaundryFailure")
                ],versionLock: [
                    "Laundry": [0xf7fbd805db29e401, 0x4714c8833e940811, 0x1fd20897826bc84, 0x6034c6f1ef489bc4],
                    "LaundryData": [0x4b7fb62f9ec88d07, 0xf260324721bdc65f, 0x1f7a4419c3987c61, 0xe4d847b0789dfe15],
                    "LaundryDetail": [0x6dc76a425d5cd8f5, 0xc0c9a3e99c2dbe2d, 0x892463d1d1618071, 0xc17618c25b33695],
                    "LaundryFailure": [0x113287c6d0670de3, 0x4201139a462a37cc, 0xf938948ed0283c6a, 0x323c9741fe705307],
                    "LaundryItem": [0x6b542efaca11071c, 0x2c3e3161b92b9235, 0xff5cec77db5a9315, 0x86eb7b83b7b950b0]
                ]

            ),
            migrationChain: ["V1"]
        )
        
        /**
         - Important: `addStorageAndWait(_:)` was used here to simplify initializing the demo, but in practice the asynchronous function variants are recommended.
         */
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "Modern.justclean.sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        return dataStack
    }()
}
