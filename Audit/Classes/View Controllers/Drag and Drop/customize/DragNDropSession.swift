//
//  DragNDropSession.swift
//  Drag N Drop Demo
//
//  Created by Rupesh Chhabra on 23/10/18.
//  Copyright © 2018 Gourav Joshi. All rights reserved.
//

import Foundation
import UIKit

class DragNDropSession {
    public static var tableViews: [DragNDropTableView]! = []
    public static var indexes: [IndexPath]! = []
    
    public static func clean(){
        tableViews = [DragNDropTableView]()
        indexes = [IndexPath]()
    }
    
    public static func addSessionItem(from column: DragNDropTableView, at indexPath: IndexPath){
        tableViews.append(column)
        indexes.append(indexPath)
    }
    
    public static func removeAll() {
        for c in 0..<tableViews.count {
            tableViews[c].stickers.remove(at: indexes[c].row)
            tableViews[c].reloadData()
        }
        clean()
    }
}
