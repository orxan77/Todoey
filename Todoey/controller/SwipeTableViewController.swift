//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Orkhan Bayramli on 10/15/19.
//  Copyright © 2019 Orkhan Bayramli. All rights reserved.
//

import UIKit
import SwipeCellKit

// Creating superclass to prevent duplicate code.
class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // TableView Data Source Methods
    
    // Method returns a generic and plain cell which is customized by the subclasses
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        // Orientation
        guard orientation == .right else { return nil }
        
        
        
        // This closure is triggered when the cell is swiped
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
    
            self.updateModel(at: indexPath)
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    // Should be overriden by the subclasses
    func updateModel(at indexPath: IndexPath) {
        // Update our data model
    }
}
