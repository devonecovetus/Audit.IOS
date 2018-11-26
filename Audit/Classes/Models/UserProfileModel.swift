//
//  UserProfileModel.swift
//  Audit
//
//  Created by Rupesh Chhabra on 24/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class UserProfileModel: NSObject {
    
    var language: String? = String()
    var address: String? = String()
    var address_ar: String? = String()
    var deviceId: String? = String()
    var deviceToken: String? = String()
    var email: String? = String()
    var firstName: String? = String()
    var lastName: String? = String()
   // var id: String? = String()
    var id: Int? = Int()
    var name: String? = String()
    var phone: String? = String()
    var photo: String? = String()
    var userRole: String? = String()
    var authToken:String? = String()
    
    override init() {}
    
    func initWith(dict: NSDictionary) {
        self.address = dict["address"] as? String
        self.address_ar = dict["address_ar"] as? String
        self.deviceId = dict["deviceid"] as? String
        if let dToken = dict["devicetoken"] as? String {
            self.deviceToken = dToken
        } else {
            self.deviceToken = "786re8768er678er87e6r868e6r868e6r868e"
        }
        
        self.email = dict["email"] as? String
        self.firstName = (dict["firstname"] as? String)?.capitalized
        //self.id = dict["id"] as? String
        if let userID = dict["id"] as? Int {
            self.id = userID
        } else if let strUserId = dict["id"] as? String {
            self.id = Int(strUserId)
        }
        
        self.lastName = (dict["lastname"] as? String)?.capitalized
        self.name = (dict["name"] as? String)?.capitalized  
        self.phone = dict["phone"] as? String
        if let imgUrl1 = dict["photo"] as? String {
            let imgUrl = String(format: "%@%@", Server.imgBaseUrl, imgUrl1)
            print("imgUrl = \(imgUrl)")
            self.photo = imgUrl
        } else {
            self.photo = ""
        }
        
        if let role = dict["role"] as? String {
            self.userRole = role
        } else {
            self.userRole = ""
        }
        
        self.authToken = dict["auth_token"] as? String
        self.language = dict["lang"] as? String
    }
    
    private static var userProfile: UserProfileModel?
    
    class func sharedInstance() -> UserProfileModel {
        if self.userProfile == nil {
            print("user object nil and initiates")
            self.userProfile = UserProfileModel()
            // Here user profile data will be inserted.

        } else {
            print("user object not nil")
        }
        return self.userProfile!
    }
    
}
