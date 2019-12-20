//
//  BuiltSubAudit+CollectionView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 01/10/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit


extension BuiltSubAuditViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView ==  colView_SubLocation {
            return CGSize(width: (collectionView.frame.size.width - 30), height:DeviceType.IS_PHONE ? 34 : 45)
        } else { //if collectionView == colView_SelectedLocation {
            return CGSize(width: DeviceType.IS_PHONE ? (collectionView.frame.size.width - 20) : (collectionView.frame.size.width / 2 - 20), height:DeviceType.IS_PHONE ? 65.0 : 75.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colView_SubLocation {
            if flagIsSearch {
                return arrSearch!.count
            } else {
                return arrSubLocationList.count
            }
        } else if collectionView == colView_SelectedSubLocation {
            return arrSelectedSubLocationList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuiltLocationCell", for: indexPath) as! BuiltLocationCell
        cell.index = indexPath.row
        if collectionView == colView_SubLocation {
            if flagIsSearch {
                cell.lbl_Name.text = arrSearch?[indexPath.row].subLocationName
            } else {
                cell.lbl_Name.text = arrSubLocationList[indexPath.row].subLocationName
            }
            
        } else if collectionView == colView_SelectedSubLocation {
            cell.btn_Up.alpha = 1.0
            cell.btn_Down.alpha = 1.0
            if isShowDeleteBtn {
                cell.btn_DeleteItem.alpha = 1.0
            } else {
                cell.btn_DeleteItem.alpha = 0.0
            }
            cell.delegate = self
            cell.lbl_Name.text = String(format: "%@ (%d)", arrSelectedSubLocationList[indexPath.row].subLocationName!, arrSelectedSubLocationList[indexPath.row].subLocationCount!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colView_SelectedSubLocation {
            tv_Description.text = arrSelectedSubLocationList[indexPath.row].subLocationDescription!.htmlToString
            lbl_Info.text =  String(format: "%@ %@", arrSelectedSubLocationList[indexPath.row].subLocationName!, NSLocalizedString("Description:", comment: ""))
        }
    }
}

extension BuiltSubAuditViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = self.dragItem(indexPath: indexPath)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let dragItem = self.dragItem(indexPath: indexPath)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        
        //print("dragSessionDidEnd \(session)")
        if flagIsAddedSelectedSubLocation! {
            self.executeUIProcess {
                
                 //print("dragSessionDidEnd self.flagIsSearch = \(self.flagIsSearch)")
                
                var arrTempList = [SubLocationModel]()
                if self.flagIsSearch {
                    arrTempList = self.arrSearch!
                } else {
                    arrTempList = self.arrSubLocationList
                }
                
                
                self.tv_Description.text = arrTempList[self.intSelectedIndexPath].subLocationDescription!.htmlToString
                self.lbl_Info.text =  String(format: "%@ %@", arrTempList[self.intSelectedIndexPath].subLocationName!, NSLocalizedString("Description:", comment: ""))
                let obSL = BuiltAuditSubLocationModel()
                obSL.initWith(auditId: arrTempList[self.intSelectedIndexPath].auditId!, locationId: arrTempList[self.intSelectedIndexPath].locationId!, subLocationId: arrTempList[self.intSelectedIndexPath].subLocationId!, folderId: self.intFolderId, subFolderId: self.intSubFolderId, workStatus: AuditStatus.InComplete, subLocationCount: 1, subLocationName: arrTempList[self.intSelectedIndexPath].subLocationName!, subLocationDesc: arrTempList[self.intSelectedIndexPath].subLocationDescription!)
                obSqlite.insertBuiltAuditSubLocationData(obBASL: obSL)
                self.getSubLocationList()
                self.getSelectedSubLocationList()
                self.flagIsSearch = false
                self.searchBar.text = ""
                self.searchBar.resignFirstResponder()
                self.colView_SubLocation.reloadData()
            }
            flagIsAddedSelectedSubLocation = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        
        intSelectedIndexPath = indexPath.row
        //print("dragPreviewParametersForItemAt = \(indexPath.row)")
        let estilo = UIDragPreviewParameters()
        //  estilo.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
        return estilo
    }
    
    private func dragItem(indexPath: IndexPath) -> UIDragItem {
        var itemProvider: NSItemProvider!
        if (colView_SubLocation != nil) {
            if let cell = colView_SubLocation.cellForItem(at: indexPath) as? BuiltLocationCell {
                itemProvider = NSItemProvider(object: cell.lbl_Name.text! as NSItemProviderWriting)
            }
        }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return dragItem
    }
}

extension BuiltSubAuditViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        
        if collectionView == colView_SubLocation {
            // for getting index path
            if let indexPath = coordinator.destinationIndexPath {
                //print("indexpth in selected location =\(indexPath.row)")
            }
        } else if collectionView == colView_SelectedSubLocation {
            flagIsAddedSelectedSubLocation = true
        }
        // self.executeUIProcess {
        let section = collectionView.numberOfSections - 1
        let row = collectionView.numberOfItems(inSection: section)
        destinationIndexPath = IndexPath(row: row, section: section)
        collectionView.reloadData()
        //  }
        
        switch coordinator.proposal.operation    {
        case .move:
            //Add the code to recorder items
            //print("coordinator.proposal.operation = move")
            break
            
        case .copy:
            //Add the code to copy items
            //print("coordinator.proposal.operation = copy")
            break
            
        case .forbidden:
            //print("coordinator.proposal.operation = forbidden")
            break
            
        case .cancel:
            //print("coordinator.proposal.operation = cancel")
            break
            
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if destinationIndexPath?.row == 0 {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)//UITableViewDropProposal(operation: .copy, intent: .automatic)
        }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

/// Here this delegate works for builtSubLocation feature
extension BuiltSubAuditViewController: BuiltLocationDelegate {
    func increaseValue(index: Int) {
        //
        if arrSelectedSubLocationList[index].isLocked == 0 { /// Means user can able to make updations in ther selected sub locations
            counter = arrSelectedSubLocationList[index].subLocationCount
            counter! += 1
            
            let success = obSqlite.updateBuiltAuditSubLocation(incId: arrSelectedSubLocationList[index].incId!, auditId: 0, locationId: 0, folderId: 0, subFolderId: 0, subLocationId: 0, subLocationCount: counter!, workStatus: 0, updateType: "count")
            if success {
                arrSelectedSubLocationList[index].subLocationCount = counter
                colView_SelectedSubLocation.reloadData()
            }
        }
    }
    
    func decreaseValue(index: Int) {
        //
        if arrSelectedSubLocationList[index].isLocked == 0 { /// Means user can able to make updations in ther selected sub locations
            counter = arrSelectedSubLocationList[index].subLocationCount
            intFolderListCounter = arrSelectedSubLocationList[index].arrFolders.count
            if counter == intFolderListCounter {
                /// Here we will show an alert,
                showAlertOnDecreaseLocationCount(index: index)
            } else {
                if counter! > 1 {
                    counter! -= 1
                    let success = obSqlite.updateBuiltAuditSubLocation(incId: arrSelectedSubLocationList[index].incId!, auditId: 0, locationId: 0, folderId: 0, subFolderId: 0, subLocationId: 0, subLocationCount: counter!, workStatus: 0, updateType: "count")
                    if success {
                        arrSelectedSubLocationList[index].subLocationCount = counter
                        colView_SelectedSubLocation.reloadData()
                    }
                }
            }
        } else {
            /// Here we will show an alert,
            showAlertOnDecreaseLocationCount(index: index)
        }
    }
    
    func deleteItem(index: Int, indexPath: IndexPath) {
        deleteSelectedSubLocation(index: index, indexPath: indexPath)
    }
    
    /// This function calls only when location counter and folder list counter are same on decreasing the location count value
    func showAlertOnDecreaseLocationCount(index: Int) {
        ///** In future this will be replaced by a custom popup.
        let strMsg = NSLocalizedString("warning1", comment: "") + arrSelectedSubLocationList[index].subLocationName!  + " " + NSLocalizedString("warning3", comment: "")
        view_Alert.alpha = 1.0
        lbl_AlertTitle.text = NSLocalizedString("warningTitle", comment: "")
        lbl_AlertMsg.text = strMsg
        intWhichAlertIndex = 2
        intSelectedIndexOnAlert = index
    }
    
    func deleteSelectedSubLocation(index: Int, indexPath: IndexPath) {
        
        intSelectedIndexOnAlert = index
        if arrSelectedSubLocationList[index].arrFolders.count == 0 {
            deleteSelectedSubLocation()
        } else {
            let strMsg = NSLocalizedString("warning1", comment: "") + arrSelectedSubLocationList[index].subLocationName!  + " " + NSLocalizedString("warning2", comment: "")
            intWhichAlertIndex = 1
            view_Alert.alpha = 1.0
            lbl_AlertTitle.text = NSLocalizedString("warning", comment: "")
            lbl_AlertMsg.text = strMsg
        }
    }
    
    func deleteSelectedSubLocation() {
        /// This will set status and on that behalf both array will be updated
        /**
         1. Delete the sublocation from sublocation database
         2. Call the BuiltAudit Sublocation Data
         3. Filter the both list
         */
        
        obSqlite.deleteBuiltAuditSubLocation(auditId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].locationId!, folderId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].folderId!, subFolderId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].subFolderId!, sublocationId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].subLocationId!, deleteType: "subFolder")
        
        obSqlite.deleteSubLocationSubFolder(incId: 0, auditId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].locationId!, folderId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].folderId!, subFolderId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].subFolderId!, sub_locationId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].subLocationId!, deleteType: "subLocation")
        
        _ = obSqlite.deleteSubLocationSubFolderPhoto(incId: 0, auditId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].auditId!, locationId: 0, sublocationId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].subLocationId!, deleteType: "sublocation")
        
        obSqlite.deleteQuestionAnswer(auditId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedSubLocationList[intSelectedIndexOnAlert].locationId!, folderId:self.arrSelectedSubLocationList[intSelectedIndexOnAlert].folderId!, subFolderId:self.arrSelectedSubLocationList[intSelectedIndexOnAlert].subFolderId!, subLocationId:self.arrSelectedSubLocationList[intSelectedIndexOnAlert].subLocationId!, subLocationSubFolderId: 0, deleteType: "sublocation")
        
        self.lbl_Info.text = NSLocalizedString("Information", comment: "")
        self.tv_Description.text = ""
        self.getSubLocationList()
        self.getSelectedSubLocationList()
    }
    
    /// This function will delete the data from database related to seleced location
    func deleteSelectedLocation(index: Int, indexPath: IndexPath) {
        let alert = UIAlertController(title: "", message: "If you delete your selected location, your all related data and their contents also deleted. Would you like to continue?", preferredStyle: UIAlertControllerStyle.alert)
        let messageFont = [NSAttributedStringKey.font: UIFont(name: CustomFont.themeFont, size: 16.0)!]
        let strMsg = NSLocalizedString("warning1", comment: "") + arrSelectedSubLocationList[index].subLocationName!  + " " + NSLocalizedString("warning3", comment: "")
        let messageAttrString = NSMutableAttributedString(string: strMsg, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let okButton = UIAlertAction(title:"Yes", style: UIAlertActionStyle.default) { (UIAlertAction) in
            /// This will set status and on that behalf both array will be updated
            /**
             1. Delete the sublocation from sublocation database
             2. Call the BuiltAudit Sublocation Data
             3. Filter the both list
             */
            obSqlite.deleteBuiltAuditSubLocation(auditId: self.arrSelectedSubLocationList[index].auditId!, locationId: self.arrSelectedSubLocationList[index].locationId!, folderId: self.arrSelectedSubLocationList[index].folderId!, subFolderId: self.arrSelectedSubLocationList[index].subFolderId!, sublocationId: self.arrSelectedSubLocationList[index].subLocationId!, deleteType: "subFolder")
            
            obSqlite.deleteSubLocationSubFolder(incId: 0, auditId: self.arrSelectedSubLocationList[index].auditId!, locationId: self.arrSelectedSubLocationList[index].locationId!, folderId: self.arrSelectedSubLocationList[index].folderId!, subFolderId: self.arrSelectedSubLocationList[index].subFolderId!, sub_locationId: self.arrSelectedSubLocationList[index].subLocationId!, deleteType: "subLocation")
            
            _ = obSqlite.deleteSubLocationSubFolderPhoto(incId: 0, auditId:  self.arrSelectedSubLocationList[index].auditId!, locationId: 0, sublocationId: self.arrSelectedSubLocationList[index].subLocationId!, deleteType: "sublocation")
            
            obSqlite.deleteQuestionAnswer(auditId: self.arrSelectedSubLocationList[self.intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedSubLocationList[self.intSelectedIndexOnAlert].locationId!, folderId:self.arrSelectedSubLocationList[self.intSelectedIndexOnAlert].folderId!, subFolderId:self.arrSelectedSubLocationList[self.intSelectedIndexOnAlert].subFolderId!, subLocationId:self.arrSelectedSubLocationList[self.intSelectedIndexOnAlert].subLocationId!, subLocationSubFolderId: 0, deleteType: "sublocation")
            
            self.lbl_Info.text = NSLocalizedString("Information", comment: "")
            self.tv_Description.text = ""
            self.getSubLocationList()
            self.getSelectedSubLocationList()
        }
        let cancelButton = UIAlertAction(title:"No", style: UIAlertActionStyle.default) { (UIAlertAction) in  }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
}
