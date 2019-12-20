//
//  FolderViewCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 23/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import MBCircularProgressBar

protocol FolderOperationDelegate {
    func viewFolderDetails(index: Int)
    func archiveFolder(index: Int)
    func editFolder(index: Int)
    func navigateToSubLocationSubFolderList(obSubLocationSubFolder: BuiltAuditSubLocationModel, obLocationSubFolder: LocationSubFolderListModel)
}

class FolderViewCell: UITableViewCell {
    let intDefaultCount = 9
    var intIndex = Int()
    var delegate: FolderOperationDelegate?
    var isArchive = Int()
    var obLocationSubFolder:LocationSubFolderListModel? = LocationSubFolderListModel()
    var arrSubLocationList = [BuiltAuditSubLocationModel]()
    
    @IBOutlet var progressBar: MBCircularProgressBarView!
    
    @IBOutlet weak var imgView_Status: UIImageView!
    @IBOutlet weak var lbl_WorkStatus: UILabel!
    @IBOutlet weak var view_WorkStatus: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var btn_Edit: UIButton!
    @IBOutlet weak var btn_View: UIButton!
    @IBOutlet weak var btn_Archive: UIButton!
    @IBOutlet weak var colView_SLCount: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpLanguageSetting()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUpLanguageSetting() {
        
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Description.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_WorkStatus.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_View.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_View.setTitle(NSLocalizedString("View", comment: ""), for: UIControlState.normal)
        
        if progressBar != nil {
            progressBar.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        }
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_Title.textAlignment = NSTextAlignment.right
            lbl_Description.textAlignment = NSTextAlignment.right
           // lbl_WorkStatus.textAlignment = NSTextAlignment.right
        }
    }
    
    func setUpSubLocationSubFolderData(obSF: SubLocationSubFolderModel) {
        
        isArchive = obSF.isArchive!
        lbl_Title.text = obSF.subFolderName
        lbl_Description.text = obSF.subFolderDescription
        
        if obSF.answeredCount == 0 {
            progressBar.value = CGFloat(0.0)
        } else {
            let totalAnswered: Double = (Double(obSF.answeredCount!) / Double(obSF.totalCount!)) * 100
            progressBar.value = CGFloat(totalAnswered.round(to: 2))
        }
        
        if progressBar.value == 0.0 {
            lbl_WorkStatus.backgroundColor = ProgressColor.InCompleted
            lbl_WorkStatus.text = ProgressText.InCompleted
        } else if progressBar.value > 0.0 && progressBar.value < 100.00 {
            lbl_WorkStatus.backgroundColor = ProgressColor.InProgress
            lbl_WorkStatus.text = ProgressText.InProgress
        } else if progressBar.value == 100.00 {
            lbl_WorkStatus.backgroundColor = ProgressColor.Completed
            lbl_WorkStatus.text = ProgressText.Completed
        }
        
        setArchiveReInitiateView(status: isArchive)
    }
    
    func setUpSubFolderData(obSF: LocationSubFolderListModel) {
        obLocationSubFolder = obSF
        isArchive = obSF.is_archive!
        lbl_Title.text = obSF.subFolderName
        lbl_Description.text = obSF.subFolderDescription
        arrSubLocationList = obSF.arrSubLocationCounter
        setArchiveReInitiateView(status: isArchive)
        colView_SLCount.reloadData()
    }
    
    @IBAction func btn_Archive(_ sender: Any) {
        delegate?.archiveFolder(index: intIndex)
    }
    
    @IBAction func btn_View(_ sender: Any) {
        delegate?.viewFolderDetails(index: intIndex)
    }
    
    @IBAction func btn_Edit(_ sender: Any) {
        delegate?.editFolder(index: intIndex)
    }
    
    private func setArchiveReInitiateView(status: Int) {
        if status == 1 { /// Means it is now archive
            setViewColorToArchiveSetting()
        } else { /// User has set it to reinitiate and user can work
            setViewColorToReInitiateSetting()
        }
    }
    
    private func setViewColorToArchiveSetting() {
        btn_View.backgroundColor = UIColor.lightGray
        btn_View.isUserInteractionEnabled = false
        
        btn_Edit.setImage(UIImage(named: "edit_gray_icon"), for: UIControlState.normal)
        btn_Edit.isUserInteractionEnabled = false
        
        btn_Archive.setTitle(NSLocalizedString("ReInitiate", comment: ""), for: UIControlState.normal)
        btn_Archive.setTitleColor(UIColor.white, for: UIControlState.normal)
        btn_Archive.backgroundColor = UIColor.init(hexString: "13CE66")
        if colView_SLCount != nil {
            colView_SLCount.isUserInteractionEnabled = false
        }
    }
    
    private func setViewColorToReInitiateSetting() {
        btn_View.backgroundColor = UIColor.init(hexString: "13CE66")
        btn_View.isUserInteractionEnabled = true
        
        btn_Edit.setImage(UIImage(named: "ic_blueedit"), for: UIControlState.normal)
        btn_Edit.isUserInteractionEnabled = true
        
        btn_Archive.setTitle(NSLocalizedString("Archive", comment: ""), for: UIControlState.normal)
        btn_Archive.setTitleColor(UIColor.black, for: UIControlState.normal)
        btn_Archive.backgroundColor = UIColor.lightGray
        if colView_SLCount != nil {
            colView_SLCount.isUserInteractionEnabled = true
        }
    }
}

extension FolderViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: DeviceType.IS_PHONE ? 44 : 76, height: DeviceType.IS_PHONE ? 44 : 76)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrSubLocationList.count == 0 {
            return intDefaultCount
        } else {
            /// Here this calculation manages counter value on  finite arr and else set default gray counts
            if arrSubLocationList.count >= intDefaultCount {
                return arrSubLocationList.count
            } else {
                var remain = 0
                remain =  intDefaultCount - arrSubLocationList.count
                return arrSubLocationList.count + remain
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubLocationCounterCell", for: indexPath) as! SubLocationCounterCell
        if arrSubLocationList.count == 0 {
            cell.lbl_Count.text = ""
            cell.backgroundColor = UIColor.lightGray
        } else {
            var remain = 0
            remain =  intDefaultCount - arrSubLocationList.count
            
            if indexPath.row  < (intDefaultCount - remain) {
                
                cell.lbl_Count.text = MF.numberFormatter(number: String(arrSubLocationList[indexPath.row].subLocationCount!))
                if isArchive == 1 {
                    cell.backgroundColor = UIColor.lightGray
                } else {
                    if arrSubLocationList[indexPath.row].workStatus == 0 {
                        cell.backgroundColor = UIColor(red: 249/255.0, green: 95/255.0, blue: 98/255.0, alpha: 1.0)
                    } else if arrSubLocationList[indexPath.row].workStatus == 1 {
                        cell.backgroundColor = UIColor(red: 255/255.0, green: 186/255.0, blue: 91/255.0, alpha: 1.0)
                    } else {
                        cell.backgroundColor = UIColor(red: 19/255.0, green: 206/255.0, blue: 102/255.0, alpha: 1.0)
                    }
                }
            } else {
                cell.lbl_Count.text = ""
                cell.backgroundColor = UIColor.lightGray
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if arrSubLocationList.count > 0 {
            let isExist = arrSubLocationList.indices.contains(indexPath.row)
            if isExist {
                delegate?.navigateToSubLocationSubFolderList(obSubLocationSubFolder: arrSubLocationList[indexPath.row], obLocationSubFolder: obLocationSubFolder!)
            }
            
        }
    }
}


extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}
