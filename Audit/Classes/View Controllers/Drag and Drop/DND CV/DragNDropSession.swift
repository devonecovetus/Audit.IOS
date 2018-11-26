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
    public static var collectionViews: [DragNDropCollectionView]! = []
    public static var indexes: [IndexPath]! = []
    
    public static func clean(){
        collectionViews = [DragNDropCollectionView]()
        indexes = [IndexPath]()
    }
    
    public static func addSessionItem(from column: DragNDropCollectionView, at indexPath: IndexPath){
        collectionViews.append(column)
        indexes.append(indexPath)
    }
    
    public static func removeAll() {
        for c in 0..<collectionViews.count {
            collectionViews[c].stickers.remove(at: indexes[c].row)
            collectionViews[c].reloadData()
        }
        clean()
    }
}
