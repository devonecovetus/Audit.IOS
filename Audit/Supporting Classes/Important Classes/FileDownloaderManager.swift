//
//  FileDownloaderManager.swift
//  Audit
//
//  Created by Rupesh Chhabra on 17/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

enum FileExtension {
    static let EXCEL = "excel"
    static let PDF = "pdf"
    static let DOC = "doc"
    static let DOCX = "docx"
    static let PNG = "png"
    static let JPG = "jpg"
    static let JPEG = "jpeg"
    static let XLSX = "xlsx"
}

class FileDownloaderManager: NSObject {

    func downloadFileDataInBackground(arrParam: [String]) {
        let path = arrParam[0]
        let name = arrParam[1]
        let fExtension = arrParam[2]
//        print("path = \(path)")
        
        do {
            let  path2 = path.replacingOccurrences(of: " ", with: "_")
            let url = URL(string: path2)
            let fileData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = String(format: "%@.%@", name, fExtension)
            
            //Check file exist or not
//            print("check file exit = \(checkFileExistOrNot(path: path2, AndName: name, AndFileExtension: fExtension))")
            
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            do {
                try fileData?.write(to: actualPath, options: .atomic)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlertMessage(strFileType: "File")
                }
                print("File saved successfully")
            } catch {
                print("file could not be saved")
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
        } catch {
            print("FileDownloading problem")
        }
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    func downloadImageData(strUrl: String) {
         SVProgressHUD.show(withStatus: NSLocalizedString("Downloading....", comment: ""))
        let requestURL: NSURL = NSURL(string: strUrl)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully. data =\(data?.count)")
                let imgD: UIImage = UIImage(data: data!)!
                UIImageWriteToSavedPhotosAlbum(imgD, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
            } else  {
                print("Failed")
            }
        }
        task.resume()
    }
    
    @objc func image(image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: AnyObject!) {
        if (error != nil) {
            print("error in downloading")
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        } else {
            // Everything is alright.
            DispatchQueue.main.async {
                self.showAlertMessage(strFileType: "Image")
                SVProgressHUD.dismiss()
            }
            print("Img Download")
        }
    }
    
  private func checkFileExistOrNot(path: String, AndName name: String, AndFileExtension fExtension: String)-> Bool {
        var status = false
        let fileName = String(format: "%@.%@", name, fExtension)
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains(fileName) {
                        status = true
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        return status
    }
    
    private func showAlertMessage(strFileType: String) {
        var strMsg = ""
        if strFileType == "Image" {
             strMsg = String(format: "%@", NSLocalizedString("PhotoSaved", comment: ""))
        } else {
             strMsg = String(format: "%@", NSLocalizedString("FileSaved", comment: ""))
        }
        SHOWALERT.showAlertViewWithMessage(strMsg)
    }
}
