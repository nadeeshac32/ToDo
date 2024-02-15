//
//  TodoListViewController.swift
//  ToDo
//
//  Created by Nadeesha Chandrapala on 15/02/2024.
//

import Foundation
import UIKit

class TodoListViewController: UITableViewController {
    
    let itemArray = ["Find mike", "buy eggs", "Call amiras"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let isSelected = tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark
        tableView.cellForRow(at: indexPath)?.accessoryType = isSelected ? .none : .checkmark
    }
    
}
