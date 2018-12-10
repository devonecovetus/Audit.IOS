//
//  BuiltAuditViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 15/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class BuiltAuditViewController: UIViewController {
    
    var intAuditId:Int? = Int()
    var counter: Int? = Int()
    var intSelectedIndexPath = Int()
    var flagIsAddedSelectedLocation: Bool? = Bool()
    var arrLocationList = [LocationModel]()
    var arrSelectedLocation = [LocationModel]()
    let cell = BuiltLocationCell()
    var isShowDeleteBtn = false
    ///This value hold the number for counts in folder list of a particular location
    var intFolderListCounter = Int()
    
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
        vc?.intAuditId = intAuditId
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBOutlet weak var tv_Description: UITextView!
    
    @IBOutlet weak var lbl_Information: UILabel!
    @IBOutlet weak var btn_Delete: UIButton!
    
    var is_draft = false

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
        
        let checkdraft = obSqlite.getAuditStatusInfoWithAuditID(auditId: intAuditId!)
        if checkdraft != 0 {
            is_draft = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        self.getLocationList()
        self.getSelectedLocationList()
    }

    override func viewDidAppear(_ animated: Bool) {
    }
    
    func getLocationList() {
        self.arrLocationList = obSqlite.getLocationList(isModified: AuditStatus.InComplete, auditId: intAuditId!)
        self.colView_LocationList.reloadData()
    }
    
    func getSelectedLocationList() {
        self.arrSelectedLocation = obSqlite.getLocationList(isModified: AuditStatus.Pending, auditId: intAuditId!)
        self.colView_SelectedLocation.reloadData()
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
   
}

extension BuiltAuditViewController: BuiltLocationDelegate {
    func increaseValue(index: Int) {
        
        if arrSelectedLocation[index].isLocked == 0 { ///  This showing that currently the main work on this location is not done, user can operate all their stuff
            counter = arrSelectedLocation[index].locationCount
            counter! += 1
            
            _ = obSqlite.updateBuiltAuditLocationCount(count: counter!, locationId: arrSelectedLocation[index].locationId!, auditId: arrSelectedLocation[index].auditId!)
            
            arrSelectedLocation[index].locationCount = counter
            colView_SelectedLocation.reloadData()
        }
        
    }
    
    func decreaseValue(index: Int) {
        
         if arrSelectedLocation[index].isLocked == 0 { ///  This showing that currently the main work on this location is not done, user can operate all their stuff
            intFolderListCounter = 0
            counter = arrSelectedLocation[index].locationCount
            
            for i in 0..<arrSelectedLocation[index].arrFolders.count {
                let obFolder = arrSelectedLocation[index].arrFolders[i]
                intFolderListCounter = intFolderListCounter + obFolder.folderCount!
            }
            print("counter = \(counter) , intFolderListCounter = \(intFolderListCounter)")
            /// This condition for checking, the location count and folder list count, if they are equalled during decreasing the counter, then if condition executes
            if counter == intFolderListCounter {
                /// Here we will show an alert,
                showAlertOnDecreaseLocationCount(index: index)
            } else {
                if counter! > 1 {
                    counter! -= 1
                    _ = obSqlite.updateBuiltAuditLocationCount(count: counter!, locationId: arrSelectedLocation[index].locationId!, auditId: arrSelectedLocation[index].auditId!)
                    arrSelectedLocation[index].locationCount = counter
                    colView_SelectedLocation.reloadData()
                }
            }
        }
    }
    
    /// delete the selected location
    func deleteItem(index: Int, indexPath: IndexPath) {
        
        deleteSelectedLocation(index: index, indexPath: indexPath)
        
        /*if arrSelectedLocation[index].isLocked == 0 { ///  This showing that currently the main work on this location is not done, user can operate all their stuff
        } else {
        } */
    }
    
