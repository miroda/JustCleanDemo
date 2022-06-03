//
//  MockData.swift
//  JustClean
//
//  Created by wuchang on 2022/6/2
//  
//

import Foundation

func mockData() {
    for index in (0...10).reversed() {
        JustClean.dataStack.perform(
            asynchronous: { (transaction) -> Void in
                let data = transaction.create(Into<V1.LaundryData>())
                data.code = 200+index
                data.status = "suc"
                let laundry = transaction.create(Into<V1.Laundry>())
                laundry.id = 3456-index*13
                laundry.name = "dubai mall \(index*7)"
                data.data = [laundry]
            },
            completion: { (result) -> Void in
                switch result {
                case .success: print("success!")
                case .failure(let error): print(error)
                }
            }
        )

//            JustClean.dataStack.perform(
//                asynchronous: { (transaction) -> Void in
//                    let data = transaction.create(Into<V2.LaundryData>())
//                    data.code = 200+index
//
//                    let laundry = transaction.create(Into<V2.Laundry>())
//                    laundry.id = 3456-index*13
//                    laundry.name = "dubai mall \(index*7)"
//
//                    let laundry2 = transaction.create(Into<V2.Laundry>())
//                    laundry2.id = 3456-index*13
//                    laundry2.name = "dubai mall \(index*7)"
//
//                    data.data = transaction.create(Into<V2.LaundryDetail>())
//                    data.data?.success =  [laundry,laundry2]
//
//                },
//                completion: { (result) -> Void in
//                    switch result {
//                    case .success: print("success----v2!")
//                    case .failure(let error): print(error)
//                    }
//                }
//            )
        
        
    }
}
    
