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
import CoreData

class ToDoListViewController: UITableViewController{
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [ToDoItem]()
    
    var selectedCategory : Category? {
        
        // The lines of code in the didSet is executed when the selectedCategory gets set with a value
        didSet{
            loadItems()
        }
    }

    // Accessing the viewContext through the UIApplication
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        searchBar.delegate = self
        
        loadItems()
        
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

/*
          For removing the ToDoItem. Order is important. First from database, then from array
  
          context.delete(itemArray[indexPath.row])
          itemArray.remove(at: indexPath.row)
*/
        saveData()
        
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
            let newItem = ToDoItem(context: self.context)
            
            // Setting its title and isDone properties
            newItem.title = textField.text!
            newItem.isDone = false
            newItem.parentCategory = self.selectedCategory
            // Appending to the array which is global
            self.itemArray.append(newItem)
            
            self.saveData()
            
            // Reloading the TableView to show the changes
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
    
    
    
    //MARK - Model Manipulating Methods
    
    func saveData() {
    
        do {
            try context.save()
        } catch {
            print("Error saving context: \(context)")
        }
    }
    
    
    // with: external paramater which is seen by the ones who call the method
    // request: internal parameter which is used within method
    // equal (=) sign means that ToDoItem.fetchRequest() is the default value when no parameter is provided
    func loadItems(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        // If the predicate parameter is provided and if it is not null, we are using NSCompoundPredicate
        // and give the predicate array as an input. If not, only predicate is the default one which is
        // categoryPredicate.
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error occurred in loadItems: \(error)")
        }
    }
}


//MARK: SearchBar methods
// Extension has been used in order the project be neater and easier to read.

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        // Query language
        // cd means that it is not CASE and DIACRITIC sensitive
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // Sort by title and in ascending (alphabetical) order
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        loadItems(with: request, predicate: predicate)
        
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

    // Better solution to dismissing keyword and cursor
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        searchBar.text = ""
//        loadItems()
//    }
//
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.showsCancelButton = true
//        UIView.animate(withDuration: 0.1) { // not ideal to hardcode the duration
//            searchBar.layoutIfNeeded()
//        }
//    }
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchBar.showsCancelButton = false
//        UIView.animate(withDuration: 0.1) {
//            searchBar.layoutIfNeeded()
//        }
//    }
    
}

