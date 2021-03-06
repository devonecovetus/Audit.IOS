//
//  ConstantsClass.swift
//  Tyvo
//
//  Created by Gourav Joshi on 04/02/17.
//  Copyright © 2017 Gourav Joshi. All rights reserved.
//
import UIKit
import Foundation
import CoreLocation

// MARK: Basic Constants Details:


let DEVICEID = UIDevice.current.identifierForVendor
let MainStoryBoard = UIStoryboard(name: DeviceType.IS_PHONE ? "Main_iPhone": "Main" , bundle: nil)
let UIStoryBoard = UIStoryboard(name: DeviceType.IS_PHONE ? "UI_iPhone": "UI", bundle: nil)
let HomeStoryBoard = UIStoryboard(name: DeviceType.IS_PHONE ? "Home_iPhone": "Home", bundle: nil)
let BuiltAuditStoryBoard = UIStoryboard(name:DeviceType.IS_PHONE ? "BuiltAudit_iPhone": "BuiltAudit", bundle: nil)
let CustomPopUpStoryBoard = UIStoryboard(name: DeviceType.IS_PHONE ? "CustomPopUp_iPhone" : "CustomPopUp", bundle: nil)
let MediaGalleryStoryBoard = UIStoryboard(name: DeviceType.IS_PHONE ?  "MediaGallery_iPhone" : "MediaGallery", bundle: nil)
let VideoStoryBoard = UIStoryboard(name: DeviceType.IS_PHONE ? "CustomVideo_iPhone": "CustomVideo", bundle: nil)

let OB_WEBSERVICE = WebServiceClass()

let SHOWALERT = ShowAlert()
let MF = SupportingFunctions()
let dc = DateClassFunctions()
var UserProfile = UserProfileModel.sharedInstance()
var obSqlite = SqliteDB.sharedInstance()

let dateFormatCustom = DateFormatter()
let DateFormat_DMMY = "dd MMMM YYYY"
let DateFormat_YMD = "YYYY-MM-dd"
let DateFormat_YMD_HM = "YYYY-MM-dd hh:mm a"
let DateFormat_YMD_HMS = "YYYY-MM-dd hh:mm:ss"
let DateFormat_DMYE = "dd MMM YYYY, EEEE"
let DateFormat_YMD_HMS1 = "YYYYMMddhhmmss"
let DateFormat_MD = "MM-dd"
let DateFormat_12HM = "hh:mm a"
let DateFormat_24HM = "HH:mm"
let DateFormat_DMY = "dd, MMM YYYY"
let DateFormat_YMD_HMS2 = "YYYY-MM-dd HH:mm:ss"

let AnswerSeperator = "|*|"
   
   /// Its a singleton of session that creates a default session
 

let SelectedLanguage = "SelectedLanguage"
   let kAppDelegate = UIApplication.shared.delegate as! AppDelegate
   let ApplicationVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let AppVersion = Double(ApplicationVersion)

   let PageLimit = 20
   let fSize = CGFloat(13.0)

   let dullWhite = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
let Preferences:UserDefaults? = UserDefaults.standard

let UAETimeInterval1 = TimeInterval((3600 * 4))
let DailyTimeInterval = TimeInterval(((3600 * 24) * 1))
let WeeklyTimeInterval = TimeInterval(((3600 * 24) * 7))
let MonthlyTimeInterval = TimeInterval(((3600 * 24) * 30))
let ThreeMonthlyTimeInterval = TimeInterval(((3600 * 24) * 90))
let OneYearTimeInterval = TimeInterval(((3600 * 24) * 365))

 let PageCounter = PageLimit
 let kAutoScrollDuration: CGFloat = 6.0 /// This will scroll the images automatically
 let blockSize = 100

// MARK: - Section Data Structure
struct Section {
    var name: String!
    var items =  NSMutableArray()
    var isCollapse: Bool!
  //  var imageName: String!
    init(name: String, items: NSMutableArray = NSMutableArray(), collapsed: Bool = true) { //, imgName: String) {
        self.name = name
        self.items = items
        self.isCollapse = collapsed
     //   self.imageName = imgName
    }
}

struct TextObjects {
    static let textColor = UIColor.white
    static let placeHolderColor = UIColor.white
    static let selectedColor = UIColor.orange
    static let borderWidth = CGFloat(1.0)
    static let cornerRadius = CGFloat(8.0)
    static let paddingPoints = CGFloat(10.0)
    static let themeColorGreen = UIColor(red: 41/255, green: 175/255, blue: 25/255, alpha: 1)
    static let themeColorGray = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1)
}

