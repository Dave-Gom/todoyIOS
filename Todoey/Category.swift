//
//  Category.swift
//  Todoey
//
//  Created by Dave Gomez on 2025-01-09.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    var items = List<Item>()
}
