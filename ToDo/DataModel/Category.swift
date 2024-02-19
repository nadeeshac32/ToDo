//
//  Category.swift
//  ToDo
//
//  Created by Nadeesha Chandrapala on 19/02/2024.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
