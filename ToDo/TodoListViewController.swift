//
//  TodoListViewController.swift
//  ToDo
//
//  Created by Nadeesha Chandrapala on 15/02/2024.
//

import Foundation
import UIKit

class TodoListViewController: UITableViewController {
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let itemArray = retrieveItems() {
            self.itemArray = itemArray
        }
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
        selectedItem.isDone = !selectedItem.isDone
        storeItems(items: itemArray)
        tableView.cellForRow(at: indexPath)?.accessoryType = selectedItem.isDone ? .checkmark : .none
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { [weak self] (action) in
            if let newTodo = textField.text, !newTodo.isEmpty {
                self?.itemArray.append(Item(title: newTodo))
                self?.storeItems(items: self?.itemArray ?? [])
                self?.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    
    func retrieveItems() -> [Item]? {
        var items: [Item]?
        if let encodedData = try? Data(contentsOf: dataFilePath!) {
            do {
                let decoder = PropertyListDecoder()
                items = try decoder.decode([Item].self, from: encodedData)
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        return items
    }
    
    func storeItems(items: [Item]) {
        let encoder = PropertyListEncoder()
        do {
            let encodedData = try encoder.encode(items)
            try encodedData.write(to: dataFilePath!)
        } catch {
            print("Error encoding data: \(error)")
        }
    }
    
    
}
