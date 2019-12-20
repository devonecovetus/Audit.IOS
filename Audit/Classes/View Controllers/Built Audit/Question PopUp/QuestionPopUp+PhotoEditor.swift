//
//  QuestionPopUp+PhotoEditor.swift
//  Audit
//
//  Created by Rupesh Chhabra on 02/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

extension QusetionPopupViewController: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
        imgCaptured = image
        photoInsert()
    }
    
    func canceledEditing() {
        photoInsert()
    }
    
    func photoInsert() {
        self.executeUIProcess {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("Saving..", comment: ""))
        }
        
        let obFileManager = FileDownloaderManager()
        obFileManager.saveAuditImage(imgData:((imgCaptured.imageQuality(.low))!), callback: { (fileName) in
            
            if self.intImagePickingType == 1 { /// for measurement question
                self.obAnswer.imgName = fileName
                self.obAnswer.isUpdate = 1
                self.setImageData()
            } else if self.intImagePickingType == 2 {
                self.arrSubAnswers[self.globalindex].imgName = fileName
                self.arrSubAnswers[self.globalindex].isUpdate = 1
                self.reloadTableCell(reloadindex: self.globalindex)
            } else if self.intImagePickingType == 3 {
                self.obInspectorAnswer?.imgName = fileName
                self.obInspectorAnswer?.isUpdate = 1
                self.setSuperAuditInspectorImageData()
            }
            self.executeUIProcess {
                SVProgressHUD.dismiss()
            }
        })
    }
    
    func reloadTableCell(reloadindex: Int) {
        let indexPath = IndexPath(item: reloadindex, section: 0)
        self.tblView_SubQuestions.reloadRows(at: [indexPath], with: .none)
    }
}
