//
//  AppDelegate.swift
//  Audit
//
//  Created by Mac on 10/9/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var strDeviceToken: String = ""
    var window: UIWindow?
    var dictUserData = NSMutableDictionary()
    var navigationController : UINavigationController = UINavigationController()
    /**
     This variable holds the value according to our language, if we select any lanaguage like: en, hin, etc it will set 1, if we select arabic the status will be set = -1
     */
    var intViewFlipStatus:CGFloat = 1
    var strLanguageName: String = String()
    var flagIsInBackground = false
    
    var intTotalLocationCount = Int()
    var intTotalFolderCount = Int()
    //THis variable is used to check the lock status in the location, if lock is 1 then no updation will be done
    var intLockStatus = Int()
    
    var currentViewController = UIViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        obSqlite.createDataBaseIfNotExist()
       // obSqlite.createTableIfNotExist(DBTables.UserChating, andFieldNames: SQLQuery.CreateTable.UserChating)
 //      obSqlite.createTableIfNotExist(DBTables.LocationSubFolderList, andFieldNames: SQLQuery.CreateTable.LocationSubFolderList)
    
        setDefaultLangaueSettings()
        IQKeyboardManager.sharedManager().enable = true
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.checkUserIsLoginOrNot(defaults: Preferences)
        self.registerForPushNotifications(application)
        self.navigationController.isNavigationBarHidden = true
        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
    }

    //MARK: Supporting Functions:
    func checkUserIsLoginOrNot(defaults: UserDefaults)  {
        /// This case is for default, and set to 0 means amount not verified
        
        /// This function help to check if user is login then navigation flow made after login screen else first login.
        if defaults.object(forKey: "isLogin") != nil {
            if defaults.bool(forKey: "isLogin") {
                let unarchiveUserData : NSMutableDictionary = NSKeyedUnarchiver.unarchiveObject(with: (defaults.object(forKey: "UserData") as! NSData) as Data) as! NSMutableDictionary
            //    print("UserData = \(unarchiveUserData.mutableCopy() as! NSMutableDictionary)")
                UserProfile.initWith(dict: unarchiveUserData.mutableCopy() as! NSMutableDictionary)
               
                let vc1 = HomeStoryBoard.instantiateViewController(withIdentifier: "Home_VC") as! Home_VC
                let vc2 = HomeStoryBoard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
                let vc3 = HomeStoryBoard.instantiateViewController(withIdentifier: "DraftsViewController") as! DraftsViewController
                let vc4 = HomeStoryBoard.instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
                let vc5 = HomeStoryBoard.instantiateViewController(withIdentifier: "AuditViewController") as! AuditViewController
                let vc6 = HomeStoryBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                
                let vcTabBarViewController = HomeStoryBoard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController
               // vcTabBarViewController?.viewControllers = [vc1, vc2, vc3, vc4, vc5]
 
                if kAppDelegate.intViewFlipStatus == 1 {
                    vcTabBarViewController?.viewControllers = [vc1, vc2, vc3, vc4, vc5, vc6]
                    vcTabBarViewController?.selectedIndex = 0
                } else {
                    vcTabBarViewController?.viewControllers = [vc6, vc5, vc4, vc3, vc2, vc1]
                    vcTabBarViewController?.selectedIndex = 5
                }
                let vcTest = BuiltAuditStoryBoard.instantiateViewController(withIdentifier: "BuiltAuditViewController") as! BuiltAuditViewController
              //  self.navigationController.viewControllers = [vcTest]
                self.navigationController.viewControllers = [vcTabBarViewController!]
            } else {
                let vc = MainStoryBoard.instantiateViewController(withIdentifier: "Login_VC") as? Login_VC
                self.navigationController.viewControllers = [vc!]
            }
        } else {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "Login_VC") as? Login_VC
            self.navigationController.viewControllers = [vc!]
        }
    }
    
    func setDefaultLangaueSettings() {
        let locale = Locale.current
        print(locale.regionCode as Any)
        print(locale.languageCode as Any)
        
        if locale.languageCode == LanguageType.Arabic {
            kAppDelegate.strLanguageName = LanguageType.Arabic
            Preferences.setValue(kAppDelegate.strLanguageName, forKey: SelectedLanguage)
            kAppDelegate.intViewFlipStatus = -1
            BundleLocalization.sharedInstance().language = LanguageType.Arabic
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            
        } else {
            kAppDelegate.strLanguageName = LanguageType.English
            Preferences.setValue(kAppDelegate.strLanguageName, forKey: SelectedLanguage)
            kAppDelegate.intViewFlipStatus = 1
            BundleLocalization.sharedInstance().language = LanguageType.English
             //UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }
    }
    
    func getAndSetUserDetailsInBackground() {
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetUserDetail, methodType: 1, forContent: 1, OnView: (kAppDelegate.window?.rootViewController)!
        , withParameters: MF.initializeDictWithUserId(), IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                let archiveUserData = NSKeyedArchiver.archivedData(withRootObject: (dictJson["response"] as! NSDictionary).mutableCopy())
                Preferences.set(archiveUserData , forKey: "UserData")
                
            }
        }
        
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerForPushNotifications(_ application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert], completionHandler: {(granted, error) in
                print("is granted = \(granted)")
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
        print("strDeviceToken = \(strDeviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Device token for push notifications: FAIL -- ")
        print(error.localizedDescription)
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
        print("userInfo = \(notification.request.content.userInfo)")
     //   if flagIsInBackground {
            if Version.iOS10 {
                completionHandler(UNNotificationPresentationOptions.alert)
            } else if Version.iOS11 {
                completionHandler([.sound, .alert])
            }
      /*  } else {
            showNotificationMessage(dictND: (notification.request.content.userInfo["aps"] as! NSDictionary)["alert"] as! NSDictionary)
       } */
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //Handle the notification
        print("userInfo = \(response.notification.debugDescription)")
        /// SHow Alert here
        showNotificationMessage(dictND: (response.notification.request.content.userInfo["aps"] as! NSDictionary)["alert"] as! NSDictionary)
    }
    
    /// This is the common function to manage the notification alert view, where the notification methods invokes it calls from there.
    func showNotificationMessage(dictND: NSDictionary) {
        
  //      let strTitle = dictND["title"] as! String
   //     let strMsg = dictND["body"] as! String
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
            
            if Preferences.bool(forKey: "isLogin") {
                
                if (kAppDelegate.currentViewController is ChatListViewController) || (kAppDelegate.currentViewController is ChatViewController){ return } else {
                    let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
                    navigationController.viewControllers = [MF.setUpTabBarView(selectedIndex:1)]
                    MF.animateViewNavigation(navigationController: navigationController)
                    kAppDelegate.window?.rootViewController = navigationController
                }
            }
            
        } else {}
    }
    
}
