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
    static let SubLocation = "SubLocation"
    static let LocationFolder = "LocationFolder"
}

enum SQLQuery {
    enum CreateTable {
        static let SubLocation = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id    INTEGER NOT NULL, audit_id  INTEGER NOT NULL, location_id   INTEGER NOT NULL, sublocation_id  INTEGER NOT NULL, sublocation_count    INTEGER NOT NULL, sublocation_name   TEXT NOT NULL,sublocation_description  TEXT NOT NULL, modified    INTEGER NOT NULL, app_version NUMERIC NOT NULL)"
        
        static let LocationFolder = " ( id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, folder_name TEXT NOT NULL, folder_count  INTEGER NOT NULL , app_version NUMERIC NOT NULL)"
        
        static let BuiltAuditLocation = "(  id   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL,   audit_id   INTEGER NOT NULL,   location_id   INTEGER NOT NULL,   location_count   INTEGER NOT NULL,   location_name   TEXT NOT NULL,   location_description   TEXT NOT NULL,   modified   INTEGER NOT NULL,   app_version   NUMERIC NOT NULL )"
        
        static let MyAuditList = "( id   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,   user_id   INTEGER NOT NULL,   audit_id   INTEGER NOT NULL,   audit_title   TEXT NOT NULL,   audit_status   INTEGER NOT NULL,   assign_by   TEXT NOT NULL,   target_date   TEXT NOT NULL,   app_version   NUMERIC NOT NULL )"
        
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
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
                    print("\(strTableName) Table Created successfuly")
                }
                sqlite3_close(auditAppDB)
            } else { }
        }
    }
    
    
    private func getPath(fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var fileURL = documentsURL.appendingPathComponent(fileName)
        //fileURL.isHidden = true
        print("fileURL.path =\(fileURL.path)")
        return fileURL.path
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
    
    
    //MARK: INsert Functions Into My Audit List
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
     This function call the list of those audits whose status is Incompleted
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
    
    
    func insertSubLocationData(obSubLoc: SubLocationModel) {
        var strMsg = ""
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.SubLocation) (user_id, audit_id, location_id, sublocation_id, sublocation_count, sublocation_name, sublocation_description, modified, app_version) VALUES (?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obSubLoc.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obSubLoc.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obSubLoc.subLocationId!))
                sqlite3_bind_int(statement, 5, Int32(obSubLoc.subLocationCount!))
                sqlite3_bind_text(statement, 6, obSubLoc.subLocationName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 7, obSubLoc.subLocationDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 8, Int32(obSubLoc.isModified!))
                sqlite3_bind_double(statement, 9, AppVersion!)
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
    
    func insertLocationData(obLocation: LocationModel) {
        var strMsg = ""
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.BuiltAuditLocation) (user_id, audit_id, location_id, location_count, location_name, location_description, modified, app_version) VALUES (?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obLocation.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obLocation.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obLocation.locationCount!))
                sqlite3_bind_text(statement, 5, obLocation.locationName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, obLocation.locationDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 7, Int32(obLocation.isModified!))
                sqlite3_bind_double(statement, 8, AppVersion!)
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
    
    func getLocationList(isModified:Int) -> [LocationModel] {
        var arr = [LocationModel]()
        var statement: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.BuiltAuditLocation) WHERE modified = \(isModified) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = LocationModel()
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.locationCount = Int(sqlite3_column_int(statement, 4))
                    obMAL.locationName = String(cString:sqlite3_column_text(statement, 5))
                    obMAL.locationDescription = String(cString:sqlite3_column_text(statement, 6))
                    obMAL.isModified = Int(sqlite3_column_int(statement, 7))
                    obMAL.arrSubFolders = getLocationFolderList(locationId: obMAL.locationId!, auditId: obMAL.auditId!)
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
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.BuiltAuditLocation) set location_count = ? Where audit_id = \(auditId) and location_id = \(locationId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(count))
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
    
    func updateLocationFolderCounter(count: Int, foldertitle:String, Index: Int) -> [Any] {
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
        return [flagIsUpdated, strMsg]
    }
    
    func deleteSubFoldersFromLoactionFolder(auditId:Int, locationId:Int) {
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
    
}
