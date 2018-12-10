//
//  SqliteDB.swift
//  Sqlite DB Demo
//
//  Created by Rupesh Chhabra on 23/10/18.
//  Copyright © 2018 Gourav Joshi. All rights reserved.
//

import UIKit
import Foundation
import SQLite3

let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

let DatabaseName = "AuditAppDB"
let FolderName = "DataBaseFolder"
let extName = "db"
let strDBName = String(format: "%@.%@", DatabaseName, extName)
var dbData: Data?

enum DBTables {
    static let UserProfile = "UserProfile"
    static let MyAuditList = "My_Audit_List"
    static let BuiltAuditLocation = "BuiltAuditLocation"
    static let BuiltAuditSubLocation = "BuiltAuditSubLocation"
    static let SubLocation = "SubLocation"
    static let LocationFolder = "LocationFolder"
    static let LocationSubFolderList = "LocationSubFolderList"
    static let AuditQuestions = "AuditQuestions"
    static let AuditAnswers = "AuditAnswers"
    static let AuditSubQuestions = "AuditSubQuestions"
    static let AuditSubAnswers = "AuditSubAnswers"
    static let ChatUserList = "ChatUserList"
    static let UserChat = "UserChat"
    static let UserChating = "UserChating"

}

enum SQLQuery {
    enum CreateTable {
        static let SubLocation = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id    INTEGER NOT NULL, audit_id  INTEGER NOT NULL, location_id   INTEGER NOT NULL, sublocation_id  INTEGER NOT NULL, sublocation_count    INTEGER NOT NULL, sublocation_name   TEXT NOT NULL,sublocation_description  TEXT NOT NULL, modified    INTEGER NOT NULL, app_version NUMERIC NOT NULL)"
        
        static let LocationFolder = " ( id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, folder_name TEXT NOT NULL, folder_count  INTEGER NOT NULL , app_version NUMERIC NOT NULL)"
        
        static let BuiltAuditLocation = "(  id   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL,   audit_id   INTEGER NOT NULL,   location_id   INTEGER NOT NULL,   location_count   INTEGER NOT NULL,   location_name   TEXT NOT NULL,   location_description   TEXT NOT NULL,   modified   INTEGER NOT NULL,   app_version   NUMERIC NOT NULL )"
        
        static let MyAuditList = "( id   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,   user_id   INTEGER NOT NULL,   audit_id   INTEGER NOT NULL,   audit_title   TEXT NOT NULL,   audit_status   INTEGER NOT NULL,   assign_by   TEXT NOT NULL,   target_date   TEXT NOT NULL,   app_version   NUMERIC NOT NULL )"
        
         static let LocationSubFolderList =  "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, folder_id INTEGER NOT NULL, is_archive INTEGER NOT NULL, sub_folder_name TEXT NOT NULL, sub_folder_description TEXT NOT NULL )"
     
        static let AuditQuestions = "(id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id  INTEGER NOT NULL, audit_id  INTEGER NOT NULL, location_id INTEGER NOT NULL, question_id  INTEGER NOT NULL, question_type  INTEGER NOT NULL, category_type  INTEGER NOT NULL, priority INTEGER NOT NULL, question  TEXT NOT NULL, answers TEXT NOT NULL, answers_id  TEXT NOT NULL)"
        
        static let AuditSubQuestions = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id  INTEGER NOT NULL, audit_id  INTEGER NOT NULL, location_id   INTEGER NOT NULL, sub_location_id  INTEGER NOT NULL, question_id  INTEGER NOT NULL, sub_question_id  INTEGER NOT NULL, answer_id  INTEGER NOT NULL, sub_question_type  INTEGER NOT NULL, sub_question   TEXT NOT NULL, answer  TEXT NOT NULL)"
        
        static let AuditAnswers = "(id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,  user_id  INTEGER NOT NULL, audit_id    INTEGER NOT NULL, location_id INTEGER NOT NULL, sub_location_id  INTEGER NOT NULL, folder_id INTEGER NOT NULL, question_id  INTEGER NOT NULL, answer_id  INTEGER NOT NULL, question_type  INTEGER NOT NULL, category_type    INTEGER NOT NULL, priority  INTEGER NOT NULL, is_update  INTEGER NOT NULL, question  TEXT NOT NULL, answer TEXT NOT NULL, description  TEXT, img_data  BLOB)"
        
        static let AuditSubAnswers = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id    INTEGER NOT NULL, location_id  INTEGER NOT NULL, sub_location_id  INTEGER NOT NULL, folder_id  INTEGER NOT NULL, question_id  INTEGER NOT NULL, sub_question_id  INTEGER NOT NULL, answer_id  INTEGER NOT NULL, sub_answer_id INTEGER NOT NULL, question_type INTEGER NOT NULL, category_type  INTEGER NOT NULL, priority    INTEGER NOT NULL, is_update  INTEGER NOT NULL, sub_question TEXT NOT NULL, sub_answer TEXT NOT NULL, description TEXT, img_data  TEXT )"
        
        static let ChatUserList = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, to_user_id INTEGER NOT NULL, name TEXT NOT NULL, time TEXT NOT NULL, role TEXT NOT NULL, photo TEXT NOT NULL, phone TEXT NOT NULL, email TEXT NOT NULL, last_msg TEXT NOT NULL, msg_type TEXT NOT NULL )"
        
         static let UserChat = "( inc_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, to_user_id INTEGER NOT NULL, message_type INTEGER NOT NULL, media_type INTEGER NOT NULL, delivery_type INTEGER NOT NULL, app_version NUMERIC NOT NULL, unread_status INTEGER NOT NULL, message_time TEXT NOT NULL, from_name TEXT NOT NULL, message TEXT NOT NULL )"
        
        static let UserChating = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, to_user_id INTEGER NOT NULL, from_id INTEGER NOT NULL, from_name TEXT NOT NULL, msg TEXT NOT NULL, msg_time TEXT NOT NULL, msgtype INTEGER NOT NULL, photo TEXT NOT NULL )"
        
        static let BuiltAuditSubLocation = "( id    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id    INTEGER NOT NULL,    audit_id    INTEGER NOT NULL,    location_id    INTEGER NOT NULL,    folder_id    INTEGER NOT NULL,    sublocation_id    INTEGER NOT NULL,    is_modified    INTEGER NOT NULL,    sublocation_count    INTEGER NOT NULL,    work_status    INTEGER NOT NULL,    sublocation_name    TEXT NOT NULL,    sublocation_description    TEXT NOT NULL,    app_version    NUMERIC NOT NULL)"
        
    }
    
    enum InsertData {
    }
    
    static let UserProfile = "Id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, UserName TEXT, Password TEXT,  Address TEXT"
}

