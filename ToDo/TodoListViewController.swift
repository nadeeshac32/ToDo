//
//  TodoListViewController.swift
//  ToDo
//
//  Created by Nadeesha Chandrapala on 15/02/2024.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: Category? {
        didSet {
            if let itemArray = retrieveItems() {
                self.itemArray = itemArray
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isDone ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = itemArray[indexPath.row]
//        context.delete(selectedItem)
//        itemArray.remove(at: indexPath.row)
        selectedItem.isDone = !selectedItem.isDone
        saveItems()
        tableView.cellForRow(at: indexPath)?.accessoryType = selectedItem.isDone ? .checkmark : .none
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            if let newTodo = textField.text, !newTodo.isEmpty {
                
                let item = Item(context: context)
                item.title = newTodo
                item.isDone = false
                item.parentCategory = selectedCategory
                self.itemArray.append(item)
                self.saveItems()
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    
    func retrieveItems(searchText: String? = nil) -> [Item]? {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let categoryPredicate: NSPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory?.name ?? "")
        
        if let searchText = searchText {
            let predicate: NSPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
            request.sortDescriptors = [sortDescriptor]
        } else {
            request.predicate = categoryPredicate
        }
        var items: [Item]?
        do {
            items = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        return items
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
}

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let items = retrieveItems(searchText: searchBar.text) {
            itemArray = items
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            if let items = retrieveItems() {
                itemArray = items
                tableView.reloadData()
            }
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
