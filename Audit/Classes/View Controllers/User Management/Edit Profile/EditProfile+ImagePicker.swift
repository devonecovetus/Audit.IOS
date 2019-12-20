//
//  EditProfile+ImagePicker.swift
//  Audit
//
//  Created by Rupesh Chhabra on 20/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        imgView_User?.image = image
        
        photoEditor.hiddenControls = [.share, .save, .sticker]
        present(photoEditor, animated: false, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.flagIsUploadPic = false
        dismiss(animated: true, completion: nil)
    }
}
