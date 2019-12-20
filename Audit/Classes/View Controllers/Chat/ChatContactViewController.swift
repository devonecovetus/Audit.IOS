//
//  ChatContactViewController.swift
//  Audit
//
//  Created by Mac on 11/29/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ChatContactViewController: UIViewController {
    //MARK: Variables & Outlets:
    var flagIsSearch = false
    var arrSections = [NSLocalizedString("A", comment: ""), NSLocalizedString("B", comment: "") ,NSLocalizedString("C", comment: ""), NSLocalizedString("D", comment: ""), NSLocalizedString("E", comment: ""), NSLocalizedString("F", comment: ""), NSLocalizedString("G", comment: ""), NSLocalizedString("H", comment: ""), NSLocalizedString("I", comment: "") ,NSLocalizedString("J", comment: ""), NSLocalizedString("K", comment: ""), NSLocalizedString("L", comment: ""), NSLocalizedString("M", comment: ""), NSLocalizedString("N", comment: ""), NSLocalizedString("O", comment: ""), NSLocalizedString("P", comment: "") ,NSLocalizedString("Q", comment: ""), NSLocalizedString("R", comment: ""), NSLocalizedString("S", comment: ""), NSLocalizedString("T", comment: ""), NSLocalizedString("U", comment: ""), NSLocalizedString("V", comment: ""), NSLocalizedString("W", comment: ""), NSLocalizedString("X", comment: ""),NSLocalizedString("Y", comment: ""), NSLocalizedString("Z", comment: "")]
    var arrSectionObejctList = [AgentListSectionModel]()
    var arrfilterdSectionObejctList = [AgentListSectionModel]()
    var arrSearchList = [AgentListModel]()
    
    @IBOutlet weak var tf_Search: DesignableUITextField!
    @IBOutlet weak var tbl_chat: UITableView!
    @IBOutlet weak var lbl_Title: UILabel!

    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Create a padding view for padding on left
        
        setUpLanguageSetting()
        tf_Search.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: tf_Search.frame.height))
        tf_Search.leftViewMode = .always
        getAgentAuditIdList()
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_Search.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_Search.textAlignment = NSTextAlignment.right
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Actions
    @IBAction func btn_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Supporting Functions:
    func getAgentAuditIdList() {
        /// API code here
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetAgentAuditId, methodType: 1, forContent: 1, OnView: self, withParameters: MF.initializeDictWithUserId()) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                let arrresponse = dictJson["response"] as! NSArray
                
                for i in 0..<self.arrSections.count {
                    autoreleasepool {
                        
                        let str_section = self.arrSections[i]
                        var arrAgentList = [AgentListModel]()
                        for item in arrresponse {
                            
                            autoreleasepool {
                                
                                let arr = item as! NSDictionary
                                var firstletter = arr["username"] as? String
                                firstletter = String((firstletter?.prefix(1))!).uppercased() // Hell)!
                                if str_section == firstletter {
                                    let obRequest = AgentListModel()
                                    obRequest.initWith(dict: (item as? NSDictionary)!)
                                    arrAgentList.append(obRequest)
                                }
                            }
                        }
                        
                        if arrAgentList.count != 0 {
                            let obRequest2 = AgentListSectionModel()
                            obRequest2.initWith(section: str_section, arrList: arrAgentList)
                            self.arrSectionObejctList.append(obRequest2)
                        }
                    }
                }
                self.tbl_chat.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
    }
}

extension ChatContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if flagIsSearch {
            return 1
        } else {
            return arrSectionObejctList.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        if flagIsSearch {
            label.text = NSLocalizedString("Searched users", comment: "")
        } else {
            label.text = arrSectionObejctList[section].section
        }
        
        label.textColor = UIColor.lightGray
        label.font = UIFont(name: CustomFont.themeFont , size: 30)
        headerView.addSubview(label)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            label.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
            label.textAlignment = NSTextAlignment.right
        }
        
        let labelline = UILabel()
        labelline.frame = CGRect.init(x: 25, y: label.frame.maxY - 8, width: headerView.frame.width-50, height: 1.5)
        labelline.backgroundColor = UIColor.lightGray
        headerView.addSubview(labelline)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flagIsSearch {
            return arrSearchList.count
        }
        return arrSectionObejctList[section].arrList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        cell.index = indexPath.row
        cell.indexpath = indexPath
        cell.delegate = self
        if flagIsSearch {
            cell.img_profilepic.sd_setImage(with: URL(string: arrSearchList[indexPath.row].profilePic!), placeholderImage: UIImage.init(named: "img_user"))
            cell.lbl_name.text = arrSearchList[indexPath.row].name
        } else {
            cell.img_profilepic.sd_setImage(with: URL(string: arrSectionObejctList[indexPath.section].arrList[indexPath.row].profilePic!), placeholderImage: UIImage.init(named: "img_user"))
            cell.lbl_name.text = arrSectionObejctList[indexPath.section].arrList[indexPath.row].name
        }
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
           cell.btn_msg.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceType.IS_PHONE ? 50 : 75
    }
}

extension ChatContactViewController : UITextFieldDelegate {
    
    // Chat list filter
    func textFieldDidBeginEditing(_ textField: UITextField) {  }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        if string == " " { } else if string == "" {
            getSearchArrayContains(txtAfterUpdate)
        } else {
            getSearchArrayContains(txtAfterUpdate)
        }
        return true
    }
    
    func getSearchArrayContains(_ text : String) {
        arrSearchList = [AgentListModel]()
        if text.count > 0 {
            flagIsSearch = true
        } else {
            flagIsSearch = false
        }
        
        for i in 0..<arrSectionObejctList.count {
            autoreleasepool {
                let obSO = arrSectionObejctList[i]
                for j in 0..<obSO.arrList.count {
                    
                    autoreleasepool {
                        let obUser = obSO.arrList[j]
                        
                        if obUser.name?.range(of: text, options: .caseInsensitive, range: (obUser.name?.startIndex)!..<(obUser.name?.endIndex)!, locale: nil) != nil {
                            self.arrSearchList.append(obUser)
                            //print("self.arrSearchList = \(self.arrSearchList.count)")
                            tbl_chat.reloadData()
                        }
                    }
                }
            }
        }
            tbl_chat.reloadData()
    }
}

extension ChatContactViewController: ChatcellDelegate {
    
    func msgAction(index: Int, indexPath: IndexPath) {
        //print("index = \(index), indexpath = \(indexPath.row)")
        tf_Search.resignFirstResponder()
        
        let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        if flagIsSearch {
            //print("arrSearchList = \(arrSearchList.count)")
            if arrSearchList[index].role == "Agent" {
                vc.sendmsg = ChatEvents.Agent_SendMsg
                vc.getmsg = ChatEvents.Agent_GetMsg
                vc.arr_ReciverDetail = [arrSearchList[indexPath.row]]
            } else {
                vc.sendmsg = ChatEvents.Admin_SendMsg
                vc.getmsg = ChatEvents.Admin_GetMsg
                vc.arr_ReciverDetail = [arrSearchList[indexPath.row]]
            }
        } else {
            if arrSectionObejctList[indexPath.section].arrList[index].role == "Agent" {
                vc.sendmsg = ChatEvents.Agent_SendMsg
                vc.getmsg = ChatEvents.Agent_GetMsg
                vc.arr_ReciverDetail = [arrSectionObejctList[indexPath.section].arrList[index]]
            } else {
                vc.sendmsg = ChatEvents.Admin_SendMsg
                vc.getmsg = ChatEvents.Admin_GetMsg
                vc.arr_ReciverDetail = [arrSectionObejctList[indexPath.section].arrList[index]]
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }    
}
