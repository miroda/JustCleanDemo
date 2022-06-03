//
//  MockData.swift
//  JustClean
//
//  Created by wuchang on 2022/6/2
//
//

import Foundation

func mockData() {
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

//    JustClean.dataStack.perform(asynchronous: { transaction in
//                                    let data = transaction.create(Into<V2.LaundryData>())
//                                    data.code = 200
//
//                                    var laundrys = [V2.Laundry]()
//                                    for index in 0 ... 9 {
//                                        let laundry = transaction.create(Into<V2.Laundry>())
//                                        laundry.id = 3456
//                                        laundry.name = "dubai mall \(index * 7)"
//                                        if index % 2 == 0 {
//                                            laundry.photo = "laundry1"
//                                        } else {
//                                            laundry.photo = "laundry2"
//                                        }
//                                        laundrys.append(laundry)
//                                    }
//
//                                    data.data = transaction.create(Into<V2.LaundryDetail>())
//                                    data.data?.success = laundrys
//
//                                },
//                                completion: { result in
//                                    switch result {
//                                    case .success: print("success----v2!")
//                                    case let .failure(error): print(error)
//                                    }
//                                })
}