struct CustomColors {
    static let Red = UIColor.red
    static let Green = UIColor(red: 41/255, green: 175/255, blue: 25/255, alpha: 1)
    static let Blue = UIColor(red: 21/255, green: 146/255, blue: 211/255, alpha: 1)
    static let Indigo = UIColor(red: 75/255, green: 0/255, blue: 130/255, alpha: 1)
    static let Magenta = UIColor.magenta
    static let Orange = UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1)
    static let Brown = UIColor(red: 139/255, green: 69/255, blue: 19/255, alpha: 1)
    static let Voilet = UIColor(red: 138/255, green: 43/255, blue: 226/255, alpha: 1)
    static let themeColorGray = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1)
    static let themeColorGreen = UIColor(red: 44/255, green: 189/255, blue: 165/255, alpha: 1)
    static let themeColorVoilet = UIColor.init(hexString: "#D8B5FF")
    static let themeColorYellow = UIColor.init(hexString: "#E8D746")
}

struct ValidationConstants {
   static let MobileNumberLength = 9
   static let MaxMobileNumberLength = 10
   static let MaxOTPLength = 6
   static let PasswordLength = 6
   static let MaxPasswordLength = 12
   static let DeviceType = "ios"
    static let MaxDescriptionLimit = 300
}

struct AppLinks {
    static let GoogleAppStoreLink = "https://play.google.com/store/apps/details?id=app.bundle.id"
    static let AppleAppStoreLink = "https://itunes.apple.com/us/app/your-app-name/idapp_id?ls=1&mt=8"
}

struct PreferencesKeys {
    static let savedItems = "savedItems"
    static let questionScreen = "questionScreen"
}

enum UserRoles {
    static let Auditor = "Auditor"
    static let Inspector = "Inspector"
}

struct LanguageType {
    static let English = "en"
    static let Arabic = "ar"
}

struct WebContentName {
    static let TermsAndConditions = NSLocalizedString("TermsConditions", comment: "")
    static let PrivacyPolicy = "Privacy Policy"
    static let AboutUs =   NSLocalizedString("AboutUs", comment: "")
    static let ContactUs =   NSLocalizedString("ContactUs", comment: "")
    static let Standards =   NSLocalizedString("StandardPractice", comment: "")
    static let News = NSLocalizedString("News", comment: "")
    static let Help = NSLocalizedString("Help2", comment: "")
}

struct WebContentData {
    static let AboutUs =  Server.BaseURL + WebServiceName.AboutUs
    static let TermsAndConditions = Server.BaseURL + WebServiceName.TermsConditions
    static let StandardsAndPractices = Server.BaseURL + WebServiceName.StandardAndPractices
    static let News = Server.BaseURL + WebServiceName.News
    static let Help = Server.BaseURL + WebServiceName.Help
}

