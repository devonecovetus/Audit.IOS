//
//  ChatViewController.swift
//  Audit
//
//  Created by Mac on 10/31/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SocketIO
import MessageUI

class ChatViewController: UIViewController, MFMailComposeViewControllerDelegate {
   
    private var socket:SocketIOClient?
    
    @IBOutlet var inputbar_constraint: NSLayoutConstraint!

    @IBOutlet weak var img_profilepic: DesignableImage!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_role: DesignableLabel!
    
    var reciver_img = UIImage()
    var sender_img = UIImage()

    @IBOutlet weak var inputbar: Inputbar!
    @IBOutlet weak var tableview: UITableView!
    var Message_Array = [ChatModel]()
    var imagePicker = UIImagePickerController()
    
    var sendmsg = ""
    var getmsg = ""
    var arr_ReciverDetail = [AgentListModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view
        IQKeyboardManager.sharedManager().enable = false
        
        reciver_img = UIImage(named: "img_user")!
        sender_img = UIImage(named: "img_user")!
        
        let imgurl = NSURL(string: arr_ReciverDetail[0].profilePic!)
        let senderurl = NSURL(string: UserProfile.photo!)
        
        img_profilepic.sd_setImage(with: imgurl! as URL, placeholderImage: UIImage(named: "img_user"),options: SDWebImageOptions(rawValue: 0), completed: { image, error, cacheType, imageURL in
            // your rest code
            if image != nil {
                self.reciver_img = image!
            }
        })
        
        let task = URLSession.shared.dataTask(with: senderurl! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {    // execute on main thread
                self.sender_img = UIImage(data: data)!
            }
        }
        task.resume()

        lbl_name.text = arr_ReciverDetail[0].name
        lbl_role.text = arr_ReciverDetail[0].role

        tableview.estimatedRowHeight = 80
        tableview.rowHeight = UITableViewAutomaticDimension
        
        self.inputbar.placeholder = "Write msg here...."
        self.inputbar.delegate = self
        self.inputbar.rightButtonImage = (UIImage(named: "send"))
        self.inputbar.leftButtonImage = (UIImage(named: "attachment"))
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.ReceivedNotification), name: NSNotification.Name(rawValue: "KeyboarkUpDwon"), object: nil)
        
        Message_Array = obSqlite.getChat(to_user_id: arr_ReciverDetail[0].agentid!)[0] as! [ChatModel]
        
        // SocketIOClientSingleton Class in socket url
        socket = SocketIOClientClass.instance.socket
        socket?.connect()
        // socket event
        socket?.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.socket?.emit("load id", UserProfile.id!)
            self.loadChat(chattype: self.getmsg, receiver_id: String(self.arr_ReciverDetail[0].agentid!), sender_id: String(UserProfile.id!), hardcoded_str: "1", update_chatmessage: self.sendmsg)
        }
        
        socket?.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnect Reconnect")
            self.socket?.connect()
            self.socket?.emit("load id", UserProfile.id!)
        }
        
        socket?.on(clientEvent: .error) {data, ack in
            print("socket error")
        }
        socket?.on(clientEvent: .reconnectAttempt) {data, ack in
            print("socket message detail reconnectAttempt")
            self.socket?.manager?.reconnects = true
        }
        self.socket?.manager?.forceNew = true
        if socket?.status == .connected {
            print( "Your connection connected")
            self.loadChat(chattype: self.getmsg, receiver_id: String(self.arr_ReciverDetail[0].agentid!), sender_id: String(UserProfile.id!), hardcoded_str: "1", update_chatmessage: self.sendmsg)
        }
        
    }
    
    func loadChat(chattype:String, receiver_id:String, sender_id:String, hardcoded_str:String, update_chatmessage:String){
        
        socket?.off(chattype)
        socket?.off(update_chatmessage)
        
        socket?.emit(chattype, receiver_id, sender_id, hardcoded_str)
        
        socket?.on(chattype) {data, ack in
            let jsonText = data[0] as! NSString
            var dictonary:NSDictionary?
            
            if let data = jsonText.data(using: String.Encoding.utf8.rawValue) {
                do {
                    dictonary = try ((JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary))
                    if let myDictionary = dictonary
                    {
                        print("Socket response \(myDictionary["chats"]!)")
                        
                        if self.Message_Array.count == (myDictionary["chats"] as! NSArray).count {
                            return
                        } else if self.Message_Array.count < (myDictionary["chats"] as! NSArray).count {
                            
                            let i = (myDictionary["chats"] as! NSArray).count - self.Message_Array.count
                            
                            let buffer = (myDictionary["chats"] as! NSArray).count - i
                            
                            for k in buffer..<(myDictionary["chats"] as! NSArray).count  {
                                let obRequest = ChatModel()
                                
                                let mydict = (myDictionary["chats"] as! NSArray)[k] as! NSDictionary
                                let from_name = mydict["from_name"] as! String
                                let from_id = mydict["from"] as! Int

                                if UserProfile.id == from_id {
                                    obRequest.initWith(to_user_id: Int(receiver_id)!, is_download: 1, from_name: from_name, dict: mydict)
                                }
                                else {
                                    obRequest.initWith(to_user_id: Int(receiver_id)!, is_download: 0, from_name: from_name, dict: mydict)
                                }
                                
                                let success = obSqlite.insertChatData(obchat: obRequest)
                                
                                if success == true {
                                    let incId_DB = obSqlite.getChatLastId()
                                    print(incId_DB)
                                    obRequest.incId = incId_DB
                                }
                                self.Message_Array.append(obRequest)
                            }
                        }
                        
                        self.Load_Table(loadtype: "all")
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        
        // message update
        socket?.on(update_chatmessage) {data, ack in
            let jsonText = data[1] as! NSString
            var dictonary:NSDictionary?
            if let data = jsonText.data(using: String.Encoding.utf8.rawValue) {
                do {
                    dictonary = try ((JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary))
                    if let myDictionary = dictonary {
                        let tempNames: NSArray = (myDictionary["response"] as? NSArray)!
                        let list = tempNames[0] as! NSDictionary
                        
                        if case String(UserProfile.id!) = (list["from"] as? String)! {
                        }
                        else {
                            let obRequest = ChatModel()
                            obRequest.initWith(to_user_id: Int(receiver_id)!, is_download: 0, from_name: self.arr_ReciverDetail[0].name!, dict: list)
                            
                            let success = obSqlite.insertChatData(obchat: obRequest)
                            
                            if success == true {
                                let incId_DB = obSqlite.getChatLastId()
                                print(incId_DB)
                                obRequest.incId = incId_DB
                            }
                            self.Message_Array.append(obRequest)

                            self.Load_Table(loadtype: "")
                        }
                        return
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    func Load_Table(loadtype: String) {
        if loadtype == "all" {
            tableview.reloadData()
            if self.Message_Array.count == 0 { return } else {
                let indexPath = IndexPath(row: self.Message_Array.count - 1, section: 0)
                self.tableview.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        } else {
            scrollToBottom()
        }
    }
    
    private func scrollToBottom() {
        let indexPath = IndexPath(row: (self.Message_Array.count) - 1, section: 0)
        tableview.beginUpdates()
        tableview.insertRows(at: [indexPath], with: UITableViewRowAnimation.none)
        tableview.endUpdates()
        self.tableview.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    @objc func ReceivedNotification(notification: NSNotification) {
        let myDict = notification.userInfo
        
        let KeybordType = (myDict! ["someKey"] as? String)!
        
        if KeybordType == "KeyboarUp" {
            
            let height = (myDict! ["height"] as? String)!
            
            var height_float = Float(0.0)
            
          //  height_float = Float(height)! - 44
            height_float = Float(height)!

            inputbar_constraint.constant = CGFloat(-height_float)
            tableview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)

            self.executeUIProcess {
                self.Load_Table(loadtype: "all")
            }
            
         //   tableview.contentInset = UIEdgeInsetsMake(0, 0, CGFloat(height_float), 0)
            
            if self.Message_Array.count == 0 {
            } else {
                let indexPath = IndexPath(row: (self.Message_Array.count) - 1, section: 0)
                tableview.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        } else {
            inputbar_constraint.constant = 0
            tableview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            if self.Message_Array.count == 0 {
            } else {
                let indexPath = IndexPath(row: (self.Message_Array.count) - 1, section: 0)
                tableview.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_dots(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Call", style: .default) { (action:UIAlertAction) in
        
            if let url = URL(string: "tel://\(String(describing: self.arr_ReciverDetail[0].phone))"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        
        let action2 = UIAlertAction(title: "Email", style: .default) { (action:UIAlertAction) in

            if !MFMailComposeViewController.canSendMail() {
                print("Mail services are not available")
                return
            }

            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients([self.arr_ReciverDetail[0].email!])
            composeVC.setSubject("")
            composeVC.setMessageBody("", isHTML: false)
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        }
        
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed the destructive");
        }
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        IQKeyboardManager.sharedManager().enable = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        self.executeUIProcess {
            self.Load_Table(loadtype: "all")
        }
        
        self.view.keyboardTriggerOffset = self.inputbar.frame.size.height
        self.view.addKeyboardPanning { (keyboardFrameInView: CGRect, opening: Bool, closing: Bool) in
            var toolBarFrame:CGRect = self.inputbar.frame
            toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height
            print("toolBarFrame = \(toolBarFrame)")
            self.inputbar.frame = toolBarFrame
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        self.view.endEditing(true)
        self.view.removeKeyboardControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func submitMediaRequest(mediadata: NSData, mediatype:String, mediaExtension:String, callBack: @escaping ((_ isSubmit:Bool) -> Void)) {
        
        let dictP = NSMutableDictionary()
        dictP.setValue("file", forKey: "fileKey")
        dictP.setValue(mediadata, forKey: "fileData")
        dictP.setValue(mediaExtension, forKey: "fileType")

        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.ChatUploadMedia, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Data send successfully
                
                callBack(true)
                
                self.sendMessage(chat_event: self.sendmsg, reciver_id: String(self.arr_ReciverDetail[0].agentid!), sender_id: String(UserProfile.id!), message: (dictJson["image_name"] as? String)!, sender_name: UserProfile.name!, receiver_name: self.arr_ReciverDetail[0].name!, type:mediatype)
            }
        }
        
    }
    
    func sendMessage(chat_event:String, reciver_id:String, sender_id:String, message:String, sender_name:String, receiver_name:String, type:String) {
        
        let JsonSendToSocket: [String: String] = [
            "yname": sender_id,
            "msg": message,
            "from_name": sender_name,
            "to_name": receiver_name,
            "type": type,
            ]
        
        socket?.emit(chat_event, reciver_id, JsonSendToSocket)
    }
    
    private func addLocalMessageinDB(message:String, type:String, is_download:Int) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentdate = formatter.string(from: date)
        
        let JsonSendToSocket: [String: AnyObject] = [
            "from": UserProfile.id as AnyObject,
            "from_name": UserProfile.name as AnyObject,
            "msg": message as AnyObject,
            "msgtime": currentdate as AnyObject,
            "msgtype": type as AnyObject,
            "photo": "" as AnyObject
        ]

        let obRequest = ChatModel()
        obRequest.initWith(to_user_id: self.arr_ReciverDetail[0].agentid!, is_download: is_download, from_name: UserProfile.name!, dict: JsonSendToSocket as NSDictionary)
        
        let success = obSqlite.insertChatData(obchat: obRequest)
        
        if success == true {
            let incId_DB = obSqlite.getChatLastId()
            print(incId_DB)
            obRequest.incId = incId_DB
            self.Message_Array.append(obRequest)
        }
        self.Load_Table(loadtype: "")
    }
    
    private func updateLocalMessageinDB(from:Int, from_name:String, msg:String, msgtime:String, msgtype:Int, photo:String, is_download:Int, incId:Int, updateIndex:Int, to_user_id:Int) {
        
        let success = obSqlite.updateChatDownload(isDownload: is_download, msg: msg, incId: incId)
        
        if success == true {
            
            let JsonSendToSocket: [String: AnyObject] = [
                "from": from as AnyObject,
                "from_name": from_name as AnyObject,
                "msg": msg as AnyObject,
                "msgtime": msgtime as AnyObject,
                "msgtype": msgtype as AnyObject,
                "photo": "" as AnyObject
            ]
            
            let obRequest = ChatModel()
            obRequest.initWith(to_user_id: to_user_id, is_download: is_download, from_name: from_name, dict: JsonSendToSocket as NSDictionary)
            
            self.Message_Array.remove(at: updateIndex)
            self.Message_Array.insert(obRequest, at: updateIndex)
            
            let indexPath = IndexPath(item: updateIndex, section: 0)
            tableview.reloadRows(at: [indexPath], with: .fade)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ChatViewController: InputbarDelegate {
    
    func inputbarDidPressRightButton(_ inputbar: Inputbar!) {
        self.view.endEditing(true)
        let message = inputbar.text
        if !message()!.isEmpty {
            self.addLocalMessageinDB(message: message()!, type: ChatType.text, is_download: 1)
            self.sendMessage(chat_event: self.sendmsg, reciver_id: String(self.arr_ReciverDetail[0].agentid!), sender_id: String(UserProfile.id!), message: message()!, sender_name: UserProfile.name!, receiver_name: self.arr_ReciverDetail[0].name!, type:ChatType.text)
        }
    }
    
    func inputbarDidPressLeftButton(_ inputbar: Inputbar!) {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        
        MF.openActionSheetForChat(with: imagePicker, with: documentPicker, and: self)
    }
    
}

extension ChatViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Message_Array.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if UserProfile.id == Message_Array[indexPath.row].fromid {
                        
            if Message_Array[indexPath.row].msgtype == 1 {
                // -- Text section
                let cellright = tableview.dequeueReusableCell(withIdentifier: "RightChat_Cell", for: indexPath) as! chat_cell
                cellright.img_profilepic.image = sender_img
                cellright.setChatUserData(obChat: Message_Array[indexPath.row])
                return cellright
            }
            else if Message_Array[indexPath.row].msgtype == 2 {
                // -- Image section
                let cellright = tableview.dequeueReusableCell(withIdentifier: "image_rightcell", for: indexPath) as! chat_cell
                cellright.img_profilepic.image = sender_img
                cellright.index = indexPath.row
                cellright.downloadId = Message_Array[indexPath.row].incId!
                cellright.delegate = self
                cellright.setChatUserData(obChat: Message_Array[indexPath.row])
                return cellright
            }
            else if Message_Array[indexPath.row].msgtype == 3 {
                // -- Video section
                let cellright = tableview.dequeueReusableCell(withIdentifier: "video_rightcell", for: indexPath) as! chat_cell
                cellright.img_profilepic.image = sender_img
                cellright.index = indexPath.row
                cellright.downloadId = Message_Array[indexPath.row].incId!
                cellright.delegate = self
                cellright.setChatUserData(obChat: Message_Array[indexPath.row])
                return cellright
            }
            else {
                // -- Document section
                let cellright = tableview.dequeueReusableCell(withIdentifier: "file_rightcell", for: indexPath) as! chat_cell
                cellright.img_profilepic.image = sender_img
                cellright.index = indexPath.row
                cellright.downloadId = Message_Array[indexPath.row].incId!
                cellright.delegate = self
                cellright.setChatUserData(obChat: Message_Array[indexPath.row])
                return cellright
            }
        } else {
            
            if Message_Array[indexPath.row].msgtype == 1 {
                // -- Text section
                let cellleft = tableview.dequeueReusableCell(withIdentifier: "ChatLeft_Cell", for: indexPath) as! chat_cell
                cellleft.img_profilepic.image = reciver_img
                cellleft.setChatUserData(obChat: Message_Array[indexPath.row])
                return cellleft
            }
            else if Message_Array[indexPath.row].msgtype == 2 {
                // -- Image section
                let cellleft = tableview.dequeueReusableCell(withIdentifier: "image_Leftcell", for: indexPath) as! chat_cell
                cellleft.img_profilepic.image = reciver_img
                cellleft.index = indexPath.row
                cellleft.downloadId = Message_Array[indexPath.row].incId!
                cellleft.delegate = self
                cellleft.setChatUserData(obChat: Message_Array[indexPath.row])
                return cellleft
            }
            else if Message_Array[indexPath.row].msgtype == 3 {
                // -- Video section
                let cellleft = tableview.dequeueReusableCell(withIdentifier: "video_Leftcell", for: indexPath) as! chat_cell
                cellleft.img_profilepic.image = reciver_img
                cellleft.index = indexPath.row
                cellleft.downloadId = Message_Array[indexPath.row].incId!
                cellleft.delegate = self
                cellleft.setChatUserData(obChat: Message_Array[indexPath.row])
                return cellleft
            }
            else {
                // -- Document section
                let cellleft = tableview.dequeueReusableCell(withIdentifier: "file_Leftcell", for: indexPath) as! chat_cell
                cellleft.img_profilepic.image = reciver_img
                cellleft.index = indexPath.row
                cellleft.downloadId = Message_Array[indexPath.row].incId!
                cellleft.delegate = self
                cellleft.setChatUserData(obChat: Message_Array[indexPath.row])
                return cellleft
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if Message_Array[indexPath.row].msgtype == 3 {
            
            DispatchQueue.global(qos: .background).async {
                
                let obfile = FileDownloaderManager()
                
                let videoUrl = obfile.getMediaDirectoryIfNotExist().appendingPathComponent("\(self.Message_Array[indexPath.row].msg!)")
                
                let videoView = VideoView(videoUrl as URL)
                DispatchQueue.main.async {
                    self.present(videoView!, animated: true)
                }
            }
        }
        else if Message_Array[indexPath.row].msgtype == 4 {
            
            let obfile = FileDownloaderManager()
            let fileUrl = obfile.getMediaDirectoryIfNotExist().appendingPathComponent("\(self.Message_Array[indexPath.row].msg!)")
            let filestring = ("\(fileUrl.absoluteString)")
            print("filestring = \(filestring)")
            self.executeUIProcess {
                SVProgressHUD.show()
            }
            var docController: UIDocumentInteractionController!
            docController = UIDocumentInteractionController.init(url: NSURL.fileURL(withPath: filestring, isDirectory: true))
            docController.delegate = self
            docController.presentPreview(animated: true)
        }
    }
}

extension ChatViewController: ChatDownloadcellDelegate {
    
    func downloadction(index:Int, downloadId:Int) {
        
        SVProgressHUD.show()
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            let str_url = Server.ImagePath.TestUrl + self.Message_Array[index].msg! as String
            
            // if let theProfileImageUrl = str_url {
            do {
                let imageData = try NSData(contentsOf: URL(string: str_url)!)
                
                let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
                var newPath = path.appendingPathComponent(ChatFolder)
                
                var imagename = ""
                if self.Message_Array[index].msgtype == 2 {
                    imagename = ("image\(dc.getCurrentDateTime_YMD_HMS()).png")
                } else if self.Message_Array[index].msgtype == 3 {
                    imagename = ("video\(dc.getCurrentDateTime_YMD_HMS()).mp4")
                } else if self.Message_Array[index].msgtype == 4 {
                     imagename = ("File\(dc.getCurrentDateTime_YMD_HMS()).pdf")
                }
                
                newPath = newPath.appendingPathComponent(imagename)
                do {
                    try imageData?.write(to: newPath)
                    
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        
                        self.updateLocalMessageinDB(from: self.Message_Array[index].fromid!, from_name: self.Message_Array[index].from_name!, msg: imagename, msgtime: self.Message_Array[index].msgtime!, msgtype: self.Message_Array[index].msgtype!, photo: "", is_download: 1, incId: downloadId, updateIndex:index, to_user_id: self.Message_Array[index].to_user_id!)
                    }
                  
                } catch {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    print(error)
                }
                
            } catch {
                print("Unable to load data: \(error)")
            }
        }
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
                print("Image Selected")
                
                if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    
                    let imagedata = pickedImage.imageQuality(.medium)! as NSData
                    
                    let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
                    var newPath = path.appendingPathComponent(ChatFolder)
                    
                    let imagename = ("image\(dc.getCurrentDateTime_YMD_HMS()).png")
                    
                    newPath = newPath.appendingPathComponent(imagename)
                    do {
                        try imagedata.write(to: newPath)
                        
                        self.addLocalMessageinDB(message: imagename, type: ChatType.image, is_download: 1)
                        
                        submitMediaRequest(mediadata: imagedata, mediatype: ChatType.image, mediaExtension: "png") { (isSubmit) in
                            if isSubmit == true {
                                print("Submitted")
                            }
                        }
                        
                    } catch {
                        print(error)
                    }                   
                }
            }
            if mediaType == "public.movie" {
               
                // choose Video
              //  if mediaType.isEqualToString(mediaType as String) {
                let videoPath = info[UIImagePickerControllerMediaURL] as? NSURL
                // Check the file path in here
                print(videoPath!.relativePath ?? NSURL())
                
                var movieData: NSData?
                do {
                    movieData = try NSData(contentsOfFile: (videoPath?.relativePath)!, options: NSData.ReadingOptions.alwaysMapped)
                    
                    let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
                    var newPath = path.appendingPathComponent(ChatFolder)
                    
                    let videoname = ("video\(dc.getCurrentDateTime_YMD_HMS()).mp4")
                    
                    newPath = newPath.appendingPathComponent(videoname)
                    do {
                        try movieData?.write(to: newPath)
                        
                        self.addLocalMessageinDB(message: videoname, type: ChatType.video, is_download: 1)
                     
                        submitMediaRequest(mediadata: movieData!, mediatype: ChatType.video, mediaExtension: "mp4") { (isSubmit) in
                            if isSubmit == true {
                                print("Submitted")
                            }
                        }
                        
                    } catch {
                        print(error)
                    }
                } catch _ {
                    movieData = nil
                    return
                }
            }
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        print("import result : \(myURL)")
        
        print(myURL.lastPathComponent)
        print(myURL.pathExtension)
        
        var movieData: NSData?
        do {
            movieData = try NSData(contentsOfFile: (myURL.relativePath), options: NSData.ReadingOptions.alwaysMapped)
            
            let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
            var newPath = path.appendingPathComponent(ChatFolder)
            
            let filename = ("File\(dc.getCurrentDateTime_YMD_HMS()).\(myURL.pathExtension)")
            
            newPath = newPath.appendingPathComponent(filename)
            do {
                try movieData?.write(to: newPath)
                
                self.addLocalMessageinDB(message: filename, type: ChatType.document, is_download: 1)
                
                submitMediaRequest(mediadata: movieData!, mediatype: ChatType.document, mediaExtension: myURL.pathExtension) { (isSubmit) in
                    if isSubmit == true {
                        print("Submitted")
                    }
                }
                
            } catch {
                print(error)
            }
 
        } catch _ {
            movieData = nil
            return
        }
        
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
}


extension ChatViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        print("willBeginSendingToApplication")
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        print("didEndSendingToApplication")
    }
    
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        print("documentInteractionControllerDidDismissOpenInMenu")
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        executeUIProcess {
            SVProgressHUD.dismiss()
        }
        return self
    }
    
}
