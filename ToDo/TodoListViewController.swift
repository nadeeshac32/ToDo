//
//  TodoListViewController.swift
//  ToDo
//
//  Created by Nadeesha Chandrapala on 15/02/2024.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    let realm = try! Realm()
    var itemArray: Results<Item>?
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
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray?[indexPath.row]
        cell.textLabel?.text = item?.title ?? "No Items Added Yet!"
        cell.accessoryType = item?.isDone == true ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectedItem = itemArray?[indexPath.row] {
            do {
                try realm.write({
                      //    realm.delete(selectedItem)
                    selectedItem.isDone = !selectedItem.isDone
                })
            } catch {
                print("Error Saving new item: \(error)")
            }
            tableView.cellForRow(at: indexPath)?.accessoryType = selectedItem.isDone ? .checkmark : .none
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            if let newTodo = textField.text, !newTodo.isEmpty, let currentCategory = self.selectedCategory {
                do {
                    try realm.write({
                        let item = Item()
                        item.title = newTodo
                        item.dateCreated = Date()
                        currentCategory.items.append(item)
                    })
                } catch {
                    print("Error Saving new item: \(error)")
                }
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
    
    
    func retrieveItems(searchText: String? = nil) -> Results<Item>? {
        if let searchText = searchText {
            return selectedCategory?.items.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
        }
        return selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
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
