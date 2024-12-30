//
//  Item.swift
//  Todoey
//
//  Created by Dave Gomez on 2024-12-17.
//  Copyright © 2024 App Brewery. All rights reserved.
//
import Foundation

class Item: Encodable,Decodable {
    var title: String = ""
    var done: Bool = false
    
    
     init(title: String?){
        self.title = title ?? "";
    }
}
