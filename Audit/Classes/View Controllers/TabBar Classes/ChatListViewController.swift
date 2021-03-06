//
//  ChatListViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 24/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController {
    
    @IBOutlet weak var tf_Search: DesignableUITextField!
    @IBOutlet weak var tbl_chat: UITableView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_add: UIButton!

    var arrchatlist = [ChatListModel]()
    var arrChatfilterList = [ChatListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        
        // Create a padding view for padding on left
        tf_Search.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: tf_Search.frame.height))
        tf_Search.leftViewMode = .always
        arrchatlist = [ChatListModel]()
        arrChatfilterList = [ChatListModel]()
        arrchatlist = obSqlite.getChatList()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(false)
        tf_Search.delegate = self
        tbl_chat.delegate = self
        tbl_chat.dataSource = self
        arrchatlist = [ChatListModel]()
        kAppDelegate.currentViewController = self
        getChatUserList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeUnUsedMemory()
    }
    
    deinit {
        
    }
    
    func setUpLanguageSetting() {
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_Search.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_add.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_Search.textAlignment = NSTextAlignment.right
        }
    }
    
    func getChatUserList() {
      //  arrchatlist = [ChatListModel]()
        /// API code here
        let dictP = NSMutableDictionary()
        dictP.setValue(UserProfile.id, forKey: "id")
        dictP.setValue(UserProfile.authToken, forKey: "auth_token")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetChatUsersList, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                let arrresponse = dictJson["response"] as! NSArray
                
                for item in arrresponse {
                    autoreleasepool {
                    let obRequest = ChatListModel()
                    obRequest.initWith(dict: (item as? NSDictionary)!)
                    let Items = self.arrchatlist.filter { $0.user_id == obRequest.user_id }
                    if Items.count == 0 {
                    }
                    
                     self.arrchatlist.append(obRequest)
                    }
                }
                self.executeUIProcess({
                    self.tbl_chat.reloadData()
                })
                
            }
        }
    }
    
    @IBAction func btn_agentlist(_ sender: Any) {
        let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "ChatContactViewController") as! ChatContactViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeUnUsedMemory() {
        tf_Search.delegate = nil
        tbl_chat.delegate = nil
        tbl_chat.dataSource = nil
        arrchatlist.removeAll()
        arrchatlist = [ChatListModel]()
        arrChatfilterList = [ChatListModel]()
    }
  
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrChatfilterList.count != 0 {
            return arrChatfilterList.count
        }
        return arrchatlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        
        if arrChatfilterList.count != 0 {
            cell.img_profilepic.sd_setImage(with: URL(string: arrChatfilterList[indexPath.row].profilePic!), placeholderImage: UIImage.init(named: "img_user"))
            cell.lbl_name.text = arrChatfilterList[indexPath.row].name
            cell.lbl_msg.text = arrChatfilterList[indexPath.row].msg
            
            var str_date = arrChatfilterList[indexPath.row].time
            str_date = dc.change(date: str_date!, format: DateFormat_YMD_HMS2, to: DateFormat_DMY)
            cell.lbl_date.text = str_date
        } else {
            cell.img_profilepic.sd_setImage(with: URL(string: arrchatlist[indexPath.row].profilePic!), placeholderImage: UIImage.init(named: "img_user"))
            cell.lbl_name.text = arrchatlist[indexPath.row].name
            cell.lbl_msg.text = arrchatlist[indexPath.row].msg
            var str_date = arrchatlist[indexPath.row].time
            str_date = dc.change(date: str_date!, format: DateFormat_YMD_HMS2, to: DateFormat_DMY)
            cell.lbl_date.text = str_date
        }
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            cell.lbl_msg.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
            cell.lbl_date.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
            cell.lbl_msg.textAlignment = NSTextAlignment.right
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceType.IS_PHONE ? 75 : 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tf_Search.text = ""
        tf_Search.resignFirstResponder()
        let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        if arrChatfilterList.count != 0 {
            
            var arragent = [AgentListModel]()
            let dictP = NSMutableDictionary()
            dictP.setValue(arrChatfilterList[indexPath.row].profilePic, forKey: "photo")
            dictP.setValue(arrChatfilterList[indexPath.row].name, forKey: "username")
            dictP.setValue(arrChatfilterList[indexPath.row].role, forKey: "role")
            dictP.setValue(arrChatfilterList[indexPath.row].user_id, forKey: "user_id")
            dictP.setValue(arrChatfilterList[indexPath.row].email, forKey: "email")
            let obRequest = AgentListModel()
            obRequest.initWith(dict: dictP)
            arragent.append(obRequest)

            if arrChatfilterList[indexPath.row].role == "Agent" {
                vc.sendmsg = ChatEvents.Agent_SendMsg
                vc.getmsg = ChatEvents.Agent_GetMsg
                vc.arr_ReciverDetail = arragent
            } else {
                vc.sendmsg = ChatEvents.Admin_SendMsg
                vc.getmsg = ChatEvents.Admin_GetMsg
                vc.arr_ReciverDetail = arragent
            }
        } else {
            
            var arragent = [AgentListModel]()
            let dictP = NSMutableDictionary()
            dictP.setValue(arrchatlist[indexPath.row].profilePic, forKey: "photo")
            dictP.setValue(arrchatlist[indexPath.row].name, forKey: "username")
            dictP.setValue(arrchatlist[indexPath.row].role, forKey: "role")
            dictP.setValue(arrchatlist[indexPath.row].user_id, forKey: "user_id")
            dictP.setValue(arrchatlist[indexPath.row].email, forKey: "email")
            let obRequest = AgentListModel()
            obRequest.initWith(dict: dictP)
            arragent.append(obRequest)

            if arrchatlist[indexPath.row].role == "Agent" {
                vc.sendmsg = ChatEvents.Agent_SendMsg
                vc.getmsg = ChatEvents.Agent_GetMsg
                vc.arr_ReciverDetail = arragent
            } else {
                vc.sendmsg = ChatEvents.Admin_SendMsg
                vc.getmsg = ChatEvents.Admin_GetMsg
                vc.arr_ReciverDetail = arragent
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChatListViewController : UITextFieldDelegate {
    
    // Chat list filter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        //print(txtAfterUpdate)
        
        if string == " " {
        } else if string == "" {
            getSearchArrayContains(txtAfterUpdate)
        } else {
            getSearchArrayContains(txtAfterUpdate)
        }
        return true
    }
    
    func getSearchArrayContains(_ text : String) {
        if arrchatlist.count == 0 {  } else {
            arrChatfilterList = arrchatlist.filter {
                return $0.name?.range(of: text, options: .caseInsensitive) != nil
            }
            tbl_chat.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            tbl_chat.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}
