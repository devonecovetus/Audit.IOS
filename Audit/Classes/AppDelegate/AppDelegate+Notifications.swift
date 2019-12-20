//
//  AppDelegate+Notifications.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerForPushNotifications(_ application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert], completionHandler: {(granted, error) in
                //print("is granted = \(granted)")
                if (granted)  {
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                }
            })
        } else {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: Device Token Methods:
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        strDeviceToken=token
        //print("strDeviceToken = \(strDeviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //print("Device token for push notifications: FAIL -- ")
        //print(error.localizedDescription)
    }
    
    //MARK: Push Notifications methods:
    /// This method will work when the app is in background and receives push notification
    func application( _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        showNotificationMessage(dictND:  userInfo as NSDictionary)
        completionHandler(.newData)
    }
    
    @available(iOS 10.0, *)
    func application(_ application: UIApplication, didReceive notification: UNNotificationRequest) {    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //Handle the notification
        //print("userInfo = \(notification.request.content.userInfo)")
        //  if flagIsInBackground {
        if Version.iOS10 {
            completionHandler(UNNotificationPresentationOptions.alert)
        } else  {
            completionHandler([.sound, .alert])
        }
        
        // } else {
        //     showNotificationMessage(dictND: (notification.request.content.userInfo["aps"] as! NSDictionary)["alert"] as! NSDictionary)
        //  }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //Handle the notification
        //print("userInfo = \(response.notification.debugDescription)")
        /// SHow Alert here
        showNotificationMessage(dictND: (response.notification.request.content.userInfo["aps"] as! NSDictionary)["alert"] as! NSDictionary)
    }
    
    /// This is the common function to manage the notification alert view, where the notification methods invokes it calls from there.
    func showNotificationMessage(dictND: NSDictionary) {
        let type = dictND["type"] as! String
        
        if type == NotificationType.Audit {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "AuditOverViewController") as! AuditOverViewController
            if let str_id = dictND["notification_id"] as? String{
                vc.str_notify_id =  str_id
            } else if let id = dictND["notification_id"] as? Int{
                vc.str_notify_id =  String(id)
            }
            self.navigationController.pushViewController(vc, animated: true)
        } else if type == NotificationType.Chat {
            
            if (Preferences?.bool(forKey: "isLogin"))! {
                
                if (kAppDelegate.currentViewController is ChatListViewController) || (kAppDelegate.currentViewController is ChatViewController) { return } else {
                    let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
                    navigationController.viewControllers = [MF.setUpTabBarView(selectedIndex:1)]
                    MF.animateViewNavigation(navigationController: navigationController)
                    kAppDelegate.window?.rootViewController = navigationController
                }
            }
        } else if type == NotificationType.Report {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "ReportListViewController") as! ReportListViewController
                self.navigationController.pushViewController(vc, animated: true)
            }
        }
    }
}
