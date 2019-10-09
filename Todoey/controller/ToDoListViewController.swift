//
//  ViewController.swift
//  Todoey
//
//  Created by Orkhan Bayramli on 10/8/19.
//  Copyright © 2019 Orkhan Bayramli. All rights reserved.
//


/*
 
 **DISCLAIMER**
 
 There is a bug in the App so that once the ToDo item is clicked, this click is also shown in another cell.
 It is because of the cell that we use. We make tableView use the dequeueReusableCell() methode when
 constructing the cells. In this case, the cell that we touch is used again when it is gone off the
 screen. As we are assigning the checkmark property to cell, this checkmark property also stays in the
 cell which is used again.
 
 */
import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemArray = [ToDoItem]()
    
    let defaults = UserDefaults.standard
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let item = ToDoItem()
        item.title = "First"
        itemArray.append(item)
        
        let item2 = ToDoItem()
        item2.title = "Second"
        itemArray.append(item2)
        
        let item3 = ToDoItem()
        item3.title = "Third"
        itemArray.append(item3)
        
        // Getting the stored data from UserDefaults
//        if let items = UserDefaults.standard.array(forKey: "ToDoListArray") as? [String] {
//            itemArray = items
//        }
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        let item = itemArray[indexPath.row]
        
        // **Ternary operator**
        //
        // If item.isDone is true the assign .checkmark to the cell.accessoryType,
        // otherwise assign .none
        cell.accessoryType = item.isDone == true ? .checkmark : .none

        return cell
    }
    
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Little trick for setting the isDone property
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
    
        tableView.reloadData()
        
        // When clicking, it deselects the row in an animated way
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items
    
    // Creating UIAlert for adding new item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // Reference to the textfield since it is inside of the closure
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        
        // Adding the ToDo item to the UserDefaults
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = ToDoItem()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            self.tableView.reloadData()
        }
        
        // Adding textfield for user to enter the ToDo
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        // Finalizing to show the UIAlert
        alert.addAction(action)
        present(alert, animated: true, completion:   nil)
    }
    
    
}

