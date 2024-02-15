//
//  Item.swift
//  ToDo
//
//  Created by Nadeesha Chandrapala on 15/02/2024.
//

import Foundation

class Item: Codable {
    var title: String = ""
    var isDone: Bool = false
    
    init(title: String, isDone: Bool = false) {
        self.title = title
        self.isDone = isDone
    }
}
