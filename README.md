JustClean Demo

CoreData Migration Solution

Since CoreData originnal API is famous for hard usage. So I am going to give two solution.

1. Original CoreData API Migration, you can just follow this article. 

   https://williamboles.com/step-by-step-core-data-migration/

2、CoreStore, this one is my solution. I have implemented all the details in my project.

## Why use CoreStore?

CoreStore was (and is) heavily shaped by real-world needs of developing data-dependent apps. It enforces safe and convenient Core Data usage while letting you take advantage of the industry's encouraged best practices.

Regarding to SUPER easy Migration process, I decide to use it.

How to Migration from V1 to V2?

```swift
//define V1 data model
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
         @Field.Stored("favorite")
            var favorite: Bool = false
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


```

```swift
//define V2 data model

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
        @Field.Stored("favorite")
           var favorite: Bool = false
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

```



```swift
//add them in to Migration Chain
//versionLock is automaticly genarated by our program, every time when you change the structure of data, it will get a new one in the Xcode console, just copy them into the project.
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
                versionLock:  [
                    "Laundry": [0x2ccef5b9c2ccd8ef, 0x6313e37b6691ccc0, 0xd22c9a3709e3d494, 0x71803a7723aaf47],
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
                    "Laundry": [0xe1370fb4bf417cf0, 0x7dde45c981b852a3, 0xbb040bd7fb510b6d, 0x8b27931ef73a0583],
                    "LaundryData": [0x4b7fb62f9ec88d07, 0xf260324721bdc65f, 0x1f7a4419c3987c61, 0xe4d847b0789dfe15],
                    "LaundryDetail": [0x6dc76a425d5cd8f5, 0xc0c9a3e99c2dbe2d, 0x892463d1d1618071, 0xc17618c25b33695],
                    "LaundryFailure": [0x113287c6d0670de3, 0x4201139a462a37cc, 0xf938948ed0283c6a, 0x323c9741fe705307],
                    "LaundryItem": [0x6b542efaca11071c, 0x2c3e3161b92b9235, 0xff5cec77db5a9315, 0x86eb7b83b7b950b0]
                ]


            ),
            migrationChain: ["V1","V2"]
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

```



3、Super easy Migration steps

only two steps in my git log

all this two commits in the branch V2

```
1、 feature:switch data model from V1 to V2
start migration but not finished.
mock data has been created.
create a new version in MigrationChain.

2、feature:Migration to V2 finished
replace all the data with V1 with V2
```

3、MockData

If we use V1 in migrationChain: ["V1"] which means our current version is V1,then we can only add V1 data model into our project

```swift
JustClean.dataStack.perform(asynchronous: { transaction in
                                    let data = transaction.create(Into<V1.LaundryData>())
                                    data.code = 200
                                    data.status = "suc"

                                    var laundrys = [V1.Laundry]()
                                    for index in 0 ... 9 {
                                        let laundry = transaction.create(Into<V1.Laundry>())
                                        laundry.id = 3456
                                        laundry.name = "dubai mall \(index * 7)"
                                        if index % 2 == 0 {
                                            laundry.photo = "laundry1"
                                        } else {
                                            laundry.photo = "laundry2"
                                        }
                                        var laundryItems = [V1.LaundryItem]()
                                        for index in 0...5 {
                                            let item = transaction.create(Into<V1.LaundryItem>())
                                            item.name = "laundryItem\(index)"
                                            item.price = Double(index)*2
                                            laundryItems.append(item)
                                        }
                                        laundry.items = laundryItems
                                        laundrys.append(laundry)
                                    }
                                    data.data = laundrys
                                },
                                completion: { result in
                                    switch result {
                                    case .success:
                                        print("success!")
                                    case let .failure(error): print(error)
                                    }
                                })
```

If we use V2 in migrationChain: ["V1","V2"] which means our current version is V2, then we can only add V2 data model into our project

```swift
JustClean.dataStack.perform(asynchronous: { transaction in
                                    let data = transaction.create(Into<V2.LaundryData>())
                                    data.code = 200

                                    var laundrys = [V2.Laundry]()
                                    for index in 0 ... 9 {
                                        let laundry = transaction.create(Into<V2.Laundry>())
                                        laundry.id = 3456
                                        laundry.name = "dubai mall \(index * 7)"
                                        if index % 2 == 0 {
                                            laundry.photo = "laundry1"
                                        } else {
                                            laundry.photo = "laundry2"
                                        }
                                        var laundryItems = [V2.LaundryItem]()
                                        for index in 0 ... 5 {
                                            let item = transaction.create(Into<V2.LaundryItem>())
                                            item.name = "laundryItem\(index)"
                                            item.price = Double(index) * 2
                                            laundryItems.append(item)
                                        }
                                        laundry.items = laundryItems
                                        laundrys.append(laundry)
                                    }
//                                    data.data = laundrys
                                    data.data = transaction.create(Into<V2.LaundryDetail>())
                                    data.data?.success = laundrys
                                },
                                completion: { result in
                                    switch result {
                                    case .success:
                                        print("success!")
                                    case let .failure(error): print(error)
                                    }
                                })
```



4、UI features.

All the features metions in documents has been implemented in the project, please follow the comments.