//
//  ViewController.swift
//  Todoey
//
//  Created by Orkhan Bayramli on 10/8/19.
//  Copyright © 2019 Orkhan Bayramli. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

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
    
    // MARK: Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self
        
        tableView.separatorStyle = .none
        
    }
    
    // This method is called right before the view is showing up on screen
    override func viewWillAppear(_ animated: Bool) {
        
        // IMPORTANT: If we are sure that, the value is not null, it is better to
        // use the guard instead if if let statement
        guard let colorHex = selectedCategory?.color else {fatalError()}
        
        title = selectedCategory?.name
        
        updateNavBar(withHexCode: colorHex)

        
    }
    
    // This method gets called right before the view gets dismissed from the view stack
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
        
    }
    
    // MARK: - Nav Bar setup methods
    
    func updateNavBar(withHexCode colorHexCode : String) {
        
        // guard keyword: Throwing error
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller does not exist")
        }
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        
        // Color of navugation backgroun
        navBar.barTintColor = navBarColor
        
        // Color of navigation and bar button items
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        // IMPORTANT! : Because we are using large title
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        // Background of search bar
        searchBar.barTintColor = navBarColor
    }
    
    
    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title

            // If color is not nil, then proceed
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(toDoItems!.count)) {
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
                
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
    
    
    // MARK: - Tableview Delegate Methods
    
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
    
    // MARK: - Add new items
    
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
    
    
    
    // MARK: - Model Manipulating Methods
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch  {
                print("Error deleting ToDoItem: \(error)")
            }
        }
    }
    
}


// MARK: SearchBar methods
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
