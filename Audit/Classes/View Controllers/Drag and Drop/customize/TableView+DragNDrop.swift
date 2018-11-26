//
//  TableView+DragNDrop.swift
//  Drag N Drop Demo
//
//  Created by Rupesh Chhabra on 23/10/18.
//  Copyright © 2018 Gourav Joshi. All rights reserved.
//

import Foundation
import UIKit

extension DragNDropTableView: UITableViewDragDelegate, UITableViewDropDelegate {
    
    //MARK: For Drag FUnctions:
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = self.dragItem(indexPath: indexPath)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let dragItem = self.dragItem(indexPath: indexPath)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            DragNDropSession.clean()
        }
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let estilo = UIDragPreviewParameters()
        estilo.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
        return estilo
    }
    
    private func dragItem(indexPath: IndexPath) -> UIDragItem {
        
        //DragDropSession_AuxSingleton.addSessionItem(from: self, at: indexPath)
        DragNDropSession.addSessionItem(from: self, at: indexPath)
        
        var itemProvider: NSItemProvider!
        if let cell = self.cellForRow(at: indexPath) as? PostItTVCell {
            itemProvider = NSItemProvider(object: cell.lbl_Name.text! as NSItemProviderWriting)
        } else if let cell = self.cellForRow(at: indexPath) as? PostItImageTVCell{
            itemProvider = NSItemProvider(object: cell.imagem.image! as NSItemProviderWriting)
        }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return dragItem
    }
    
    //MARK: For Drop FUnctions:
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            let stringItems = items as! [String]
            addItems(stringItems)
        }
        
        coordinator.session.loadObjects(ofClass: UIImage.self) { (items) in
            let imageItems = items as! [UIImage]
            print(imageItems)
            addItems(imageItems)
        }
        
        func addItems(_ items: [Any]){
            for (index, item) in items.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                if DragNDropSession.indexes.count == 0 {
                    self.stickers.insert(item, at: indexPath.row)
                } else
                    if !(self === DragNDropSession.tableViews[index]){
                        self.stickers.insert(item, at: indexPath.row)
                    } else {
                        let initialIndexPath = DragNDropSession.indexes[index]
                        self.stickers.remove(at: initialIndexPath.row)
                        self.stickers.insert(item, at: indexPath.row)
                }
            }
            DragNDropSession.removeAll()
            self.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self) || session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if DragNDropSession.indexes.count == 0 {
            return UITableViewDropProposal(operation: .copy, intent: .automatic)
        }
        return UITableViewDropProposal(operation: .move, intent: .automatic)
        
    }
}


