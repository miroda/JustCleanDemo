//
//  CoreDataVersion.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 02/01/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataMigrationVersion: String, CaseIterable {
    case version1 = "JustClean"
//    case version2 = "JustClean V2"
    
    // MARK: - Current
    
    static var current: CoreDataMigrationVersion {
        guard let latest = allCases.last else {
            fatalError("no model versions found")
        }
        
        return latest
    }
    
    // MARK: - Migration
    
    func nextVersion() -> CoreDataMigrationVersion? {
        switch self {
        case .version1:
            return nil
//        case .version2:
//            return nil
        }
    }
}
