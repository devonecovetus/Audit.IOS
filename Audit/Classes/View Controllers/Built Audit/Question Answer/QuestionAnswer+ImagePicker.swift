//
//  QuestionAnswer+ImagePicker.swift
//  Audit
//
//  Created by Rupesh Chhabra on 01/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

extension QuestionAnswerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        autoreleasepool {
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            picker.dismiss(animated: false, completion: nil)
            self.flagIsReloadTableView = true
            self.executeUIProcess {
                autoreleasepool {
                    self.imagePicker?.delegate = nil
                    self.imagePicker = UIImagePickerController()
                    let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
                    photoEditor.photoEditorDelegate = self
                    photoEditor.image = image
                    if self.view_InspectorQuestion.alpha == 1.0 {
                        self.imgView_Inspector.image = image
                    } else {
                        self.img_resizing = image
                    }
                    photoEditor.hiddenControls = [.share, .save, .sticker]
                    self.present(photoEditor, animated: false, completion: nil)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.flagIsReloadTableView = false
        dismiss(animated: true, completion: nil)
    }
}

extension QuestionAnswerViewController: PhotoCollectionDelegate {
    
    func addphotoClick(index: Int) {
        if (arrPhotos?.count)! < 8 {
            photobtnclick = "collection"
            imagePicker = UIImagePickerController()
            imagePicker?.delegate = self
            MF.openActionSheet(with: imagePicker!, and: self, targetFrame: CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0), isShowArrow: false)
        } else {
            self.showAlertViewWithMessage("You can't add more than 8 images in a folder.", vc: self)
        }
    }
    
    func deleteClick(index: Int) {
        let isDeleted = obSqlite.deleteSubLocationSubFolderPhoto(incId: (self.arrPhotos?[index].incId!)!, auditId: 0, locationId: 0, sublocationId: 0, deleteType: "incID")
        if isDeleted {
            arrPhotos?.remove(at: index)
            self.colView_photo.reloadData()
        }
    }
}
