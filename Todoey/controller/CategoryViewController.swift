//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Orkhan Bayramli on 10/11/19.
//  Copyright © 2019 Orkhan Bayramli. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    // Exclamation mark means that we are sure Realm will not throw an error.
    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }

    //MARK: - TableView Datasource Methods
    // Methods to show items
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // "??" is called Nil Coalescing Operator
        // if not null, return count. If null return 1
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    // Methods to decide what should happen when the Category is clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToToDoItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Preparation before sending Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Getting ViewController from downcasting
        let destinationVC = segue.destination as! ToDoListViewController
        
        // If selected indexPath from TableView is not null, then set the selectedCategory of ViewController
        // to the corresponding category from this array
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    // MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // Reference to the textfield since it is inside of the closure
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            // Creating new Category
            let newCategory = Category()
            
            // Setting its name property
            newCategory.name = textField.text!
            
            self.saveData(category: newCategory)
            
            // Reloading the TableView to show the changes
            self.tableView.reloadData()
        }
        
        // Adding textfield for user to enter the Category
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create Category"
            textField = alertTextField
        }
        
        // Finalizing to show the UIAlert
        alert.addAction(action)
        present(alert, animated: true, completion:   nil)
        
    }
    
    
    
    //MARK: - Data Manipulation Methods
    func saveData(category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // with: external paramater which is seen by the ones who call the method
    // request: internal parameter which is used within method
    // equal (=) sign means that ToDoItem.fetchRequest() is the default value when no parameter is provided
    func loadCategories() {
        
        // Reading categories from Realm DB
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
}
