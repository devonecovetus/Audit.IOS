//
//  AppDelegate.swift
//  Audit
//
//  Created by Mac on 10/9/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

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
    /*
     THis varaible check wether app is in background mode or in foreground mode, so that this flag will manage the dependency in app
     */
    var flagIsInBackground = false
    
    var flagIsOrderSubmit = false
    var intTotalLocationCount = Int()
    var intTotalFolderCount = Int()
    var strSubLocationName = String()
    var strPhoto = String()
    //THis variable is used to check the lock status in the location, if lock is 1 then no updation will be done
    var intLockStatus = Int()
    var strMainLocationName:String? = String()
    var currentViewController = UIViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let obSqlite1 = SqliteDB.sharedInstance()
        //obSqlite = SqliteDB.sharedInstance()
        obSqlite1.createDataBaseIfNotExist()
        //print("url = \(Server.BaseURL)")
        setDefaultLangaueSettings()
        IQKeyboardManager.sharedManager().enable = true
        window = UIWindow(frame: UIScreen.main.bounds)
        checkUserIsLoginOrNot(defaults: Preferences!)
        registerForPushNotifications(application)
        navigationController.isNavigationBarHidden = true
        
        window = UIWindow()
        window?.rootViewController = self.navigationController
        window?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width + 0.001, height: UIScreen.main.bounds.size.height + 0.001)
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        flagIsInBackground = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        flagIsInBackground = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
    }

    //MARK: Supporting Functions:
    
    func test() {
        var arrLocal = [1,2,3,4,5,6,7,8,9,10,11,12,13]
        //print("arrLocal = \(arrLocal)")
        arrLocal.removeSubrange(ClosedRange(uncheckedBounds: (lower: 3 , upper: arrLocal.count - 1)))
        //print("arrLocal after remove= \(arrLocal)")
    }
    
    func test2() {
        
        
        
    }
    func checkUserIsLoginOrNot(defaults: UserDefaults)  {
        /// This case is for default, and set to 0 means amount not verified
        autoreleasepool {
        /// This function help to check if user is login then navigation flow made after login screen else first login.
        if defaults.object(forKey: "isLogin") != nil {
            if defaults.bool(forKey: "isLogin") {
                let unarchiveUserData : NSMutableDictionary = NSKeyedUnarchiver.unarchiveObject(with: (defaults.object(forKey: "UserData") as! NSData) as Data) as! NSMutableDictionary
            //    //print("UserData = \(unarchiveUserData.mutableCopy() as! NSMutableDictionary)")
                UserProfile.initWith(dict: unarchiveUserData.mutableCopy() as! NSMutableDictionary)
               
                let vc1 = HomeStoryBoard.instantiateViewController(withIdentifier: "Home_VC") as! Home_VC
                let vc2 = HomeStoryBoard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
                let vc3 = HomeStoryBoard.instantiateViewController(withIdentifier: "DraftsViewController") as! DraftsViewController
                let vc4 = HomeStoryBoard.instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
                let vc5 = HomeStoryBoard.instantiateViewController(withIdentifier: "AuditViewController") as! AuditViewController
                let vc6 = HomeStoryBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                
                let vcTabBarViewController = HomeStoryBoard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController
 
                if kAppDelegate.intViewFlipStatus == 1 {
                    vcTabBarViewController?.viewControllers = [vc1, vc2, vc3, vc4, vc5, vc6]
                    vcTabBarViewController?.selectedIndex = 0
                } else {
                    vcTabBarViewController?.viewControllers = [vc6, vc5, vc4, vc3, vc2, vc1]
                    vcTabBarViewController?.selectedIndex = 5
                }
              //  MF.setTabBarIcons(tabBar: (vcTabBarViewController?.tabBar)!)
                navigationController.viewControllers = [vcTabBarViewController!]
                let obfile:FileDownloaderManager? = FileDownloaderManager()
                obfile?.getMediaDirectoryIfNotExist()
            } else {
                let vc = MainStoryBoard.instantiateViewController(withIdentifier: "Login_VC") as? Login_VC
                navigationController.viewControllers = [vc!]
            }
        } else {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "Login_VC") as? Login_VC
            navigationController.viewControllers = [vc!]
        }    
        }
    }
    
    func setDefaultLangaueSettings() {
        let locale = Locale.current
        //print(locale.regionCode as Any)
        //print(Locale.current as Any)
        autoreleasepool {
       if locale.languageCode == LanguageType.Arabic {
      // if "ar" == LanguageType.Arabic {
            kAppDelegate.strLanguageName = LanguageType.Arabic
        Preferences?.setValue(kAppDelegate.strLanguageName, forKey: SelectedLanguage)
            kAppDelegate.intViewFlipStatus = -1
            BundleLocalization.sharedInstance().language = LanguageType.Arabic
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        } else {
            kAppDelegate.strLanguageName = LanguageType.English
        Preferences?.setValue(kAppDelegate.strLanguageName, forKey: SelectedLanguage)
            kAppDelegate.intViewFlipStatus = 1
            BundleLocalization.sharedInstance().language = LanguageType.English
             //UIView.appearance().semanticContentAttribute = .forceRightToLeft
            }
        }
    }
    
    func getAndSetUserDetailsInBackground() {
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetUserDetail, methodType: 1, forContent: 1, OnView: (kAppDelegate.window?.rootViewController)!
        , withParameters: MF.initializeDictWithUserId(), IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                let archiveUserData = NSKeyedArchiver.archivedData(withRootObject: (dictJson["response"] as! NSDictionary).mutableCopy())
                Preferences?.set(archiveUserData , forKey: "UserData")
                let unarchiveUserData : NSMutableDictionary = NSKeyedUnarchiver.unarchiveObject(with: (Preferences?.object(forKey: "UserData") as! NSData) as Data) as! NSMutableDictionary
                 UserProfile.initWith(dict: unarchiveUserData.mutableCopy() as! NSMutableDictionary)
            }
        }
    }
}


