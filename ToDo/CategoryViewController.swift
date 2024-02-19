//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Nadeesha Chandrapala on 16/02/2024.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        if let categoryArray = retrieveCategories() {
            self.categoryArray = categoryArray
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added Yet!"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TodoListViewController, let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Category", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            if let newCategory = textField.text, !newCategory.isEmpty {
                
                let category = Category()
                category.name = newCategory
                self.saveCategories(category: category)
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }

    func retrieveCategories(searchText: String? = nil) -> Results<Category>? {
        if let searchText = searchText {
            return realm.objects(Category.self).filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "name", ascending: true)
        } else {
            return realm.objects(Category.self)
        }
    }
    
    func saveCategories(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
}


extension CategoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let categories = retrieveCategories(searchText: searchBar.text) {
            categoryArray = categories
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            if let categories = retrieveCategories() {
                categoryArray = categories
                tableView.reloadData()
            }
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }

            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
                guard let self = self else { return }
                if let item = self.categoryArray?[indexPath.row] {
                    do {
                        try self.realm.write({
                            self.realm.delete(item)
                        })
                    } catch {
                        print("error deleting category: \(error)")
                    }
//                    self.tableView.reloadData()
                }
            }

            deleteAction.image = UIImage(named: "delete")
            return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
}
