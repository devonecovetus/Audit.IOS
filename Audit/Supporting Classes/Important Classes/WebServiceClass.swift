//
//  WebServiceClass.swift
//
//
//  Created by Gourav Joshi on 22/08/16.
//  Copyright © 2016 Gourav Joshi. All rights reserved.
//

import UIKit
import SVProgressHUD

class WebServiceClass: NSObject {

    static let sharedInstanceOfWebServiceClass = WebServiceClass()
    
    func getWebApiData(webService name: String, methodType mType: Int, forContent cType: Int, OnView vc: UIViewController, withParameters dictParams: NSMutableDictionary, IsShowLoader: Bool = true, callBack: @escaping ((_ resultantDictionary: NSDictionary) -> Void)) {
        
        if MF.isInternetAvailable() {
            if IsShowLoader {
                SVProgressHUD.show(withStatus: "Loading....")
            }
            
            let strUrl = NSString(format: "%@%@", Server.BaseURL, name) as String
         
            print("Url = \(strUrl)\n\nParams = \(dictParams)")
            
            let url = NSURL(string: strUrl as String)
            let boundary = "Boundary-\(UUID().uuidString)"
            let body = NSMutableData()
            let request = NSMutableURLRequest(url: url! as URL)
            request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
            if dictParams.count > 0 {
                /**
                 Managing parameters and values except data files
                 */
                for (key, value) in dictParams {
                    if key as! String != "fileKey" && key as! String != "fileData" && key as! String != "multiFiles" {
                        body.appendString(string: "--\(boundary)\r\n")
                        body.appendString(string:"Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                        body.appendString(string:"\(value)\r\n")
                    }
                }
                
                
                /**
                 If single file data, then this condition executes
                 */
                if let fileData = dictParams["fileData"] as? Data {
                    ///file data in multipart form
                    let fileKey = dictParams["fileKey"] as! String
                    if fileData.count > 0 {
                        let filename = "\(UUID().uuidString).png"
                        let mimetype = "application/octet-stream"
                        body.appendString(string: "--\(boundary)\r\n")
                        body.appendString(string: "Content-Disposition: form-data; name=\"\(fileKey)\"; filename=\"\(filename)\"\r\n")
                        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
                        body.append(fileData)
                        body.appendString(string: "\r\n")
                        body.appendString(string: "--\(boundary)--\r\n")
                    }
                    
                } else if let arrFiles =  dictParams["multiFiles"] as? NSMutableArray {
                    /// And if multiple then this.
                    for i in 0..<arrFiles.count {
                        if (arrFiles[i] as! NSDictionary)[MediaFilesMetaDataConstants.FileData] as? Data != nil {
                            let fileKey = String(format: "file_name%d", i + 1)
                            let fileData = (arrFiles[i] as! NSDictionary)[MediaFilesMetaDataConstants.FileData] as! Data
                            let filename = "\(UUID().uuidString).png"
                            let mimetype = "application/octet-stream"
                            body.appendString(string: "--\(boundary)\r\n")
                            body.appendString(string: "Content-Disposition: form-data; name=\"\(fileKey)\"; filename=\"\(filename)\"\r\n")
                            body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
                            body.append(fileData)
                            body.appendString(string: "\r\n")
                            body.appendString(string: "--\(boundary)--\r\n")
                        }
                    }
                }
            }
            print("body data = \(body.length)")
            request.httpBody = body as Data
            
            /**
             Setting the content type
             */
            switch cType {
            case 1:
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                break
            case 2:
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                break
            case 3:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                break
            default:
                break
            }
            
            /**
             Setting the method type
             */
            switch mType {
            case 1:
                request.httpMethod = MethodType.Post
                break
            case 2:
                request.httpMethod = MethodType.Get
                break
            case 3:
                request.httpMethod = MethodType.Put
                break
            default:
                break
            }
            /**
             Here I am creating session data task object to fulfil the API request
             */
            let dataTask = SESSION.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                if response == nil { /// Response fail to get
                    DispatchQueue.main.async(execute: {
                        print("error = \(error.debugDescription)")
                    //    SVProgressHUD.dismiss()
                        let alert = UIAlertController(title : "Network Error: Could not connect to server.", message : "Oops! Network was failed to process your request. Do you want to try again?", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default ,handler:nil))
                        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default ,handler:
                            {(action:UIAlertAction) in
                                self.getWebApiData(webService: name, methodType: mType, forContent: cType, OnView: vc, withParameters: dictParams, callBack: { (dict) in
                                    callBack(dict)
                                })
                        }))
                       // vc.showAlertViewWithDuration(ValidationMessages.strInternalError, vc: vc)
                    })
                } else { /// Response made to get
                    if error != nil {
                        //handle error
                        if IsShowLoader {
                            vc.showAlertViewWithDuration(ValidationMessages.strInternalError, vc: vc)
                        }
                    } else if let data = data {
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]//[AnyHashable: Any]
                            print("json response = \(jsonObject)")
                            DispatchQueue.main.async(execute: {
                                SVProgressHUD.dismiss()
                            })
                            DispatchQueue.main.async(execute: {  /// pass the response to destination View
                                if (jsonObject as NSDictionary)["status"] as? Int == 1 {
                                    callBack(jsonObject as NSDictionary)
                                } else if (jsonObject as NSDictionary)["status"] as? Int == 2 {
                                    SHOWALERT.showAlertViewWithDuration("Your account is already logged in on another device, Try logging in again!")
                                    MF.logoutAndClearAllSessionData()
                                } else if (jsonObject as NSDictionary)["message"] as! String == "auth token is invalid!" {
                                    //vc.showAlertViewWithDuration("Your account is already logged in on another device, Try logging in again!", vc: vc)
                                    SHOWALERT.showAlertViewWithDuration("Your account is already logged in on another device, Try logging in again!")
                                    MF.logoutAndClearAllSessionData()
                                } else {
                                    if IsShowLoader {
                                        vc.showAlertViewWithDuration((jsonObject as NSDictionary)["message"] as! String, vc: vc)
                                    }
                                }
                            })
                        } catch {
                            let str = String.init(data: data, encoding: .utf8)
                            print("str = \(String(format: "%@", str!))")
                            SVProgressHUD.dismiss()
                            if IsShowLoader {
                                vc.showAlertViewWithDuration(ValidationMessages.strServerError, vc: vc)
                            }
                        }
                    }
                }
            })
            DispatchQueue.main.suspend()
            DispatchQueue.main.resume()
            dataTask.resume()
            SESSION.finishTasksAndInvalidate()
        } else {
            SHOWALERT.showAlertViewWithMessage(ValidationMessages.strInternetIsNotAvailable)
        }
    }
}
