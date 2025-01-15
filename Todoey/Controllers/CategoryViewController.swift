//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Dave on 2025-01-05.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories : Results<Category>?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("No existe el navigationController")}
        
        
        let navBarColor = UIColor.systemBlue

            
            let standardAppearance = UINavigationBarAppearance()
            
            standardAppearance.configureWithOpaqueBackground()
            standardAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            standardAppearance.backgroundColor = navBarColor

            standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            
                navBar.standardAppearance = standardAppearance
            navBar.scrollEdgeAppearance = standardAppearance

            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)

            

        
        
        
    }
    


    
    //MARK: - TableView Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
       if let category = categories?[indexPath.row] {
           cell.textLabel?.text = category.name
           
           guard let categoryColor = UIColor(hexString: category.color) else { fatalError("Could not create color from \(category.color)") }
           
           
           cell.backgroundColor = categoryColor;
           cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        
        return cell;

    }
    
    
    //MARK: - Tableview Delegate mehtods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
            
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCagteories(category: Category) {
        do {
            try realm.write{
                realm.add(category)
            }
            tableView.reloadData()
        }
        catch{
            print("Error al guardar los datos \(error.localizedDescription)")
        }
    }
    
    func loadCategories() {
        do{
        
            self.categories = realm.objects(Category.self)
            
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
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()

            self.saveCagteories(category: newCategory)
            
        }
        
        alert.addAction(action)
        
        alert.addTextField() { (field) in
            textField = field
            textField.placeholder = "Category Name"
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - Delete
    override func updateModel(at indexPath: IndexPath) {
        do{
            if let categoryItemForDeletion = self.categories?[indexPath.row] {
                try self.realm.write {
                    self.realm.delete(categoryItemForDeletion)
                }
            }
        }
        catch {
            print("error al eliminar \(error)")
        }
    }
    
    
}
