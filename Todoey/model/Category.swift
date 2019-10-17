//
//  Category.swift
//  Todoey
//
//  Created by Orkhan Bayramli on 10/15/19.
//  Copyright © 2019 Orkhan Bayramli. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    
    // Declaring relationship as in the DataModel via using List that comes from Realm.
    // P.S. forward relationship.
    let items = List<ToDoItem>()
}
