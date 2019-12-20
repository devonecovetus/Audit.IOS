//
//  QuestionAnswer+PhotoEditor.swift
//  Audit
//
//  Created by Rupesh Chhabra on 01/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

extension QuestionAnswerViewController: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
        if self.view_InspectorQuestion.alpha == 1.0 {
            self.imgView_Inspector.image = image
            self.img_resizing = image
        } else {
            self.img_resizing = image
        }
        photoInsert()
    }
    
    func canceledEditing() {
        self.flagIsReloadTableView = false
        photoInsert()
    }
    
    func photoInsert() {
        autoreleasepool {
            self.executeUIProcess {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("Saving..", comment: ""))
            }
            
            let obFileManager: FileDownloaderManager? = FileDownloaderManager()
            obFileManager?.saveAuditImage(imgData:((self.img_resizing?.imageQuality(.low))!), callback: { (fileName) in
                
                if self.photobtnclick == "all" {
                    if self.arrMainPhoto?.count != 0{
                        let isDeleted = obSqlite.deleteSubLocationSubFolderPhoto(incId: (self.arrMainPhoto?[0].incId!)!, auditId: 0, locationId: 0, sublocationId: 0, deleteType: "incID")
                        if isDeleted {
                            let obPhoto:SubLocationSubFolder_PhotoModel? = SubLocationSubFolder_PhotoModel()
                            obPhoto?.initWith(auditId: self.intAuditId, locationId: self.intLocationId, folderId: self.intFolderId, subFolderId: self.intSubFolderId, subLocationId: self.intSubLocationId, subLocation_subFolderId: self.intSubLocationSubFolderId, imgName: fileName, main_photo: 1)
                            let rowid = obSqlite.insertPhotosSubLocationSubFolder(oblist: obPhoto!)
                            obPhoto?.incId = rowid
                            self.addNewPhotocell(obPhoto: obPhoto!)
                        }
                    }  else {
                        let obPhoto:SubLocationSubFolder_PhotoModel? = SubLocationSubFolder_PhotoModel()
                        obPhoto?.initWith(auditId: self.intAuditId, locationId: self.intLocationId, folderId: self.intFolderId, subFolderId: self.intSubFolderId, subLocationId: self.intSubLocationId, subLocation_subFolderId: self.intSubLocationSubFolderId, imgName: fileName, main_photo: 1)
                        let rowid = obSqlite.insertPhotosSubLocationSubFolder(oblist: obPhoto!)
                        obPhoto?.incId = rowid
                        self.addNewPhotocell(obPhoto: obPhoto!)
                    }
                    
                } else if self.photobtnclick == "collection" {
                    let obPhoto:SubLocationSubFolder_PhotoModel? = SubLocationSubFolder_PhotoModel()
                    obPhoto?.initWith(auditId: self.intAuditId, locationId: self.intLocationId, folderId: self.intFolderId, subFolderId: self.intSubFolderId, subLocationId: self.intSubLocationId, subLocation_subFolderId: self.intSubLocationSubFolderId, imgName: fileName, main_photo: 0)
                    let rowid = obSqlite.insertPhotosSubLocationSubFolder(oblist: obPhoto!)
                    obPhoto?.incId = rowid
                    self.addNewPhotocell(obPhoto: obPhoto!)
                } else if self.photobtnclick == "superAudit" {
                    self.obInspectorAnswer?.imgName = fileName
                    self.obInspectorAnswer?.isUpdate = 1
                    self.setSuperAuditInspectorImageData()
                } else {
                    self.arrNormalQuestions[self.globalindex].imgName = fileName
                    self.arrNormalQuestions[self.globalindex].isUpdate = 1
                    self.reloadTablecell(reloadindex: self.globalindex)
                }
                
                self.executeUIProcess {
                    SVProgressHUD.dismiss()
                    self.img_resizing = UIImage()
                }
            })
        }
    }
    
    func addNewPhotocell(obPhoto: SubLocationSubFolder_PhotoModel) {
        autoreleasepool {
            if self.photobtnclick == "all" {
                imgView_Photo?.image = img_resizing
                arrMainPhoto?.append(obPhoto) //add your object to data source first
                
                let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showAvatar(_:)))
                tapGestureRecognizer11.numberOfTapsRequired = 1
                imgView_Photo?.addGestureRecognizer(tapGestureRecognizer11)
                img_resizing = nil
            } else {
                btn_Delete.alpha = 1.0
                btn_Delete.isUserInteractionEnabled = true
                
                arrPhotos?.append(obPhoto) //add your object to data source first
                self.colView_photo.reloadData()
            }
            
        }
    }
}
