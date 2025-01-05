//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Dave on 2025-01-05.
//  Copyright © 2025 App Brewery. All rights reserved.
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


    
    //MARK: - TableView Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell;
    }
    
    
    //MARK: - Tableview Delegate mehtods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories[indexPath.row]
            
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCagteories() {
        do {
            try context.save()
            tableView.reloadData()
        }
        catch{
            print("Error al guardar los datos \(error.localizedDescription)")
        }
    }
    
    func loadCategories() {
        do{
            let request: NSFetchRequest<Category> =  Category.fetchRequest()
            
            categories = try context.fetch(request)
            
            tableView.reloadData()
        }
        catch{
            print("error al cargar las categorias \(error)")
        }
    }
    
    //MARK: - Add new Categories


    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Category", message: nil, preferredStyle: .alert)
        
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categories.append(newCategory)
            self.saveCagteories()
            
        }
        
        alert.addAction(action)
        
        alert.addTextField() { (field) in
            textField = field
            textField.placeholder = "Category Name"
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
}

