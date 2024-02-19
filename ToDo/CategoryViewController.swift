//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Nadeesha Chandrapala on 16/02/2024.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let categoryArray = retrieveCategories() {
            self.categoryArray = categoryArray
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let item = categoryArray[indexPath.row]
        cell.textLabel?.text = item.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TodoListViewController, let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Category", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            if let newCategory = textField.text, !newCategory.isEmpty {
                
                let category = Category(context: context)
                category.name = newCategory
                self.categoryArray.append(category)
                self.saveCategories()
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

    func retrieveCategories(searchText: String? = nil) -> [Category]? {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        if let searchText = searchText {
            let predicate: NSPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.predicate = predicate
            request.sortDescriptors = [sortDescriptor]
        }
        var categories: [Category]?
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        return categories
    }
    
    func saveCategories() {
        do {
            try context.save()
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
