//
//  ViewController.swift
//  Todoey
//
//  Created by Orkhan Bayramli on 10/8/19.
//  Copyright © 2019 Orkhan Bayramli. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: SwipeTableViewController{
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var toDoItems : Results<ToDoItem>?
    
    var selectedCategory : Category? {
        
        // The lines of code in the didSet is executed when the selectedCategory gets set with a value
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.rowHeight = 80
        searchBar.delegate = self
        
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title

            // **Ternary operator**
            //
            // If item.isDone is true the assign .checkmark to the cell.accessoryType,
            // otherwise assign .none
            cell.accessoryType = item.isDone == true ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items added"
        }

        return cell
    }
    
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.isDone = !item.isDone
                }
            } catch {
                print("Error occurred while updating items: \(error)")
            }
        }
        
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
            
            // Creating new ToDoItem
            let newItem = ToDoItem()

            if let currentCategory = self.selectedCategory {
                
                do {
                    
                    // Saving ToDoItem
                    try self.realm.write {
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving ToDoItem: \(error)")
                }
                
                self.tableView.reloadData()

            }
            
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
    
    
    
    //MARK - Model Manipulating Methods
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try realm.write {
                
                if let currentCategory = self.selectedCategory {
                    currentCategory.items.remove(at: indexPath.row)
                }
                
            }
        } catch  {
            print("Error deleting ToDoItem: \(error)")
        }
    }
    
}


//MARK: SearchBar methods
// Extension has been used in order the project be neater and easier to read.

extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        // If all the text has been deleted from search bar, load items again.
        if searchBar.text?.count == 0 {
            loadItems()
            self.tableView.reloadData()

            // Makes the OS run the code in the main thread
            DispatchQueue.main.async {
                // Search bar should revert to the state when there was no keyboard and cursor.
                searchBar.resignFirstResponder()
            }
        }
    }
}
