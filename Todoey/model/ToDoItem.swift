//
//  ToDoCell.swift
//  Todoey
//
//  Created by Orkhan Bayramli on 10/9/19.
//  Copyright © 2019 Orkhan Bayramli. All rights reserved.
//

import Foundation

// Inheriting Codable in order to make ToDoItem to be encoded into the plist or decoded from the plist
class ToDoItem: Codable {
    
    // Properties should have standard data types
    var title : String = ""
    var isDone : Bool = false
    
    
}
