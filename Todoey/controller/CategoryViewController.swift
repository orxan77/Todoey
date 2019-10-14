//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Orkhan Bayramli on 10/11/19.
//  Copyright © 2019 Orkhan Bayramli. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }

    //MARK: - TableView Datasource Methods
    // Methods to show items
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
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
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    
    // MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // Reference to the textfield since it is inside of the closure
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            // Creating new Category
            let newCategory = Category(context: self.context)
            
            // Setting its name property
            newCategory.name = textField.text

            // Appending to the array which is global
            self.categories.append(newCategory)
            
            self.saveData()
            
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
    func saveData(){
        do {
            try context.save()
        } catch {
            print("Error saving context: \(context)")
        }
    }
    
    // with: external paramater which is seen by the ones who call the method
    // request: internal parameter which is used within method
    // equal (=) sign means that ToDoItem.fetchRequest() is the default value when no parameter is provided
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error occurred in loadItems: \(error)")
        }
        
    }
}
