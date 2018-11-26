//
//  DragNDropTableView.swift
//  Drag N Drop Demo
//
//  Created by Rupesh Chhabra on 23/10/18.
//  Copyright © 2018 Gourav Joshi. All rights reserved.
//

import Foundation
import UIKit

class DragNDropTableView: UITableView {
    var strTitle: String!
    var color: UIColor!
    var stickers: [Any]!
    var dictData: NSDictionary? = NSDictionary()
    
    /**
     This variable helps to maintain the status for a cell is active or not.... i.e it is in list part or in working part.
     */
    var isEnabled: Bool? = Bool()
    var isClicked: Bool? = Bool()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.dataSource = self
        self.dragDelegate = self
        self.dropDelegate = self
    }
    
}

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
}

extension DragNDropTableView: PostItDelegate {
    func increaseValue(index: Int) {
        print("increaseValue = \(index)")
    }
    
    func decreaseValue(index: Int) {
        print("decreaseValue = \(index)")
    }
    
}
