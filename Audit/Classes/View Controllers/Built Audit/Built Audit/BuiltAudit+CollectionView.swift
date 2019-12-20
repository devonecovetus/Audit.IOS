//
//  BuiltAudit+TableView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 24/09/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension BuiltAuditViewController: BuiltLocationDelegate {
    func increaseValue(index: Int) {
        if arrSelectedLocation[index].isLocked == 0 { ///  This showing that currently the main work on this location is not done, user can operate all their stuff
            counter = arrSelectedLocation[index].locationCount
            counter! += 1
            obSqlite.updateBuiltAuditLocation(isModified: 0, count: counter!, auditId: arrSelectedLocation[index].auditId!, locationId: arrSelectedLocation[index].locationId!, updateType: "count")
            arrSelectedLocation[index].locationCount = counter
            colView_SelectedLocation.reloadData()
        }
    }
    
    func decreaseValue(index: Int) {
        if index <= arrSelectedLocation.count - 1 {
            if arrSelectedLocation[index].isLocked == 0 { ///  This showing that currently the main work on this location is not done, user can operate all their stuff
                intFolderListCounter = 0
                counter = arrSelectedLocation[index].locationCount
                for i in 0..<arrSelectedLocation[index].arrFolders.count {
                    let obFolder = arrSelectedLocation[index].arrFolders[i]
                    intFolderListCounter = intFolderListCounter + obFolder.folderCount!
                }
                //print("counter = \(counter) , intFolderListCounter = \(intFolderListCounter)")
                /// This condition for checking, the location count and folder list count, if they are equalled during decreasing the counter, then if condition executes
                if counter == intFolderListCounter {
                    /// Here we will show an alert,
                    showAlertOnDecreaseLocationCount(index: index)
                } else {
                    if counter! > 1 {
                        counter! -= 1
                        obSqlite.updateBuiltAuditLocation(isModified: 0, count: counter!, auditId: arrSelectedLocation[index].auditId!, locationId: arrSelectedLocation[index].locationId!, updateType: "count")
                        arrSelectedLocation[index].locationCount = counter
                        colView_SelectedLocation.reloadData()
                    }
                }
            }
        }
    }
    
    /// delete the selected location
    func deleteItem(index: Int, indexPath: IndexPath) {
        deleteSelectedLocation(index: index, indexPath: indexPath)
    }
    
    /// This function calls only when location counter and folder list counter are same on decreasing the location count value
    func showAlertOnDecreaseLocationCount(index: Int) {
        ///** In future this will be replaced by a custom popup.
        intSelectedIndexOnAlert = index
        if arrSelectedLocation[index].arrFolders.count == 0 {
            if self.counter! > 1 {
                self.counter! -= 1
                obSqlite.updateBuiltAuditLocation(isModified: 0, count: self.counter!, auditId: self.arrSelectedLocation[intSelectedIndexOnAlert].auditId!, locationId: self.arrSelectedLocation[intSelectedIndexOnAlert].locationId!, updateType: "count")
                self.arrSelectedLocation[intSelectedIndexOnAlert].locationCount = self.counter
                self.colView_SelectedLocation.reloadData()
            }
        } else {
            let strMsg = NSLocalizedString("warning1", comment: "") + arrSelectedLocation[index].locationName!  + " " + NSLocalizedString("warning2", comment: "")
            view_Alert.alpha = 1.0
            lbl_AlertTitle.text = NSLocalizedString("warningTitle", comment: "")
            lbl_AlertMsg.text = strMsg
            intWhichAlertIndex = 2
        }
    }
    
    /// This function will delete the data from database related to seleced location
    func deleteSelectedLocation(index: Int, indexPath: IndexPath) {
        intSelectedIndexOnAlert = index
        if arrSelectedLocation[index].arrFolders.count == 0 {
            
            obSqlite.updateBuiltAuditLocation(isModified: AuditStatus.InComplete, count: 0, auditId: self.arrSelectedLocation[index].auditId!, locationId: self.arrSelectedLocation[index].locationId!, updateType: "modified")
            
            self.lbl_Information.text = NSLocalizedString("Information", comment: "")
            self.tv_Description.text = ""
            self.getLocationList()
            self.getSelectedLocationList()
            
        } else {
            let strMsg = NSLocalizedString("warning1", comment: "") + arrSelectedLocation[index].locationName! + " " + NSLocalizedString("warning2", comment: "")
            intWhichAlertIndex = 1
            view_Alert.alpha = 1.0
            lbl_AlertTitle.text = NSLocalizedString("warningTitle", comment: "")
            lbl_AlertMsg.text = strMsg
        }
    }
}