enum Params {
    static let Name = "Name"
}

class SqliteDB: NSObject {
    
    var statement: OpaquePointer?
    var auditAppDB: OpaquePointer?
    var strDBPath = String()
    
    private static var obSqlite: SqliteDB?
    
    class func sharedInstance() -> SqliteDB {
        if self.obSqlite == nil {
            print("user object nil and initiates")
            self.obSqlite = SqliteDB()
        } else {
            print("user object not nil")
        }
        return self.obSqlite!
    }
    
    
    //MARK: Basic Functions:
    /*
     Creating Data Base File
     */
    
    func createDataBaseIfNotExist() {
        let dbPath: String = getPath(fileName: strDBName)
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: dbPath) {
            let documentsURL = Bundle.main.resourceURL
            
            let fromPath = documentsURL!.appendingPathComponent(strDBName)//folderPath.appendingPathComponent(strDBName)
            print("from Path = \(fromPath)")
            
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
                print("error = w\(error.debugDescription)")
            }
        }
    }
    
    private func getDataBasePath() -> String {
        let documentsURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(strDBName)
        //  fileURL.isHidden = true
        return fileURL.path
    }
    
    /**
     This method checks that particular table exist or not, if it is exist it reurns an bool variable = true, else returns false
     */
    
    private func checkTableNameExistOrNot(strTableName: String) -> Bool {
        var querySQL = ""
        var isExist: Bool = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            querySQL = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(strTableName)'"
            let query_stmt = querySQL
            if sqlite3_prepare_v2(auditAppDB, query_stmt, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    /// If my given table name and sqlite table name both are matched means table exist and it returns the int value 1.
                    let column = String(cString: sqlite3_column_text(statement, 0))
                    if (strTableName == column) {
                        print("Table Already Available \(String(cString: sqlite3_column_text(statement, 0)))")
                        isExist = true
                    }
                    sqlite3_step(statement)
                }
                sqlite3_finalize(statement)
            } else {
                isExist = false
            }
            sqlite3_close(auditAppDB)
        }
        return isExist
    }
    
    func createTableIfNotExist(_ strTableName: String?, andFieldNames strFieldsName: String?) {
        let checkValue = checkTableNameExistOrNot(strTableName: strTableName!)
        
        /// The zero showing that table not exist we have to create it
        if checkValue == false {
            if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
                let strSqlSt = "CREATE TABLE IF NOT EXISTS \(strTableName ?? "") \(strFieldsName ?? "")"
                if sqlite3_exec(auditAppDB, strSqlSt, nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_exec: \(errmsg)")
                } else {
                    print("\(String(describing: strTableName)) Table Created successfuly")
                }
                sqlite3_close(auditAppDB)
            } else { }
        }
    }
    
    
    private func getPath(fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        //fileURL.isHidden = true
        print("fileURL.path =\(fileURL.path)")
        return fileURL.path
    }
    
   private func stepStatementCondition(strMsg: String) {
        if sqlite3_step(statement) != SQLITE_DONE {
            print(strMsg)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("error sqlite3_step: \(errmsg)")
        }
    }
    
    /*
     To check the condition, step statement execution finished or not
     */
   private func finishedExcecution(strMsg: String) {
        if sqlite3_step(statement) == SQLITE_DONE {
            print(strMsg)
            sqlite3_step(statement)
            stepStatementCondition(strMsg: strMsg)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("error sqlite3_step: \(errmsg)")
        }
    }
    
    
    //MARK: User Profile Functions
    func insertUserProfileData1(obUser: UserProfileModel) {
        var statement: OpaquePointer?
        let dbpath = getDataBasePath()
        var strMsg = ""
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.UserProfile) (userId, name, first_name, last_name, address, phone, photo, device_token, auth_token, role, language) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
            
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(statement, 1, Int32(obUser.id!))
                sqlite3_bind_text(statement, 2, obUser.name, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 3, obUser.firstName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 4, obUser.lastName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 5, obUser.address, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, obUser.phone, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 7, obUser.photo, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 8, obUser.deviceToken, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 9, obUser.authToken, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 10, obUser.userRole, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 11, obUser.language, -1, SQLITE_TRANSIENT)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.UserProfile) Record added successfully")
                    strMsg = "Code saved successfully"
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.UserProfile) entry added successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("error sqlite3_step: \(errmsg)")
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                strMsg = "\(sqlite3_errmsg(auditAppDB))"
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    
    func insertUserProfileData() {
        var statement: OpaquePointer?
        let dbpath = getDataBasePath()
        var strMsg = ""
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.UserProfile) (Name, UserName, Password, Address) VALUES (?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                
                sqlite3_bind_text(statement, 1, "Gourav", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 2, "UserName GKJ", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 3, "123456", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 4, "Address Indore", -1, SQLITE_TRANSIENT)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.UserProfile) Record added successfully")
                    strMsg = "Code saved successfully"
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.UserProfile) entry added successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("error sqlite3_step: \(errmsg)")
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                strMsg = "\(sqlite3_errmsg(auditAppDB))"
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    
    func getUserProfileData() {
        let arr = NSMutableArray()
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.UserProfile)"
            
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    var dict: [AnyHashable : Any] = [:]
                    dict["Id"] = sqlite3_column_int(statement, 0) //"\(sqlite3_column_int(statement, 0))"
                    dict["Name"] = String(cString: sqlite3_column_text(statement, 1))
                    dict["UsearName"] = String(cString:sqlite3_column_text(statement, 2))
                    dict["Password"] = String(cString:sqlite3_column_text(statement, 3))
                    //  dict["Address"] = String(cString:sqlite3_column_text(statement, 4))
                    arr.add(dict)
                }
                sqlite3_finalize(statement)
            } else {  }
            sqlite3_close(auditAppDB)
        }
        print("arr List = \(arr)")
    }
    
    func updateUserProfileData() {
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.UserProfile) set Name = ?, UserName = ?, Address = ?"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, "Gourav JS", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 2, "UserName GKJ 12", -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 3, "Address Indore", -1, SQLITE_TRANSIENT)
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.UserProfile) Record updated successfully")
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.UserProfile) entry updated successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("error sqlite3_step: \(errmsg)")
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {  }
        } else {  }
    }
    
    func deleteRecord() {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.UserProfile) "
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                //sqlite3_step(statement)
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Record Deleted")
                    sqlite3_step(statement)
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    

    //MARK: INsert Functions Into My Audit List ---------------- XXXXXXXXXXXX ----------------
    func insertMyAuditList(obAudit: MyAuditListModel) {
        var flagIsSaved = Bool()
        var strMsg = ""
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.MyAuditList) (user_id, audit_id, audit_title, audit_status, assign_by, target_date, app_version) VALUES (?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obAudit.audit_id!))
                sqlite3_bind_text(statement, 3, obAudit.audit_title, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 4, Int32(obAudit.audit_status!))
                sqlite3_bind_text(statement, 5, obAudit.assign_by, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, obAudit.target_date, -1, SQLITE_TRANSIENT)
                sqlite3_bind_double(statement, 7, AppVersion!)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.MyAuditList) Record added successfully")
                    strMsg = "Code saved successfully"
                    flagIsSaved = true
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.MyAuditList) entry added successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("error sqlite3_step: \(errmsg)")
                    }
                } else {
                    flagIsSaved = false
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                strMsg = "\(sqlite3_errmsg(auditAppDB))"
            }
        } else {
            flagIsSaved = false
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    
    /*
     This function call the list of those audit list
     */
    func getAuditListWith(status: Int) -> [MyAuditListModel] {
        
        var arr = [MyAuditListModel]()
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE audit_status = \(status) and user_id = \(UserProfile.id!)"
            
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let dict = MyAuditListModel()
                    dict.id =  Int(sqlite3_column_int(statement, 0)) //"\(sqlite3_column_int(statement, 0))"
                    dict.audit_id =  Int(sqlite3_column_int(statement, 2))
                    dict.audit_title = String(cString:sqlite3_column_text(statement, 3))
                    dict.audit_status = Int(sqlite3_column_int(statement, 4))
                    dict.assign_by = String(cString:sqlite3_column_text(statement, 5))
                    dict.target_date = String(cString:sqlite3_column_text(statement, 6))
                    arr.append(dict)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.MyAuditList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    
    /*
     This function call the list of those audit list
     */
    func getAuditStatusInfoWithAuditID(auditId: Int) -> Int {
        
        var audit_status = 0
        
        //  var arr = [MyAuditListModel]()
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    audit_status = Int(sqlite3_column_int(statement, 4))
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.MyAuditList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        return audit_status
    }
    
    
    // This function is used to check if there is any audit exist or not if exist then not add and if not then add.
    func getFullAuditList() -> [MyAuditListModel] {
        var arr = [MyAuditListModel]()
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE  user_id = \(UserProfile.id!)"
            
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let dict = MyAuditListModel()
                    dict.id =  Int(sqlite3_column_int(statement, 0)) //"\(sqlite3_column_int(statement, 0))"
                    dict.audit_id =  Int(sqlite3_column_int(statement, 2))
                    dict.audit_title = String(cString:sqlite3_column_text(statement, 3))
                    dict.audit_status = Int(sqlite3_column_int(statement, 4))
                    dict.assign_by = String(cString:sqlite3_column_text(statement, 5))
                    dict.target_date = String(cString:sqlite3_column_text(statement, 6))
                    arr.append(dict)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.MyAuditList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    /*
     This functions checks that any audit data saved or not.....if saved then user cannot able to accept another. It returns two values Bool and Int. Bool for check condition and Int will check which audit is downloaded so that there will be no repeatation found.
     */
    func checkAnyBuiltAuditEntryExistOrNot() -> [Any] {
        var isExist = false
        var auditId = Int()
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.BuiltAuditLocation) WHERE  user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    print("Int(sqlite3_column_int(statement, 2))  = \(Int(sqlite3_column_int(statement, 2)))")
                    auditId = Int(sqlite3_column_int(statement, 2))
                    isExist = true
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.BuiltAuditLocation) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        return  [isExist, auditId]
    }
    
    func updateAuditWorkStatus(auditStatus: Int, auditId: Int) -> [Any] {
        var strMsg = ""
        var flagIsUpdated = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.MyAuditList) set audit_status = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(auditStatus))
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.MyAuditList) Record updated successfully")
                    strMsg = "\(DBTables.MyAuditList) Record updated successfully"
                    flagIsUpdated = true
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.MyAuditList) entry updated successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("error sqlite3_step: \(errmsg)")
                        strMsg = "\(DBTables.MyAuditList) \(errmsg)"
                        flagIsUpdated = false
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                    strMsg = "\(DBTables.MyAuditList) \(errmsg)"
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
                strMsg = "\(DBTables.MyAuditList) \(errmsg)"
                flagIsUpdated = false
            }
        }
        return [flagIsUpdated, strMsg]
    }
    
    // ---------------- XXXXXXXXXXXX ---------------- ---------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX ----------------
    
    
    
     // ---------------- XXXXXXXXXXXX ---------------- Built Audit Category ---------------- XXXXXXXXXXXX ----------------
    
    //MARK: INsert Functions Into Built Audit Category List ---------------- XXXXXXXXXXXX ----------------
  
    func insertLocationData(obLocation: LocationModel) {
        var strMsg = ""
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.BuiltAuditLocation) (user_id, audit_id, location_id, location_count, location_name, location_description, modified, app_version, is_locked) VALUES (?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obLocation.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obLocation.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obLocation.locationCount!))
                sqlite3_bind_text(statement, 5, obLocation.locationName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, obLocation.locationDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 7, Int32(obLocation.isModified!))
                sqlite3_bind_double(statement, 8, AppVersion!)
                sqlite3_bind_int(statement, 9, Int32(obLocation.isLocked!))

            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(DBTables.BuiltAuditLocation) Record added successfully")
                
                strMsg = "Code saved successfully"
                sqlite3_step(statement)
                if sqlite3_step(statement) != SQLITE_DONE {
                    print("\(DBTables.BuiltAuditLocation) entry added successfuly")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    
    func getLocationList(isModified:Int, auditId: Int) -> [LocationModel] {
        var arr = [LocationModel]()
       // statement = nil
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.BuiltAuditLocation) WHERE modified = \(isModified) and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = LocationModel()
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.locationCount = Int(sqlite3_column_int(statement, 4))
                    obMAL.locationName = String(cString:sqlite3_column_text(statement, 5))
                    obMAL.locationDescription = String(cString:sqlite3_column_text(statement, 6))
                    obMAL.isModified = Int(sqlite3_column_int(statement, 7))
                    obMAL.arrFolders = getLocationFolderList(locationId: obMAL.locationId!, auditId: obMAL.auditId!)
                    arr.append(obMAL)
                }
                
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.BuiltAuditLocation) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        
        return arr
    }
    
    func updateBuiltAuditLocation(isModified: Int, locationId: Int, auditId: Int) -> [Any] {
        var strMsg = ""
        var flagIsUpdated = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.BuiltAuditLocation) set modified = ? Where audit_id = \(auditId) and location_id = \(locationId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(isModified))
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.BuiltAuditLocation) Record updated successfully")
                    strMsg = "\(DBTables.BuiltAuditLocation) Record updated successfully"
                    flagIsUpdated = true
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.BuiltAuditLocation) entry updated successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("error sqlite3_step: \(errmsg)")
                        strMsg = "\(DBTables.BuiltAuditLocation) \(errmsg)"
                        flagIsUpdated = false
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                    strMsg = "\(DBTables.BuiltAuditLocation) \(errmsg)"
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
                strMsg = "\(DBTables.BuiltAuditLocation) \(errmsg)"
                flagIsUpdated = false
            }
        }
        //let arr = [flagIsUpdated, strMsg]
        return [flagIsUpdated, strMsg]
    }
    
    func updateBuiltAuditLocationCount(count: Int, locationId: Int, auditId: Int) -> [Any] {
        var strMsg = ""
        var flagIsUpdated = false
        statement =  nil
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.BuiltAuditLocation) set location_count = ? Where audit_id = \(auditId) and location_id = \(locationId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(count))
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.BuiltAuditLocation) Record updated successfully")
                    strMsg = "\(DBTables.BuiltAuditLocation) Record updated successfully"
                    flagIsUpdated = true
                    sqlite3_step(statement)
                    /*
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.BuiltAuditLocation) entry updated successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("error sqlite3_step: \(errmsg)")
                        strMsg = "\(DBTables.BuiltAuditLocation) \(errmsg)"
                        flagIsUpdated = false
                    } */
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                    strMsg = "\(DBTables.BuiltAuditLocation) \(errmsg)"
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
                strMsg = "\(DBTables.BuiltAuditLocation) \(errmsg)"
                flagIsUpdated = false
            }
        }
        //let arr = [flagIsUpdated, strMsg]
        return [flagIsUpdated, strMsg]
    }
    
    // ---------------- XXXXXXXXXXXX ---------------- ---------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX ----------------
    //MARK: SubLocation Setions:
    
    /**
     This will call the sub location list that saved during questionaaries and modules time and this will be used for read only purpose
     */
    func getDefaultSubLocationList(auditId: Int) -> [SubLocationModel] {
        var arr = [SubLocationModel]()
        // statement = nil
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.SubLocation) WHERE audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = SubLocationModel()
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.subLocationCount = Int(sqlite3_column_int(statement, 4))
                    obMAL.subLocationName = String(cString:sqlite3_column_text(statement, 5))
                    obMAL.subLocationDescription = String(cString:sqlite3_column_text(statement, 6))
                    arr.append(obMAL)
                }
                
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.BuiltAuditLocation) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        
        return arr
    }
    
    func getBuiltAuditSubLocationList(auditId: Int, locationId: Int, folderId: Int, subFolderId: Int) -> [BuiltAuditSubLocationModel] {
        var arr = [BuiltAuditSubLocationModel]()
        // statement = nil
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.BuiltAuditSubLocation) WHERE audit_id = \(auditId) and user_id = \(UserProfile.id!) and location_id = \(locationId) and folder_id = \(folderId) and subfolder_id = \(subFolderId)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obSL = BuiltAuditSubLocationModel()
                    obSL.auditId = Int(sqlite3_column_int(statement, 2))
                    obSL.locationId = Int(sqlite3_column_int(statement, 3))
                    obSL.subLocationId  = Int(sqlite3_column_int(statement, 4))
                    obSL.folderId  = Int(sqlite3_column_int(statement, 5))
                    obSL.subFolderId  = Int(sqlite3_column_int(statement, 6))
                    obSL.isModified  = Int(sqlite3_column_int(statement, 7))
                    obSL.subLocationCount  = Int(sqlite3_column_int(statement, 8))
                    obSL.workStatus  = Int(sqlite3_column_int(statement, 9))
                    obSL.subLocationName = String(cString:sqlite3_column_text(statement, 10))
                    obSL.subLocationDescription = String(cString:sqlite3_column_text(statement, 11))
                    arr.append(obSL)
                }
                
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.BuiltAuditSubLocation) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        
        return arr
    }
    
    func insertBuiltAuditSubLocationData(obBASL: BuiltAuditSubLocationModel) {
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.BuiltAuditSubLocation) (user_id, audit_id, location_id, sublocation_id, folder_id, subfolder_id, is_modified, sublocation_count, work_status, sublocation_name, sublocation_description, app_version) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obBASL.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obBASL.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obBASL.subLocationId!))
                sqlite3_bind_int(statement, 5, Int32(obBASL.folderId!))
                sqlite3_bind_int(statement, 6, Int32(obBASL.subFolderId!))
                sqlite3_bind_int(statement, 7, Int32(obBASL.isModified!))
                sqlite3_bind_int(statement, 8, Int32(obBASL.subLocationCount!))
                sqlite3_bind_int(statement, 9, Int32(obBASL.workStatus!))
                sqlite3_bind_text(statement, 10, obBASL.subLocationName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 11, obBASL.subLocationDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_double(statement, 12, AppVersion!)
            }
            self.finishedExcecution(strMsg: "\(DBTables.AuditQuestions) recored added")
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
            
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    /// This will update the sublocation count when we increase or decrease the counter value
    func updateSubLocationFolderCount(incId: Int, subLocationCount: Int) -> [Any] {
        var strMsg = ""
        var flagIsUpdated = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.BuiltAuditSubLocation) set sublocation_count = ?  Where id = \(incId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(statement, 1, Int32(subLocationCount))
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.BuiltAuditSubLocation) Record updated successfully")
                    strMsg = "\(DBTables.BuiltAuditSubLocation) Record updated successfully"
                    flagIsUpdated = true
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.BuiltAuditSubLocation) entry updated successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("\(DBTables.BuiltAuditSubLocation) error sqlite3_step: \(errmsg)")
                        strMsg = "\(DBTables.BuiltAuditSubLocation) \(errmsg)"
                        flagIsUpdated = false
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("\(DBTables.BuiltAuditSubLocation) error sqlite3_step: \(errmsg)")
                    strMsg = "\(DBTables.BuiltAuditSubLocation) \(errmsg)"
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
                strMsg = "\(DBTables.BuiltAuditSubLocation) \(errmsg)"
                flagIsUpdated = false
            }
        } // end of open
        return  [flagIsUpdated, strMsg]
    }
    
    /// This will update the sublocation count when we increase or decrease the counter value
    func updateSubLocationWorkStatus(incId: Int, workStatus: Int) -> [Any] {
        var strMsg = ""
        var flagIsUpdated = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.BuiltAuditSubLocation) set work_status = ?  Where id = \(incId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(statement, 1, Int32(workStatus))
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.BuiltAuditSubLocation) Record updated successfully")
                    strMsg = "\(DBTables.BuiltAuditSubLocation) Record updated successfully"
                    flagIsUpdated = true
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.BuiltAuditSubLocation) entry updated successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("\(DBTables.BuiltAuditSubLocation) error sqlite3_step: \(errmsg)")
                        strMsg = "\(DBTables.BuiltAuditSubLocation) \(errmsg)"
                        flagIsUpdated = false
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("\(DBTables.BuiltAuditSubLocation) error sqlite3_step: \(errmsg)")
                    strMsg = "\(DBTables.BuiltAuditSubLocation) \(errmsg)"
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
                strMsg = "\(DBTables.BuiltAuditSubLocation) \(errmsg)"
                flagIsUpdated = false
            }
        } // end of open
        return  [flagIsUpdated, strMsg]
    }
    
    func deleteSubLocationData(incId: Int) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.BuiltAuditSubLocation) WHERE id = \(incId)"
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                //sqlite3_step(statement)
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Record Deleted from \(DBTables.BuiltAuditSubLocation)")
                    sqlite3_step(statement)
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    
   
    // ---------------- XXXXXXXXXXXX ---------------- ---------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX ----------------
    
    
    
    // ---------------- XXXXXXXXXXXX ---------------- Category Folder List---------------- XXXXXXXXXXXX ----------------
    
    //MARK: INsert Functions Into Category Folder List ---------------- XXXXXXXXXXXX ----------------
    
    func insertLocationFolderData(obFolder: LocationFolderModel) {
        var strMsg = ""
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.LocationFolder) (user_id, audit_id, location_id, folder_name, folder_count, app_version) VALUES (?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obFolder.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obFolder.locationId!))
                sqlite3_bind_text(statement, 4, obFolder.folderName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 5, Int32(obFolder.folderCount!))
                sqlite3_bind_double(statement, 6, AppVersion!)
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(DBTables.LocationFolder) Record added successfully")
                strMsg = "Code saved successfully"
                sqlite3_step(statement)
                if sqlite3_step(statement) != SQLITE_DONE {
                    print("\(DBTables.LocationFolder) entry added successfuly")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    
    func updateLocationFolderCount(incId: Int, folderCount: Int) -> Bool {
        var strMsg = ""
        var flagIsUpdated = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.LocationFolder) set folder_count = ?  Where id = \(incId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(statement, 1, Int32(folderCount))
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.LocationSubFolderList) Record updated successfully")
                    strMsg = "\(DBTables.LocationSubFolderList) Record updated successfully"
                    flagIsUpdated = true
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.LocationSubFolderList) entry updated successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("\(DBTables.LocationSubFolderList) error sqlite3_step: \(errmsg)")
                        strMsg = "\(DBTables.LocationSubFolderList) \(errmsg)"
                        flagIsUpdated = false
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("\(DBTables.LocationSubFolderList) error sqlite3_step: \(errmsg)")
                    strMsg = "\(DBTables.LocationSubFolderList) \(errmsg)"
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
                strMsg = "\(DBTables.LocationSubFolderList) \(errmsg)"
                flagIsUpdated = false
            }
        } // end of open
        
        return flagIsUpdated
    }
    
    
    func getLocationFolderList(locationId:Int, auditId:Int) -> [LocationFolderModel] {
        var arr = [LocationFolderModel]()
        var statement: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.LocationFolder) WHERE location_id = \(locationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = LocationFolderModel()
                    obMAL.primaryId = Int(sqlite3_column_int(statement, 0))
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.folderName = String(cString:sqlite3_column_text(statement, 4))
                    obMAL.folderCount = Int(sqlite3_column_int(statement, 5))
                    obMAL.arrSubFolders = getLocationSubFolderList(locationId: locationId, auditId: auditId, folderId: obMAL.primaryId!)
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.LocationFolder) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    func updateLocationFolderCounter(count: Int, foldertitle:String, Index: Int) -> Bool {
        var strMsg = ""
        var flagIsUpdated = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            
            let insertSQL = "UPDATE \(DBTables.LocationFolder) set folder_count = ? , folder_name = ? Where id = \(Index) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(count))
                sqlite3_bind_text(statement, 2, foldertitle, -1, SQLITE_TRANSIENT)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.LocationFolder) Record updated successfully")
                    strMsg = "\(DBTables.LocationFolder) Record updated successfully"
                    flagIsUpdated = true
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.LocationFolder) entry updated successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("error sqlite3_step: \(errmsg)")
                        strMsg = "\(DBTables.LocationFolder) \(errmsg)"
                        flagIsUpdated = false
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                    strMsg = "\(DBTables.LocationFolder) \(errmsg)"
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
                strMsg = "\(DBTables.LocationFolder) \(errmsg)"
                flagIsUpdated = false
            }
        }
        return flagIsUpdated
    }
    
    func deleteFoldersFromLoactionFolder(auditId:Int, locationId:Int) -> Bool {
        var flagIsDeleted = false
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.LocationFolder) WHERE location_id = \(locationId) and audit_id = \(auditId)"
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                //sqlite3_step(statement)
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Record Deleted")
                    flagIsDeleted = true
                    sqlite3_step(statement)
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
        return flagIsDeleted
    }
    
    /// This query ececutes when after accepting the condition for location count less than folders count
    func deleteLocationSubFolders(auditId:Int, locationId:Int) {
        var flagIsDelete = false
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.LocationSubFolderList) WHERE location_id = \(locationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Record Deleted")
                    sqlite3_step(statement)
                    flagIsDelete = true
                    
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                    flagIsDelete = false
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
        
        if flagIsDelete {
            /// This delay of time is used to prevent from unintentionally load in Database
            let delay = 2.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.deleteFoldersFromLoactionFolder(auditId: auditId, locationId: locationId)
            })
        }
    }
    
    
    
    
    // ---------------- XXXXXXXXXXXX ---------------- ---------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX ----------------

    func insertLocationSubFolderListData(obFolder: LocationSubFolderListModel) {
        var strMsg = ""
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.LocationSubFolderList) (user_id, audit_id, location_id, folder_id, is_archive, sub_folder_name, sub_folder_description) VALUES (?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obFolder.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obFolder.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obFolder.folderId!))
                sqlite3_bind_int(statement, 5, Int32(obFolder.is_archive!))
                sqlite3_bind_text(statement, 6, obFolder.subFolderName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 7, obFolder.subFolderDescription, -1, SQLITE_TRANSIENT)
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(DBTables.LocationSubFolderList) Record added successfully")
                strMsg = "Code saved successfully"
                sqlite3_step(statement)
                if sqlite3_step(statement) != SQLITE_DONE {
                    print("\(DBTables.LocationSubFolderList) entry added successfuly")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    
    
    func getLocationSubFolderList(locationId:Int, auditId:Int, folderId:Int) -> [LocationSubFolderListModel] {
        var arr = [LocationSubFolderListModel]()
        var statement: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.LocationSubFolderList) WHERE location_id = \(locationId) and audit_id = \(auditId) and folder_id = \(folderId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = LocationSubFolderListModel()
                    obMAL.incId = Int(sqlite3_column_int(statement, 0))
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.folderId = Int(sqlite3_column_int(statement, 4))
                    obMAL.is_archive = Int(sqlite3_column_int(statement, 5))
                    obMAL.subFolderName = String(cString:sqlite3_column_text(statement, 6))
                    obMAL.subFolderDescription = String(cString:sqlite3_column_text(statement, 7))
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.LocationSubFolderList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    func deleteSelectedSubFolderData(incId: Int) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.LocationSubFolderList) WHERE id = \(incId)"
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Record Deleted from \(DBTables.LocationSubFolderList)")
                    sqlite3_step(statement)
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    func deleteSubFoldersByFolderId(auditId:Int, locationId:Int, folderId:Int) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.LocationSubFolderList) WHERE location_id = \(locationId) and audit_id = \(auditId) and folder_id = \(folderId)"
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Record Deleted")
                    sqlite3_step(statement)
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    func updateSubFolderData(subfoldertitle:String, subfolderdescription:String, primaryId: Int) -> [Any] {
        var strMsg = ""
        var flagIsUpdated = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            
            let insertSQL = "UPDATE \(DBTables.LocationSubFolderList) set sub_folder_name = ? , sub_folder_description = ? Where id = \(primaryId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, subfoldertitle, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 2, subfolderdescription, -1, SQLITE_TRANSIENT)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.LocationSubFolderList) Record updated successfully")
                    strMsg = "\(DBTables.LocationSubFolderList) Record updated successfully"
                    flagIsUpdated = true
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.LocationSubFolderList) entry updated successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("error sqlite3_step: \(errmsg)")
                        strMsg = "\(DBTables.LocationSubFolderList) \(errmsg)"
                        flagIsUpdated = false
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                    strMsg = "\(DBTables.LocationSubFolderList) \(errmsg)"
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
                strMsg = "\(DBTables.LocationSubFolderList) \(errmsg)"
                flagIsUpdated = false
            }
        }
        return [flagIsUpdated, strMsg]
    }
    
    // ---------------- XXXXXXXXXXXX ---------------- ---------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX ----------------

    func insertSubLocationData(obSubLoc: SubLocationModel) {
        var strMsg = ""
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.SubLocation) (user_id, audit_id, location_id, sublocation_id, work_status, sublocation_count, sublocation_name, sublocation_description, modified, app_version) VALUES (?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obSubLoc.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obSubLoc.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obSubLoc.subLocationId!))
                sqlite3_bind_int(statement, 5, Int32(obSubLoc.work_status!))
                sqlite3_bind_int(statement, 6, Int32(obSubLoc.subLocationCount!))
                sqlite3_bind_text(statement, 7, obSubLoc.subLocationName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 8, obSubLoc.subLocationDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 9, Int32(obSubLoc.isModified!))
                sqlite3_bind_double(statement, 10, AppVersion!)
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(DBTables.SubLocation) Record added successfully")
                strMsg = "Code saved successfully"
                sqlite3_step(statement)
                if sqlite3_step(statement) != SQLITE_DONE {
                    print("\(DBTables.SubLocation) entry added successfuly")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: Questions SQL
    
    func insertQuestionsData(obQuestion: QuestionsModel) {
        var strMsg = ""
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.AuditQuestions) (user_id, audit_id, location_id, question_id, question_type, category_type, priority, question, answers, answers_id) VALUES (?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obQuestion.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obQuestion.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obQuestion.questionId!))
                sqlite3_bind_int(statement, 5, Int32(obQuestion.questionType!))
                sqlite3_bind_int(statement, 6, Int32(obQuestion.categoryType!))
                sqlite3_bind_int(statement, 7, Int32(obQuestion.priority!))
                sqlite3_bind_text(statement, 8, obQuestion.question, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 9, obQuestion.answers, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 10, obQuestion.answerId, -1, SQLITE_TRANSIENT)
                
            }
            
            self.finishedExcecution(strMsg: "\(DBTables.AuditQuestions) recored added")
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: Sub Questions SQL
    
    func insertSubQuestionsData(obSubQ: SubQuestionsModel) {
        var strMsg = ""
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.AuditSubQuestions) (user_id, audit_id, location_id, sub_location_id, question_id, sub_question_id, answer_id, sub_question_type, sub_question, answer ) VALUES (?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obSubQ.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obSubQ.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obSubQ.subLocationId!))
                sqlite3_bind_int(statement, 5, Int32(obSubQ.questionId!))
                sqlite3_bind_int(statement, 6, Int32(obSubQ.subQuestionId!))
                sqlite3_bind_int(statement, 7, Int32(obSubQ.answerId!))
                sqlite3_bind_int(statement, 8, Int32(obSubQ.subQuestionType!))
                sqlite3_bind_text(statement, 9, obSubQ.subQuestion, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 10, obSubQ.answer, -1, SQLITE_TRANSIENT)
                
            }
            
            self.finishedExcecution(strMsg: "\(DBTables.AuditSubQuestions) recored added")
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: Answers SQL
    func insertAnswersData(obAns: AuditAnswerModel) {
        var strMsg = ""
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.AuditAnswers) (user_id, audit_id, location_id, sub_location_id, folder_id, question_id, answer_id, question_type, category_type, priority, is_update, question, answer, description, img_data ) VALUES (?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obAns.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obAns.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obAns.subLocationId!))
                sqlite3_bind_int(statement, 5, Int32(obAns.folderId!))
                sqlite3_bind_int(statement, 6, Int32(obAns.questionId!))
                sqlite3_bind_int(statement, 7, Int32(obAns.answerId!)!)
                sqlite3_bind_int(statement, 8, Int32(obAns.questionType!))
                sqlite3_bind_int(statement, 9, Int32(obAns.categoryType!))
                sqlite3_bind_int(statement, 10, Int32(obAns.priority!))
                sqlite3_bind_int(statement, 11, Int32(obAns.isUpdate!))
                sqlite3_bind_text(statement, 12, obAns.question, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 13, obAns.answers, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 14, obAns.answerDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 15, obAns.img64Data, -1, SQLITE_TRANSIENT)
                
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(DBTables.AuditAnswers) Record added successfully")
                
                strMsg = "Code saved successfully"
                sqlite3_step(statement)
                if sqlite3_step(statement) != SQLITE_DONE {
                    print("\(DBTables.AuditAnswers) entry added successfuly")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
    
    
    //MARK: Sub Answers SQL
    func insertSubAnswersData(obAns: AuditAnswerModel) {
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.AuditAnswers) (user_id, audit_id, location_id, sub_location_id, folder_id, question_id, answer_id, question_type, category_type, priority, is_update, question, answer, description, img_data ) VALUES (?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obAns.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obAns.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obAns.subLocationId!))
                sqlite3_bind_int(statement, 5, Int32(obAns.folderId!))
                sqlite3_bind_int(statement, 6, Int32(obAns.questionId!))
                sqlite3_bind_int(statement, 7, Int32(obAns.answerId!)!)
                sqlite3_bind_int(statement, 8, Int32(obAns.questionType!))
                sqlite3_bind_int(statement, 9, Int32(obAns.categoryType!))
                sqlite3_bind_int(statement, 10, Int32(obAns.priority!))
                sqlite3_bind_int(statement, 11, Int32(obAns.isUpdate!))
                sqlite3_bind_text(statement, 12, obAns.question, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 13, obAns.answers, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 14, obAns.answerDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 15, obAns.img64Data, -1, SQLITE_TRANSIENT)
                
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(DBTables.AuditAnswers) Record added successfully")
                
                sqlite3_step(statement)
                if sqlite3_step(statement) != SQLITE_DONE {
                    print("\(DBTables.AuditAnswers) entry added successfuly")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }
   
    // ---------------- XXXXXXXXXXXX ---------------- ---------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX -------------------------------- XXXXXXXXXXXX ----------------
    
    func insertUserChatList(oblist: ChatListModel) {
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.ChatUserList) (user_id, to_user_id, name, time, role, photo, phone, email, last_msg, msg_type) VALUES (?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(oblist.user_id!))
                sqlite3_bind_text(statement, 3, oblist.name, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 4, oblist.time, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 5, oblist.role, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, oblist.profilePic, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 7, oblist.phone, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 8, oblist.email, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 9, oblist.msg, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 10, oblist.msg_type, -1, SQLITE_TRANSIENT)
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(DBTables.ChatUserList) Record added successfully")
                
                sqlite3_step(statement)
                if sqlite3_step(statement) != SQLITE_DONE {
                    print("\(DBTables.ChatUserList) entry added successfuly")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
    }

    
    func getChatList() -> [ChatListModel] {
        var arr = [ChatListModel]()
        var statement: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.ChatUserList) WHERE user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = ChatListModel()
                    obMAL.user_id = Int(sqlite3_column_int(statement, 2))
                    obMAL.name = String(cString:sqlite3_column_text(statement, 3))
                    obMAL.time = String(cString:sqlite3_column_text(statement, 4))
                    obMAL.role = String(cString:sqlite3_column_text(statement, 5))
                    obMAL.profilePic = String(cString:sqlite3_column_text(statement, 6))
                    obMAL.phone = String(cString:sqlite3_column_text(statement, 7))
                    obMAL.email = String(cString:sqlite3_column_text(statement, 8))
                    obMAL.msg = String(cString:sqlite3_column_text(statement, 9))
                    obMAL.msg_type = String(cString:sqlite3_column_text(statement, 10))
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.ChatUserList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    //MARK: User Chat Operations
    /**
     1. Insert User Chat Data:
     2. Get Chat Data by Logged In User Id and with Userid
     3. Get Distinct Date with user Id and With user Id // If we implement the section wise chat by date
     4. Saved Received message with unread counter
     5. Update unread messages of user and withUser Id
     6. Get unread message Of user
     **/
    
    func insertChatData(obchat: ChatModel) -> Bool {
        
        var insertsuccess = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.UserChating) (user_id ,to_user_id, from_id, from_name, msg, msg_time, msgtype, photo, is_download) VALUES (?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obchat.to_user_id!))
                sqlite3_bind_int(statement, 3, Int32(obchat.fromid!))
                sqlite3_bind_text(statement, 4, obchat.from_name, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 5, obchat.msg, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, obchat.msgtime, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 7, Int32(obchat.msgtype!))
                sqlite3_bind_text(statement, 8, "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 9, Int32(obchat.is_download!))
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                insertsuccess = true
                print("\(DBTables.UserChating) Record added successfully")

                sqlite3_step(statement)
                if sqlite3_step(statement) != SQLITE_DONE {
                    print("\(DBTables.UserChating) entry added successfuly")
                } else {
                    insertsuccess = false
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                }
            } else {
                insertsuccess = false
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            insertsuccess = false
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        
        return insertsuccess
        
      //  SELECT MAX(id) FROM UserChating
    }
    
    func getChatLastId() -> Int {
        var primaryid = 0
        var statement: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT MAX(id) FROM \(DBTables.UserChating)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                   primaryid = Int(sqlite3_column_int(statement, 0))
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.UserChating) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        return primaryid
    }
    
    func getChat(to_user_id: Int) -> NSMutableArray {
        
        var flag = false
        var arr = [ChatModel]()
        var statement: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.UserChating) WHERE user_id = \(UserProfile.id!) and to_user_id = \(to_user_id)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = ChatModel()
                    obMAL.incId = Int(sqlite3_column_int(statement, 0))
                    obMAL.to_user_id = Int(sqlite3_column_int(statement, 2))
                    obMAL.fromid = Int(sqlite3_column_int(statement, 3))
                    obMAL.from_name =  String(cString:sqlite3_column_text(statement, 4))
                    obMAL.msg = String(cString:sqlite3_column_text(statement, 5))
                    obMAL.msgtime = String(cString:sqlite3_column_text(statement, 6))
                    obMAL.msgtype = Int(sqlite3_column_int(statement, 7))
                    obMAL.is_download = Int(sqlite3_column_int(statement, 9))
                    arr.append(obMAL)
                }
                flag = true
                sqlite3_finalize(statement)
            } else {
                flag = false
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("\(DBTables.UserChating) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            flag = false
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            print("data base is not opened \(errmsg)")
        }
        let arr1 = NSMutableArray()
        arr1.add(arr)
        arr1.add(flag)
        return arr1
    }
    
    func updateChatDownload(isDownload: Int, msg:String, incId: Int) -> Bool {
        
        var flagIsUpdated = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.UserChating) set is_download = ? , msg = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(statement, 1, Int32(isDownload))
                sqlite3_bind_text(statement, 2, msg, -1, SQLITE_TRANSIENT)

                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(DBTables.UserChating) Record updated successfully")
                    flagIsUpdated = true
                    sqlite3_step(statement)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        print("\(DBTables.UserChating) entry updated successfuly")
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                        print("error sqlite3_step: \(errmsg)")
                        flagIsUpdated = false
                    }
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                print("error sqlite3_step: \(errmsg)")
                flagIsUpdated = false
            }
        }
        return flagIsUpdated
    }
    
    func deleteChatRecord(to_user_id:Int) -> Bool {
        
        var is_deleted = false
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.UserChat) WHERE user_id = \(UserProfile.id!) and to_user_id = \(to_user_id)"
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                //sqlite3_step(statement)
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Record Deleted")
                    sqlite3_step(statement)
                    is_deleted = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    print("error sqlite3_step: \(errmsg)")
                    is_deleted = false
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
        return is_deleted
    }
    
    
}
