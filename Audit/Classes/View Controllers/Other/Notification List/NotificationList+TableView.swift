//
//  NotificationList+TableView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 22/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension NotificationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceType.IS_PHONE ? 100.0 : 155.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (notificationList?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        if (notificationList?.count)! > 0 {
            cell.setNotificationData(obNot: (notificationList?[indexPath.row])!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if notificationList?[indexPath.row].type == NotificationType.Audit {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "AuditOverViewController") as! AuditOverViewController
            vc.str_notify_id = (notificationList?[indexPath.row].notify_id!)!
            navigationController?.pushViewController(vc, animated: true)
        } else if notificationList?[indexPath.row].type == NotificationType.Chat {
            delegate?.NotificationSeen(notifyid: Int((notificationList?[indexPath.row].notify_id!)!)!)
           redirectToChatScreen(indexPath: indexPath)
        } else if notificationList?[indexPath.row].type == NotificationType.Report {
            delegate?.NotificationSeen(notifyid: Int((notificationList?[indexPath.row].notify_id!)!)!)
            redirectToReportScreen()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let height:Int = Int((tblView?.contentOffset.y)! + (tblView?.frame.size.height)!)
        let TableHeight:Int =  Int((tblView?.contentSize.height)!)
        if (height >= TableHeight) {
            if lodingApi == true {
                lodingApi = false
                self.pageno = self.pageno + 1
                delegate?.getNotificationList()
            }
        } else {
            return;
        }
    }
    
    private func redirectToReportScreen() {
        
        let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "ReportListViewController") as! ReportListViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func redirectToChatScreen(indexPath: IndexPath) {
        let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        var arragent = [AgentListModel]()
        
        let dictP = NSMutableDictionary()
        dictP.setValue(notificationList?[indexPath.row].photo, forKey: "photo")
        dictP.setValue(notificationList?[indexPath.row].user_name, forKey: "username")
        dictP.setValue(notificationList?[indexPath.row].role, forKey: "role")
        dictP.setValue(notificationList?[indexPath.row].user_id, forKey: "user_id")
        
        let obRequest:AgentListModel? = AgentListModel()
        obRequest?.initWith(dict: dictP)
        arragent.append(obRequest!)
        
        if notificationList?[indexPath.row].role == "Agent" {
            vc.sendmsg = ChatEvents.Agent_SendMsg
            vc.getmsg = ChatEvents.Agent_GetMsg
            vc.arr_ReciverDetail = arragent
        } else {
            vc.sendmsg = ChatEvents.Admin_SendMsg
            vc.getmsg = ChatEvents.Admin_GetMsg
            vc.arr_ReciverDetail = arragent
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
