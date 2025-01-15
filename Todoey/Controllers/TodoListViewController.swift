//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    var todoItems: Results<Item>?
    
    let defaults = UserDefaults.standard;
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        tableView.rowHeight = 80.0
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        

        
        if let colorHex = selectedCategory?.color{
            
            title = selectedCategory!.name 
            guard let navBar = navigationController?.navigationBar else {fatalError("No existe el navigationController")}
            
            
            if let navBarColor = UIColor(hexString: colorHex){
                searchBar.barTintColor = navBarColor
                searchBar.searchTextField.textColor = ContrastColorOf(navBarColor, returnFlat: true)
                searchBar.inputView?.layer.borderColor = navBarColor.cgColor

                let standardAppearance = UINavigationBarAppearance()
                
                standardAppearance.configureWithOpaqueBackground()
                standardAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                standardAppearance.backgroundColor = navBarColor

                standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                
                navBar.standardAppearance = standardAppearance
                navBar.scrollEdgeAppearance = standardAppearance

                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)

            }
            
            
        }
        
    }
    
    //MARK -  Metodos del datasource del TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title;
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(self.todoItems?.count ?? 1)){
                cell.backgroundColor = color
            }
           
            
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)

        }
        
        return cell;
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        do{
            if let item = todoItems?[indexPath.row]{
                try realm.write{
                    item.done = !item.done
                }
            }

            tableView.reloadData()
            tableView.deselectRow(at: indexPath, animated: true);
        }
        catch let error{
            print("Error updating item: \(error)")
        }
        
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField();
        let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            do{
                let newItem = Item()
                newItem.done = false
                newItem.title = textField.text!
                
                if let currentCategory = self.selectedCategory{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                    
                }
               

            }
            catch {
                print("error en la creacion")
                print("error creating \(error)")
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    

    //MARK - Model Maniputaion Methods
        
    
    //MARK - Load Items
    func loadItems(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        
    }
    
    //MARK: - Delete
    
    override func updateModel(at indexPath: IndexPath) {
        do{
            if let item = self.todoItems?[indexPath.row] {
                try self.realm.write {
                    self.realm.delete(item)
                }
            }
        }
        catch {
            print("error al eliminar \(error)")
        }
    }
    

}


//MART: - Searchbar Methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty) {
            loadItems()
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
