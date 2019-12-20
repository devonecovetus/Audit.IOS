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
    static let XLS = "xls"
}

let ChatFolder = "ChatFiles"
let AuditFolder = "AuditImages"
let AuditReports = "AuditReports"
let AuditContentData = "AuditData"

class FileDownloaderManager: NSObject {
    
    func downloadFileDataInBackground(arrParam: [String]) {
        let path = arrParam[0]
        let name = arrParam[1]
        let fExtension = arrParam[2]
        //print("path = \(path)\n name = \(name)")
        do {
            let  path2 = path.replacingOccurrences(of: " ", with: "")
            let url = URL(string: path2)
            let fileData = try? Data.init(contentsOf: url!)
            if fileData == nil {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                SHOWALERT.showAlertViewWithDuration("File may be corrupted or improper format")
                return
            }
            
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = String(format: "%@.%@", name, fExtension)
            //Check file exist or not
            //print("check file exit = \(checkFileExistOrNot(path: path2, AndName: name, AndFileExtension: fExtension))")
            if checkFileExistOrNot(path: path2, AndName: name, AndFileExtension: fExtension).0 == false {
                let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
                //print("actualPath = \(actualPath)")
                do {
                    try fileData?.write(to: actualPath, options: .atomic)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.showAlertMessage(strFileType: "File")
                    }
                    //print("File saved successfully")
                } catch {
                    //print("file could not be saved")
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                }
            } else {
                DispatchQueue.main.async(execute: {
                    SHOWALERT.showAlertViewWithDuration("File already downloaded")
                })
            }
        } catch {
            //print("FileDownloading problem")
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
                //print("Everyone is fine, file downloaded successfully. data =\(data?.count)")
                let imgD: UIImage = UIImage(data: data!)!
                UIImageWriteToSavedPhotosAlbum(imgD, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
            } else  {
                //print("Failed")
            }
        }
        task.resume()
    }
    
    @objc func image(image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: AnyObject!) {
        if (error != nil) {
            //print("error in downloading")
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        } else {
            // Everything is alright.
            DispatchQueue.main.async {
                self.showAlertMessage(strFileType: "Image")
                SVProgressHUD.dismiss()
            }
            //print("Img Download")
        }
    }
    
     func checkFileExistOrNot(path: String, AndName name: String, AndFileExtension fExtension: String)-> (Bool, String) {
        var status = false
    var strUrl = ""
        let fileName = String(format: "%@.%@", name, fExtension)
        do {
            let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
            for url in contents {
                
                if url.description.contains(fileName) {
                    //print("url = \(url)")
                    strUrl = url.absoluteString
                    status = true
                }
            }
        } catch {
            //print("could not locate pdf file !!!!!!!")
        }
        return (status, strUrl)
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
    
    /// This function checks the file path, if it is exist it returns true and path else false
    func downloadChatFileDataInBackground(arrParam: [String], callBack: @escaping ((_ isExist:Bool, _ filePath: String) -> Void))  {
        DispatchQueue.main.async {
        let path = arrParam[0]
        let name = arrParam[1]
        let fExtension = arrParam[2]
        
        let  path2 = path.replacingOccurrences(of: " ", with: "_")
        let url = URL(string: path2)
        let fileNameFromUrl = String(format: "%@.%@", name, fExtension)
        let actualPath = self.getMediaDirectoryIfNotExist().appendingPathComponent(fileNameFromUrl)
        //print("actualPath = \(actualPath)")

        let fileData = try? Data.init(contentsOf: url!)
        do {
            try fileData?.write(to: actualPath, options: .atomic)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.showAlertMessage(strFileType: "File")
            }
             //print("File saved successfully")
             callBack(true, actualPath.absoluteString)
        } catch {
            //print("file could not be saved")
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
       }
    }
    
    /// This function checks the file path, if it is exist it returns true and path else false
    func downloadAuditReportInBackground(arrParam: [String], callBack: @escaping ( _ filePath: String) -> Void)  {
        DispatchQueue.main.async {
            
            let path = arrParam[0]
            let name = arrParam[1]
            let fExtension = arrParam[2]
            
            let  path2 = path.replacingOccurrences(of: " ", with: "_")
            let url = URL(string: path2)
            let fileNameFromUrl = String(format: "%@.%@", name, fExtension)
            let actualPath = self.getAuditReportDirectoryIfNotExist().appendingPathComponent(fileNameFromUrl)
            //print("actualPath = \(actualPath)")
            
            let fileData = try? Data.init(contentsOf: url!)
            do {
                try fileData?.write(to: actualPath, options: .atomic)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlertMessage(strFileType: "File")
                }
                //print("File saved successfully")
                callBack(actualPath.absoluteString)
            } catch {
                //print("file could not be saved")
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func getMediaDirectoryIfNotExist() -> URL {
        let documentsDirectory = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let dataPath = documentsDirectory.appendingPathComponent(ChatFolder)
        if FileManager.default.fileExists(atPath: dataPath.path) == false {
            do {
                try FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: false, attributes: nil)
                return dataPath
            } catch let error as NSError {
                //print(error.localizedDescription);
            }
        }
        return dataPath
    }
    
    /**
     This function check path for Audit images folder, if it is exist it will return path else create and reutrn. This folder will be created in library
     */
    func getAuditDirectoryIfNotExist() -> URL {
        let documentsDirectory = (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)).last! as URL
        let dataPath = documentsDirectory.appendingPathComponent(AuditFolder)
        if FileManager.default.fileExists(atPath: dataPath.path) == false {
            do {
                try FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: false, attributes: nil)
                return dataPath
            } catch let error as NSError {
                //print(error.localizedDescription);
            }
        }
        return dataPath
    }
    
    /**
     This function check path for Audit images folder, if it is exist it will return path else create and reutrn. This folder will be created in library
     */
    func getAuditReportDirectoryIfNotExist() -> URL {
        let documentsDirectory = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let dataPath = documentsDirectory.appendingPathComponent(AuditReports)
        if FileManager.default.fileExists(atPath: dataPath.path) == false {
            do {
                try FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: false, attributes: nil)
                return dataPath
            } catch let error as NSError {
                //print(error.localizedDescription);
            }
        }
        return dataPath
    }
    
    func createAndGetAuditContentDirectory() -> URL {
        let libraryDirectory = (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)).last! as URL
        let dataPath = libraryDirectory.appendingPathComponent(AuditContentData)
            do {
                try FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: false, attributes: nil)
                return dataPath
            } catch let error as NSError {
                //print(error.localizedDescription);
            }
        return dataPath
    }
    
    func getAuditContentDirectory() -> URL {
        let libraryDirectory = (FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)).last! as URL
        let dataPath = libraryDirectory.appendingPathComponent(AuditContentData)
        return dataPath
    }
    
   
    //func saveAuditDataContent(fileUrl: String, callBackFile: @escaping ((_ resultantDictionary: String) -> Void)) {
    func saveAuditDataContent(fileUrl: String, callBackFile: @escaping ((_ filePath: String) -> Void)) {
        DispatchQueue.main.async(execute: {
            
        
        let fileNameFromUrl = String(format: "%@.%@", "AuditContent", "json")
        let actualPath = self.createAndGetAuditContentDirectory().appendingPathComponent(fileNameFromUrl)
        let fileData = try? Data.init(contentsOf: URL(string: fileUrl)!)
        do {
            try fileData?.write(to: actualPath, options: .atomic)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            //print("File saved successfully")
            callBackFile(actualPath.absoluteString)
        } catch {
            //print("file could not be saved")
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
        })
    }
    
    /**
     This func save the audit report from report list
     */
    
    func saveAuditReport(reportLink: URL, callback: @escaping ((_ filePath: URL) -> Void)) {
        DispatchQueue.main.async {
            
            var reportPath = self.getAuditReportDirectoryIfNotExist()
            
            let reportName = "report\(dc.getCurrentDateTime_YMD_HMS()).pdf"
            reportPath = reportPath.appendingPathComponent(reportName)
            do {
                try self.getDataFrom(url: reportLink).write(to: reportPath)
                callback(reportPath)
            } catch let fileError as NSError {
                 //print("Audit img saving error = \(fileError.debugDescription)")
            }
        }
    }
    
    func getDataFrom(url: URL) -> Data {
        var fileData = Data()
            do {
                fileData = try Data(contentsOf: url)
                return fileData
            } catch let error as NSError {
                //print("Unable to load data: \(error.debugDescription)")
            }
        return fileData
    }
    
    
    /**
     This func save the audit image in audit folder and return back image save name so database will be updated
     */
    func saveAuditImage(imgData: Data, callback: @escaping ((_ fileName: String) -> Void)) {
        
        DispatchQueue.main.async {
            var imagePath = self.getAuditDirectoryIfNotExist()//.appendingPathComponent(FolderName)
            
            let imagename = ("image\(dc.getCurrentDateTime_YMD_HMS()).png")
            imagePath = imagePath.appendingPathComponent(imagename)
            do {
                try imgData.write(to: imagePath)
                //print("imagePath = \(imagePath.path)")
                callback(imagename)
            } catch let fileError as NSError {
                //print("Audit img saving error = \(fileError.debugDescription)")
            }
        }
    }
    
    func deleteAuditImage(fileName: String) {
        var filePath = self.getAuditDirectoryIfNotExist()
        filePath = filePath.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(atPath: filePath.absoluteString)
            //print("FIle Deleted")
        } catch let error as Error {
            //print("error = \(error.localizedDescription)")
        }
        
    }
    
    func getAuditImagePath(imageName: String) -> String {
        return getAuditDirectoryIfNotExist().appendingPathComponent(imageName).path
    }
    
    
    func checkMediaFileExistOrNot(arrParam: [String]) -> Bool {
      
        let path = arrParam[0]
        let name = arrParam[1]
        let fExtension = arrParam[2]

        let fileNameFromUrl = String(format: "%@.%@", name, fExtension)
        let actualPath = getMediaDirectoryIfNotExist().appendingPathComponent(fileNameFromUrl)
        if FileManager.default.fileExists(atPath: actualPath.absoluteString) {
          return true
        }
        return false
    }
    
    func checkReportFileExistOrNot(arrParam: [String]) -> (Bool, URL) {
        
        let path = arrParam[0]
        let name = arrParam[1]
        let fExtension = arrParam[2]
        
        let fileNameFromUrl = String(format: "%@.%@", name, fExtension)
        //print("fileName = \(fileNameFromUrl)")
        let actualPath = getAuditReportDirectoryIfNotExist().appendingPathComponent(fileNameFromUrl)
        //print("actualPath = \(actualPath)")
        if FileManager.default.fileExists(atPath: actualPath.absoluteString) {
            return (true, actualPath)
        }
        return (false, actualPath)
    }
    
}