    /// This function calls only when location counter and folder list counter are same on decreasing the location count value
    func showAlertOnDecreaseLocationCount(index: Int) {
        ///** In future this will be replaced by a custom popup.
        
        let alert = UIAlertController(title: NSLocalizedString("warningTitle", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 16.0)!]
        
        let strMsg = NSLocalizedString("warning1", comment: "") + arrSelectedLocation[index].locationName!  + " " + NSLocalizedString("warning2", comment: "")
        let messageAttrString = NSMutableAttributedString(string: strMsg, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let okButton = UIAlertAction(title:"Yes", style: UIAlertActionStyle.default) { (UIAlertAction) in
            //1. delete location subfolder list data on basis of folder id, location_id, auditid, userId
            //2. delete location folder list data on basis of location id and then executes just after 2 seconds
            obSqlite.deleteLocationSubFolders(auditId: self.arrSelectedLocation[index].auditId!, locationId: self.arrSelectedLocation[index].locationId!)
            
            let delay = 0.5 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                if self.counter! > 1 {
                    self.counter! -= 1
                    _ = obSqlite.updateBuiltAuditLocationCount(count: self.counter!, locationId: self.arrSelectedLocation[index].locationId!, auditId: self.arrSelectedLocation[index].auditId!)
                    self.arrSelectedLocation[index].locationCount = self.counter
                    self.colView_SelectedLocation.reloadData()
                }
            })
        }
        let cancelButton = UIAlertAction(title:"No", style: UIAlertActionStyle.default) { (UIAlertAction) in
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /// This function will delete the data from database related to seleced location
    func deleteSelectedLocation(index: Int, indexPath: IndexPath) {
        let alert = UIAlertController(title: "", message: "If you delete your selected location, your all related data and their contents also deleted. Woul you like to continue?", preferredStyle: UIAlertControllerStyle.alert)
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 16.0)!]
        let strMsg = NSLocalizedString("warning1", comment: "") + arrSelectedLocation[index].locationName!  + " " + NSLocalizedString("warning2", comment: "")
        let messageAttrString = NSMutableAttributedString(string: strMsg, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let okButton = UIAlertAction(title:"Yes", style: UIAlertActionStyle.default) { (UIAlertAction) in
            /// This will set status and on that behalf both array will be updated
            _ = obSqlite.updateBuiltAuditLocation(isModified: AuditStatus.InComplete, locationId: self.arrSelectedLocation[index].locationId!, auditId: self.arrSelectedLocation[index].auditId!)
            _ = obSqlite.updateBuiltAuditLocationCount(count: 1, locationId: self.arrSelectedLocation[index].locationId!, auditId: self.arrSelectedLocation[index].auditId!)
            
            let isDeleted = obSqlite.deleteFoldersFromLoactionFolder(auditId: self.arrSelectedLocation[index].auditId!, locationId: self.arrSelectedLocation[index].locationId!)
            if isDeleted {
                /// This Will delete location Folders subfolder list
                obSqlite.deleteLocationSubFolders(auditId: self.arrSelectedLocation[index].auditId!, locationId: self.arrSelectedLocation[index].locationId!)
            }
            
            self.arrLocationList = obSqlite.getLocationList(isModified: AuditStatus.InComplete, auditId: self.intAuditId!)
            self.arrSelectedLocation = obSqlite.getLocationList(isModified: AuditStatus.Pending, auditId: self.intAuditId!)
            self.colView_LocationList.reloadData()
            self.colView_SelectedLocation.reloadData()
        }
        let cancelButton = UIAlertAction(title:"No", style: UIAlertActionStyle.default) { (UIAlertAction) in
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
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
        
        print("dragSessionDidEnd \(session)")
        if flagIsAddedSelectedLocation! {
            
            tv_Description.text = arrLocationList[intSelectedIndexPath].locationDescription!.htmlToString
            lbl_Information.text =  String(format: "%@ %@", arrLocationList[intSelectedIndexPath].locationName!, NSLocalizedString("Description:", comment: ""))
            
            if is_draft == false {
                let arr = obSqlite.updateAuditWorkStatus(auditStatus: AuditStatus.Pending, auditId: intAuditId!)
                if arr[0] as! Bool == true {
                    is_draft = true
                }
            }
            
            _ = obSqlite.updateBuiltAuditLocation(isModified: AuditStatus.Pending, locationId: arrLocationList[intSelectedIndexPath].locationId!, auditId: arrLocationList[intSelectedIndexPath].auditId!)
            
            arrLocationList = obSqlite.getLocationList(isModified: AuditStatus.InComplete, auditId: intAuditId!)
            arrSelectedLocation = obSqlite.getLocationList(isModified: AuditStatus.Pending, auditId: intAuditId!)
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
                    print("indexpth in selected location =\(indexPath.row)")
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

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
