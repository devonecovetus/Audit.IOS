//
//  QuestionPopUp+ImagePicker.swift
//  Audit
//
//  Created by Rupesh Chhabra on 02/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

extension QusetionPopupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        picker.dismiss(animated: false, completion: nil)
        
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.photoEditorDelegate = self
        photoEditor.image = image
        imgCaptured = image
        photoEditor.hiddenControls = [.share, .save, .sticker]
        present(photoEditor, animated: false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
