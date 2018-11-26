//
//  DragNDropTableView.swift
//  Drag N Drop Demo
//
//  Created by Rupesh Chhabra on 23/10/18.
//  Copyright © 2018 Gourav Joshi. All rights reserved.
//

import Foundation
import UIKit

class DragNDropCollectionView: UICollectionView {
    var strTitle: String!
    var color: UIColor!
    var stickers: [Any]!
    var dictData: NSDictionary? = NSDictionary()
    var rowNumber: Int? = Int()
    
    /**
     This variable helps to maintain the status for a cell is active or not.... i.e it is in list part or in working part.
     */
    var isEnabled: Bool? = Bool()
    var isEnableDelete: Bool? = Bool()
    var isClicked: Bool? = Bool()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func initSettings( isDelegaeDataSource: Bool, isDrag: Bool, isDrop: Bool) {
        
        if isDelegaeDataSource {
            self.delegate = self
            self.dataSource = self
        }
        
        if isDrag {
            self.dragDelegate = self
        }
        
        if isDrop {
            self.dropDelegate = self
        }
    }
    
}


extension DragNDropCollectionView: UICollectionViewDelegate, UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if rowNumber == 1 {
            return CGSize(width: (collectionView.frame.size.width - 10 ), height:75)
        } else if rowNumber == 2 {
            return CGSize(width: (collectionView.frame.size.width / 2 - 10 ), height:75)
        }
        return CGSize(width: (collectionView.frame.size.width / 2 - 10 ), height:75)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PostItCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostItCVCell", for: indexPath) as! PostItCVCell
        if let table = collectionView as? DragNDropCollectionView {
          //  let conteudo:Any = table.stickers[indexPath.row]
            cell.cellIndex = indexPath
            cell.lbl_Name.text = table.stickers[indexPath.row] as? String
            
            if isEnabled! {
                cell.btn_Up.alpha = 1.0
                cell.btn_Down.alpha = 1.0
                cell.index = indexPath.row
                cell.delegate = self
            } else {
                cell.btn_Up.alpha = 0.0
                cell.btn_Down.alpha = 0.0
            }
            
            if isEnableDelete! {
                cell.btn_DeleteItem.alpha = 1.0
            } else {
                cell.btn_DeleteItem.alpha = 0.0
            }
            
            cell.tag = indexPath.row
        } else {
            print("Impossible to cast to Column from UITableView")
        }
        
        return cell
    }
    
    
}
/*
extension DragNDropTableView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stickers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEnabled! {
            print("data name = \(self.stickers[indexPath.row])")
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "post"
   //     var cell = UITableViewCell()
         var cell: PostItTVCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? PostItTVCell
        if let table = tableView as? DragNDropTableView {
            let conteudo:Any = table.stickers[indexPath.row]
            
           
            if cell == nil {
                tableView.register(UINib(nibName: "PostItTVCell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? PostItTVCell
            }
            cell.lbl_Name.text = table.stickers[indexPath.row] as? String
          
            if isEnabled! {
                cell.btn_Up.alpha = 1.0
                cell.btn_Down.alpha = 1.0
                cell.index = indexPath.row
                cell.delegate = self
            } else {
                cell.btn_Up.alpha = 0.0
                cell.btn_Down.alpha = 0.0
            }
            cell.tag = indexPath.row
        } else {
            print("Impossible to cast to Column from UITableView")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cgRect = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100)
        let headerView: UIView = UIView(frame: cgRect)
        headerView.backgroundColor = self.color
        
        let label = UILabel(frame: headerView.frame)
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.text = self.strTitle
        
        headerView.addSubview(label)
        
        return headerView
    }
} */


extension DragNDropCollectionView: PostItCVDelegate {
    func deleteItem(index: Int, indexPath: IndexPath) {
        
        let destinationIndexPath: IndexPath
        
        //if let indexPath = indexPath {
            destinationIndexPath = indexPath
        /*} else {
            // Get last index path of table view.
            let section = self.numberOfSections - 1
            let row = self.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        } */
        
        /*coordinator.session.loadObjects(ofClass: NSString.self) { items in
            let stringItems = items as! [String]
            addItems(stringItems)
        } */
        
        
       // func addItems(_ items: [Any]){
            for (index, item) in self.stickers.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
              
                if DragNDropSession.indexes.count == 0 {
                    print("indx k =\( DragNDropSession.indexes)")
                   //   let initialIndexPath = DragNDropSession.indexes[index]
                    self.stickers.remove(at: index)
                    self.stickers.insert(self.stickers[index] as! String, at: indexPath.row)
                   // self.stickers.insert(self.stickers[initialIndexPath.row] as! String, at: indexPath.row)
                    
                    /*if !(self === DragNDropSession.collectionViews[index]){
                        self.stickers.insert(self.stickers[index] as! String, at: indexPath.row)
                    } else {
                        let initialIndexPath = DragNDropSession.indexes[index]
                        self.stickers.remove(at: initialIndexPath.row)
                        //self.stickers.insert(self.stickers[index] as! String, at: indexPath.row)
                    } */
                    
                    
                } else
                    if !(self === DragNDropSession.collectionViews[index]){
                        self.stickers.insert(self.stickers[index] as! String, at: indexPath.row)
                    } else {
                        let initialIndexPath = DragNDropSession.indexes[index]
                        self.stickers.remove(at: initialIndexPath.row)
                        //self.stickers.insert(self.stickers[index] as! String, at: indexPath.row)
                }
            }
            //DragNDropSession.removeAll()
            self.reloadData()
       // }
    }
    
    
    
    func increaseValue(index: Int) {
        print("increaseValue = \(index)")
    }
    
    func decreaseValue(index: Int) {
        print("decreaseValue = \(index)")
    }
    
}
