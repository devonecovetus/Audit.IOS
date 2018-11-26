//
//  TableView+DragNDrop.swift
//  Drag N Drop Demo
//
//  Created by Rupesh Chhabra on 23/10/18.
//  Copyright © 2018 Gourav Joshi. All rights reserved.
//

import Foundation
import UIKit

extension DragNDropCollectionView: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = self.dragItem(indexPath: indexPath)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
    {
        let dragItem = self.dragItem(indexPath: indexPath)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            DragNDropSession.clean()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let estilo = UIDragPreviewParameters()
        estilo.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
        return estilo
    }
    
    private func dragItem(indexPath: IndexPath) -> UIDragItem {
        
        //DragDropSession_AuxSingleton.addSessionItem(from: self, at: indexPath)
        DragNDropSession.addSessionItem(from: self, at: indexPath)
        
        var itemProvider: NSItemProvider!
        if let cell = self.cellForItem(at: indexPath) as? PostItCVCell {
            itemProvider = NSItemProvider(object: cell.lbl_Name.text! as NSItemProviderWriting)
        } 
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return dragItem
    }
    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            let stringItems = items as! [String]
            addItems(stringItems)
        }
        
        
        func addItems(_ items: [Any]){
            for (index, item) in items.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                if DragNDropSession.indexes.count == 0 {
                    self.stickers.insert(item, at: indexPath.row)
                } else
                    if !(self === DragNDropSession.collectionViews[index]){
                        self.stickers.insert(item, at: indexPath.row)
                    } else {
                       /* let initialIndexPath = DragNDropSession.indexes[index]
                        self.stickers.remove(at: initialIndexPath.row)
                        self.stickers.insert(item, at: indexPath.row) */
                        return
                }
            }
            DragNDropSession.removeAll()
            self.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if DragNDropSession.indexes.count == 0 {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)//UITableViewDropProposal(operation: .copy, intent: .automatic)
        }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
  }


