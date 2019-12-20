//
//  EditProfile+PhotoEditor.swift
//  Audit
//
//  Created by Rupesh Chhabra on 20/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

extension EditProfileViewController: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
        imgView_User?.image = image
    }
    
    func canceledEditing() {
        //print("Canceled")
    }
}
