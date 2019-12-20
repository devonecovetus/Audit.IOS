//
//  Audit+ImagePicker.swift
//  Audit
//
//  Created by Rupesh Chhabra on 27/11/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

extension AuditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        picker.dismiss(animated: false, completion: nil)
        autoreleasepool {
            let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
            
            photoEditor.photoEditorDelegate = self
            self.flagIsUploadPic = true
            photoEditor.image = image
            imgView_Audit.image = image
            
            photoEditor.hiddenControls = [.share, .save, .sticker]
            present(photoEditor, animated: false, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.flagIsUploadPic = false
        dismiss(animated: true, completion: nil)
    }
}

extension AuditViewController: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
        imgView_Audit?.image = image
    }
    
    func canceledEditing() {
        //print("Canceled")
    }
}
