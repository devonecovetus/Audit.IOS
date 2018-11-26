//
//  BuiltAuditViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 15/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class BuiltAuditViewController: UIViewController {
    
    var counter: Int? = Int()
    var intSelectedIndexPath = Int()
    var flagIsAddedSelectedLocation: Bool? = Bool()
    var arrLocationList = [LocationModel]()
    var arrSelectedLocation = [LocationModel]()
    let cell = BuiltLocationCell()
    var isShowDeleteBtn = false
    
    /*
     This will work woit drop feature
     */
    @IBOutlet weak var colView_SelectedLocation: UICollectionView!
    /*
     This view can work with drag feature
     */
    @IBOutlet weak var colView_LocationList: UICollectionView!
    
    @IBOutlet weak var btn_Next: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btn_Next(_ sender: Any) {
        let vc = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBOutlet weak var tv_Description: UITextView!
    
    @IBOutlet weak var lbl_Information: UILabel!
    @IBOutlet weak var btn_Delete: UIButton!
    
    @IBAction func btn_Delete(_ sender: UIButton) {
        if sender.isSelected {
            isShowDeleteBtn = false
            btn_Delete.setTitle("Delete", for: .normal)
            sender.isSelected = false
        } else {
            isShowDeleteBtn = true
            btn_Delete.setTitle("Done", for: .normal)
            sender.isSelected = true
        }
        colView_SelectedLocation.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        arrLocationList = obSqlite.getLocationList(isModified: AuditStatus.InComplete)
        arrSelectedLocation = obSqlite.getLocationList(isModified: AuditStatus.Pending)
        colView_LocationList.reloadData()
        colView_SelectedLocation.reloadData()
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    */
}

/*
extension BuiltAuditViewController: BuiltLocationDelegate {
    func increaseValue(index: Int) {
        counter = arrSelectedLocation[index].locationCount
        counter! += 1
        
        _ = obSqlite.updateBuiltAuditLocationCount(count: counter!, locationId: arrSelectedLocation[index].locationId!, auditId: arrSelectedLocation[index].auditId!)
        
        arrSelectedLocation = obSqlite.getLocationList(isModified: AuditStatus.Pending)
        colView_SelectedLocation.reloadData()
    }
    
    func decreaseValue(index: Int) {
        counter = arrSelectedLocation[index].locationCount

        if counter! > 1 {
            counter! -= 1
            _ = obSqlite.updateBuiltAuditLocationCount(count: counter!, locationId: arrSelectedLocation[index].locationId!, auditId: arrSelectedLocation[index].auditId!)
            
            arrSelectedLocation = obSqlite.getLocationList(isModified: AuditStatus.Pending)
            colView_SelectedLocation.reloadData()
        }
    }
    
    func deleteItem(index: Int, indexPath: IndexPath) {
        
        _ = obSqlite.updateBuiltAuditLocation(isModified: AuditStatus.InComplete, locationId: arrSelectedLocation[index].locationId!, auditId: arrSelectedLocation[index].auditId!)
        _ = obSqlite.updateBuiltAuditLocationCount(count: 1, locationId: arrSelectedLocation[index].locationId!, auditId: arrSelectedLocation[index].auditId!)
        
        obSqlite.deleteSubFoldersFromLoactionFolder(auditId: arrSelectedLocation[index].auditId!, locationId: arrSelectedLocation[index].locationId!)
        
        arrLocationList = obSqlite.getLocationList(isModified: AuditStatus.InComplete)
        arrSelectedLocation = obSqlite.getLocationList(isModified: AuditStatus.Pending)
        colView_LocationList.reloadData()
        colView_SelectedLocation.reloadData()
    }
}

extension BuiltAuditViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView ==  colView_LocationList {
            return CGSize(width: (collectionView.frame.size.width - 30), height:45)
        } else { //if collectionView == colView_SelectedLocation {
            return CGSize(width: (collectionView.frame.size.width / 2 - 20), height:75)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colView_LocationList {
            return arrLocationList.count
        } else if collectionView == colView_SelectedLocation {
            return arrSelectedLocation.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuiltLocationCell", for: indexPath) as! BuiltLocationCell
        cell.index = indexPath.row
        
        if collectionView == colView_LocationList {
            cell.lbl_Name.text = arrLocationList[indexPath.row].locationName
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
        
        print("dragSessionDidEnd \(session)")
        if flagIsAddedSelectedLocation! {
            
            _ = obSqlite.updateBuiltAuditLocation(isModified: AuditStatus.Pending, locationId: arrLocationList[intSelectedIndexPath].locationId!, auditId: arrLocationList[intSelectedIndexPath].auditId!)
            
            arrLocationList = obSqlite.getLocationList(isModified: AuditStatus.InComplete)
            arrSelectedLocation = obSqlite.getLocationList(isModified: AuditStatus.Pending)
            colView_LocationList.reloadData()
            colView_SelectedLocation.reloadData()
            flagIsAddedSelectedLocation = false
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        
        intSelectedIndexPath = indexPath.row
        print("dragPreviewParametersForItemAt = \(indexPath.row)")
        
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
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            
            if collectionView == colView_LocationList {
                // for getting index path
                if let indexPath = coordinator.destinationIndexPath {
                }
            } else if collectionView == colView_SelectedLocation {
                flagIsAddedSelectedLocation = true
            }
            
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
            collectionView.reloadData()
            
            switch coordinator.proposal.operation
            {
            case .move:
                //Add the code to recorder items
                print("coordinator.proposal.operation = move")
                break
                
            case .copy:
                //Add the code to copy items
                print("coordinator.proposal.operation = copy")
                break
                
            case .forbidden:
                print("coordinator.proposal.operation = forbidden")
                break
                
            case .cancel:
                print("coordinator.proposal.operation = cancel")
                break
                
            default:
                return
            }
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

extension BuiltAuditViewController: UITextViewDelegate {
    
    // Textview Delegate Method
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write here..." {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGray
            textView.text = "Write here..."
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.autocorrectionType = .no
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
 
*/
