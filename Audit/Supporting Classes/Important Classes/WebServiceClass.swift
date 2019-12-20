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
    var SESSION = URLSession.shared
    var uploadTask: URLSessionDataTask?
    var downloadTask: URLSessionDownloadTask?
    static let sharedInstanceOfWebServiceClass = WebServiceClass()
    
    func getWebApiData(webService name: String, methodType mType: Int, forContent cType: Int, OnView vc: UIViewController, withParameters dictParams: NSMutableDictionary, IsShowLoader: Bool = true, callBack: @escaping ((_ resultantDictionary: NSDictionary) -> Void)) {
        
        let dataUploadSession: URLSession = { () -> URLSession in
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 180000
            configuration.timeoutIntervalForResource = 180000
            return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }()
        
        // Check if internet is available before proceeding further
        if MF.isInternetAvailable() {
                // Go ahead and fetch your data from the internet
                // ...
                if IsShowLoader {
                    SVProgressHUD.show(withStatus: "Loading....")
                }
                let strUrl = NSString(format: "%@%@", Server.BaseURL, name) as String
             //  print("Url = \(strUrl)\n\n params = \(dictParams)")
               // print("Url = \(strUrl)")
                
                if name != WebServiceName.GetAuditSync {
                    //    //print("dictParams = \(dictParams)")
                }
                
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
                    }
                    if let fileString = dictParams["fileData1"] as? String {
                        ///file data in multipart form
                        let fileKey = dictParams["fileKey1"] as! String
                        if fileString.count > 0 {
                            body.appendString(string: "--\(boundary)\r\n")
                            body.appendString(string:"Content-Disposition: form-data; name=\"\(fileKey)\"\r\n\r\n")
                         //   //print("fileData size = \((fileString.utf8.count / 1024)) KB")
                            body.appendString(string:"\(fileString)\r\n")
                        }
                    }
                    if let fileString2 = dictParams["fileData2"] as? String {
                        ///file data in multipart form
                        let fileKey = dictParams["fileKey2"] as! String
                        if fileString2.count > 0 {
                            body.appendString(string: "--\(boundary)\r\n")
                            body.appendString(string:"Content-Disposition: form-data; name=\"\(fileKey)\"\r\n\r\n")
                            body.appendString(string:"\(fileString2)\r\n")
                        }
                    }
                    
                    if let fileString3 = dictParams["fileDataQ"] as? String {
                        ///file data in multipart form
                        let fileKey = dictParams["fileKeyQ"] as! String
                        if fileString3.count > 0 {
                            body.appendString(string: "--\(boundary)\r\n")
                            body.appendString(string:"Content-Disposition: form-data; name=\"\(fileKey)\"\r\n\r\n")
                            body.appendString(string:"\(fileString3)\r\n")
                        }
                    }
                
                    
                    if let arrFiles =  dictParams["multiFiles"] as? NSMutableArray {
                        /// And if multiple then this.
                        for i in 0..<arrFiles.count {
                            
                            if (arrFiles[i] as! NSDictionary)["fileDataM"] as? String != nil {
                                let fileKey = String(format: "%@", (arrFiles[i] as! NSDictionary)["fileKeyM"] as! String)
                                let fileData = (arrFiles[i] as! NSDictionary)["fileDataM"] as! String
                            //    //print("fileData size = \((fileData.utf8.count / 1024)) KB")
                                body.appendString(string: "--\(boundary)\r\n")
                                body.appendString(string:"Content-Disposition: form-data; name=\"\(fileKey)\"\r\n\r\n")
                                body.appendString(string:"\(fileData)\r\n")
                            }
                        }
                    }
                }
              //  //print("body data = \(body.length)")
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
                uploadTask = dataUploadSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                    if response == nil { /// Response fail to get
                     //   DispatchQueue.main.async(execute: {
                           //print("error = \(error?.localizedDescription)")
                            if IsShowLoader {
                                SVProgressHUD.dismiss()
                            } 
                            
                            let alert = UIAlertController(title : "Network Error: Could not connect to server.", message : "Oops! Network was failed to process your request. Do you want to try again?", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default ,handler:nil))
                            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default ,handler:
                                {(action:UIAlertAction) in
                                    self.getWebApiData(webService: name, methodType: mType, forContent: cType, OnView: vc, withParameters: dictParams, callBack: { (dict) in
                                        callBack(dict)
                                    })
                            }))
                            //  vc.showAlertViewWithDuration(ValidationMessages.strInternalError, vc: vc)
                            vc.present(alert, animated: true, completion: nil)
                     //   })
                    } else { /// Response made to get
                        if error != nil {
                            //handle error
                            if IsShowLoader {
                                vc.showAlertViewWithDuration(ValidationMessages.strInternalError, vc: vc)
                            }
                        } else if let data = data {
                            do {
                                let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]//[AnyHashable: Any]
                               //print("json response = \(jsonObject)")
                                DispatchQueue.main.async(execute: {
                                    if IsShowLoader {
                                        SVProgressHUD.dismiss()
                                    }
                                })
                               // DispatchQueue.main.async(execute: {  /// pass the response to destination View
                                    if (jsonObject as NSDictionary)["status"] as? Int == 1 {
                                        callBack(jsonObject as NSDictionary)
                                    } else if (jsonObject as NSDictionary)["status"] as? Int == 2 {
                                        SHOWALERT.showAlertViewWithDuration((jsonObject as NSDictionary)["message"] as! String)
                                        MF.logoutAndClearAllSessionData()
                                    } else {
                                        if IsShowLoader {
                                            if name != WebServiceName.GenerateReport {
                                                vc.showAlertViewWithDuration((jsonObject as NSDictionary)["message"] as! String, vc: vc)
                                            }
                                        }
                                    }
                               // })
                            } catch {
                                let str = String.init(data: data, encoding: .utf8)
                               print("str = \(String(format: "%@", str!))")
                                DispatchQueue.main.async(execute: {
                                    if IsShowLoader {
                                        SVProgressHUD.dismiss()
                                    }
                                })
                                if IsShowLoader {
                                    if name != WebServiceName.GenerateReport {
                                        vc.showAlertViewWithDuration(ValidationMessages.strServerError, vc: vc)
                                    }
                                }
                            }
                        }
                    }
                })
                //DispatchQueue.main.suspend()
               // DispatchQueue.main.resume()
                uploadTask!.resume()
                dataUploadSession.finishTasksAndInvalidate()
                
            
        } else {
            if name == WebServiceName.GetAuditSync {
                NotificationCenter.default.post(name: .internetDisconnect, object: nil)
            }
            SHOWALERT.showAlertViewWithMessage(ValidationMessages.strInternetIsNotAvailable)
        }
    }
    
    
    
}

extension WebServiceClass: URLSessionDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        //print("urlSessionDidFinishEvents")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        //print("didFinishCollecting")
        
    }
    
    /**
     This method is called if the waitsForConnectivity property of NSURLSessionConfiguration is true, and sufficient connectivity is unavailable. The delegate can use this opportunity to update the user interface; for example, by presenting an offline mode or a cellular-only mode.
     
     This method is called, at most, once per task, and only if connectivity is initially unavailable. It is never called for background sessions because waitsForConnectivity is ignored for those sessions.
     */
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        //print("There is a connectivity issue with server side due to networking problem")
        uploadTask?.suspend()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        //print("didCompleteWithError = \(error?.localizedDescription)")
        
    }
    
    func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask) {
        //print("betterRouteDiscoveredFor")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        
    }
}