extension BuiltAuditViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView ==  colView_LocationList {
            return CGSize(width: (collectionView.frame.size.width - 30), height:DeviceType.IS_PHONE ? 34 : 45)
        } else { //if collectionView == colView_SelectedLocation {
            return CGSize(width: DeviceType.IS_PHONE ? (collectionView.frame.size.width - 20) : (collectionView.frame.size.width / 2 - 20), height:DeviceType.IS_PHONE ? 60.0 : 75.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colView_LocationList {
            if flagIsSearch {
                return arrSearch!.count
            } else {
                return arrLocationList.count
            }
        } else if collectionView == colView_SelectedLocation {
            return arrSelectedLocation.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuiltLocationCell", for: indexPath) as! BuiltLocationCell
        cell.index = indexPath.row
        
        if collectionView == colView_LocationList {
            if flagIsSearch {
                cell.lbl_Name.text = arrSearch?[indexPath.row].locationName!
            } else {
                cell.lbl_Name.text = arrLocationList[indexPath.row].locationName
            }
            
        } else if collectionView == colView_SelectedLocation {
            cell.btn_Up.alpha = 1.0
            cell.btn_Down.alpha = 1.0
            if isShowDeleteBtn {
                cell.btn_DeleteItem.alpha = 1.0
            } else {
                cell.btn_DeleteItem.alpha = 0.0
            }
            cell.delegate = self
            cell.lbl_Name.text = String(format: "%@ (%d)", arrSelectedLocation[indexPath.row].locationName!, arrSelectedLocation[indexPath.row].locationCount!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colView_SelectedLocation {
            tv_Description.text = arrSelectedLocation[indexPath.row].locationDescription!.htmlToString
            lbl_Information.text =  String(format: "%@ %@", arrSelectedLocation[indexPath.row].locationName!, NSLocalizedString("Description:", comment: ""))
        } 
    }
}

extension BuiltAuditViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = self.dragItem(indexPath: indexPath)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let dragItem = self.dragItem(indexPath: indexPath)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        
        if flagIsAddedSelectedLocation! {
            self.executeUIProcess {
               //print("dragSessionDidEnd self.flagIsSearch = \(self.flagIsSearch)")
                if self.flagIsSearch {
                    self.tv_Description.text = self.arrSearch?[self.intSelectedIndexPath].locationDescription!.htmlToString
                    self.lbl_Information.text =  String(format: "%@ %@", (self.arrSearch?[self.intSelectedIndexPath].locationName!)!, NSLocalizedString("Description:", comment: ""))
                } else {
                    self.tv_Description.text = self.arrLocationList[self.intSelectedIndexPath].locationDescription!.htmlToString
                    self.lbl_Information.text =  String(format: "%@ %@", self.arrLocationList[self.intSelectedIndexPath].locationName!, NSLocalizedString("Description:", comment: ""))
                }
                
               
                
                
                if self.is_draft == false {
                    let isSuccess = obSqlite.updateAudit(auditId: self.intAuditId!, updateType: "auditStatus", auditStatus: AuditStatus.Pending, countryId: 0, language: "", isSyncCompleted: 0, answersAreSynced: 0, answersForSync: 0)
                    if isSuccess == true {
                        self.is_draft = true
                    }
                }
                
                if self.flagIsSearch {
                    obSqlite.updateBuiltAuditLocation(isModified: AuditStatus.Pending, count: 0, auditId: (self.arrSearch?[self.intSelectedIndexPath].auditId!)!, locationId: (self.arrSearch?[self.intSelectedIndexPath].locationId!)!, updateType: "modified")
                } else {
                    obSqlite.updateBuiltAuditLocation(isModified: AuditStatus.Pending, count: 0, auditId: self.arrLocationList[self.intSelectedIndexPath].auditId!, locationId: self.arrLocationList[self.intSelectedIndexPath].locationId!, updateType: "modified")
                }
                
                self.getLocationList()
                self.getSelectedLocationList()
                self.flagIsAddedSelectedLocation = false
                self.flagIsSearch = false
                self.searchBar.text = ""
                self.searchBar.resignFirstResponder()
                self.colView_LocationList.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters?   {
        intSelectedIndexPath = indexPath.row
        //print("dragPreviewParametersForItemAt = \(indexPath.row)")
        let estilo = UIDragPreviewParameters()
        //  estilo.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
        return estilo
    }
    
    private func dragItem(indexPath: IndexPath) -> UIDragItem {
        var itemProvider: NSItemProvider!
        if (colView_LocationList != nil) {
            if let cell = colView_LocationList.cellForItem(at: indexPath) as? BuiltLocationCell {
                itemProvider = NSItemProvider(object: cell.lbl_Name.text! as NSItemProviderWriting)
            }
        }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return dragItem
    }
}


extension BuiltAuditViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if collectionView == colView_LocationList {
            // for getting index path
            if let indexPath = coordinator.destinationIndexPath {
                //print("indexpth in selected location =\(indexPath.row)")
            }
        } else if collectionView == colView_SelectedLocation {
            flagIsAddedSelectedLocation = true
        }
        
        let section = collectionView.numberOfSections - 1
        let row = collectionView.numberOfItems(inSection: section)
        destinationIndexPath = IndexPath(row: row, section: section)
        collectionView.reloadData()
        
        switch coordinator.proposal.operation   {
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
