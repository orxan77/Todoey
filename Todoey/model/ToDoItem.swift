//
//  Item.swift
//  Todoey
//
//  Created by Orkhan Bayramli on 10/15/19.
//  Copyright © 2019 Orkhan Bayramli. All rights reserved.
//

import Foundation
import RealmSwift

// Object is the super class which is used to define Realm model objects.
// Object comes from the Realm library.
class ToDoItem: Object {
    
    // By the help of dynamic keyword, Realm DB is able to modify the value of property at Runtime.
    // @objc means that, the feature comes from the Objective-C APIs.
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var dateCreated: Date?

    // Reverse relationship. 
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}