struct ScreenSize {
    static let SCREEN_WIDTH         =   UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        =   UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    
    static let IS_PHONE = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO    = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

struct Version {
    static let SYS_VERSION = (UIDevice.current.systemVersion as NSString).floatValue
    static let iOS7 = (Version.SYS_VERSION < 8.0 && Version.SYS_VERSION >= 7.0)
    static let iOS8 = (Version.SYS_VERSION >= 8.0 && Version.SYS_VERSION < 9.0)
    static let iOS9 = (Version.SYS_VERSION >= 9.0 && Version.SYS_VERSION < 10.0)
    static let iOS10 = (Version.SYS_VERSION >= 10.0 && Version.SYS_VERSION < 11.0)
    static let iOS11 = (Version.SYS_VERSION >= 11.0 && Version.SYS_VERSION < 12.0)
    static let iOS12 = (Version.SYS_VERSION >= 12.0 && Version.SYS_VERSION < 13.0)
    static let iOS13 = (Version.SYS_VERSION >= 13.0 && Version.SYS_VERSION < 14.0)
}

struct MessageType {
    static let Text = 1
    static let Image = 2
    static let Video = 3
    static let Document = 4
}

struct NotificationType {
   static let Audit = "Audit"
   static let Chat = "Chat"
   static let Report = "Report"
}

enum CustomFont {
    static let themeFont = "Montserrat-Regular"
}

/*
 to check and manage question type
 */
enum QuestionType {
    static let Text = 1
    static let Radio = 2
    static let CheckBox = 3
    static let DropDown = 4
    static let PopUp = 5
    static let TrueFalse = 6
}

/*
 Help to manage question priority
 */
enum QuestionPriority {
    static let Low = 1
    static let Medium = 2
    static let High = 3
    static let PPP = 4
}

enum PriorityColor {
    static let Low = CustomColors.themeColorGreen//UIColor(red: 255/255.0, green: 186/255.0, blue: 91/255.0, alpha: 1.0)
    static let Medium = UIColor(red: 232/255.0, green: 215/255.0, blue: 70/255.0, alpha: 0.75)
    static let High = UIColor(red: 249/255.0, green: 95/255.0, blue: 98/255.0, alpha: 1.0)
    static let PPP = UIColor(red: 47/255.0, green: 54/255.0, blue: 113/255.0, alpha: 1.0)
}

enum QuestionPriorityName {
    static let Low = NSLocalizedString("Low", comment: "")
    static let Medium = NSLocalizedString("Medium", comment: "")
    static let High = NSLocalizedString("High", comment: "")
    static let PPP = NSLocalizedString("PPP", comment: "")
}

enum QuestionCategory {
    static let Normal = 1
    static let Measurement = 2
}

enum PopUpType {
    static let Simple = 1
    static let Action = 2
    static let Check = 3
    static let Toast = 4
    static let SimpleAction = 5
}

enum MethodType {
    static let Get =    "GET"
    static let Post =   "POST"
    static let Put =     "PUT"
    static let Patch = "PATCH"
}

enum AuditType {
    static let Auditor = 1
    static let Inspector = 2
    static let SuperAudit = 3
}

struct SettingContent {
    enum Sections {
        static let PushNotification = NSLocalizedString("PushNotification1", comment: "")
        static let Pages = NSLocalizedString("Pages", comment: "")
        static let ContactUs = NSLocalizedString("ContactUs1", comment: "")
    }
    
    static let AssignAudit  = NSLocalizedString("AssignAudit", comment: "")
    static let NewAudit  = NSLocalizedString("NewAudit", comment: "")
    static let SyncAudit  = NSLocalizedString("SyncAudit", comment: "")
    static let Notification  = NSLocalizedString("PushNotification1", comment: "")
    static let ContactUs = NSLocalizedString("ContactUs1", comment: "")
    static let ChangePassword = NSLocalizedString("ChangePassword1", comment: "")
    static let AboutUs = NSLocalizedString("AboutUs1", comment: "")
    static let News = NSLocalizedString("News1", comment: "")
    static let Standars = NSLocalizedString("StandardPractice1", comment: "")
    static let TermsConditions = NSLocalizedString("TermsConditions1", comment: "")
    static let Help = NSLocalizedString("Help", comment: "")
    static let Logout = NSLocalizedString("Logout", comment: "")
}

enum ProfileContent {
    static let UpdateDetail = NSLocalizedString("UpdateDetails", comment: "")
    static let ChatAdmin = NSLocalizedString("ChatAdmin", comment: "")
    static let ShareApp = NSLocalizedString("ShareApp", comment: "")
    static let HowUse = NSLocalizedString("HowUse", comment: "")
}

enum MenuContent {
    static let Account = NSLocalizedString("MenuAccount", comment: "")
    static let History = NSLocalizedString("MenuHistory", comment: "")
    static let Report = NSLocalizedString("MenuReports", comment: "")
    static let Setting = NSLocalizedString("MenuSetting", comment: "")
    static let Help = NSLocalizedString("MenuHelp", comment: "")
    static let Logout = NSLocalizedString("MenuLogout", comment: "")
}

enum MediaFilesMetaDataConstants {
    static let FileData = "file_data"
    static let FileName = "file_name"
    static let FileUrl = "file_url"
    static let FileType = "file_type"
    static let Thumbnail = "thumbnail"
    static let TagId = "tag_id"
    static let FileType_URL = "1"
    static let FileType_Image = "0"
}

enum AuditStatus {
    static let InComplete = 0
    static let Pending = 1
    static let Completed = 2
}

enum ProgressColor {
    static let InCompleted = UIColor(red: 249/255.0, green: 95/255.0, blue: 98/255.0, alpha: 1.0)
    static let InProgress = UIColor(red: 255/255.0, green: 186/255.0, blue: 91/255.0, alpha: 1.0)
    static let Completed = CustomColors.themeColorGreen
}

enum ProgressText {
    static let InCompleted = NSLocalizedString("InComplete", comment: "")
    static let InProgress = NSLocalizedString("InProgress", comment: "")
    static let Completed = NSLocalizedString("Completed", comment: "")
}
