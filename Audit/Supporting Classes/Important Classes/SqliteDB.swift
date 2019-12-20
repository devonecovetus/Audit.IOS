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
    static let MyAuditList = "My_Audit_List"
    static let BuiltAuditLocation = "BuiltAuditLocation"
    static let BuiltAuditSubLocation = "BuiltAuditSubLocation"
    static let SubLocation = "SubLocation"
    static let LocationFolder = "LocationFolder"
    static let LocationSubFolderList = "LocationSubFolderList"
    static let SubLocationSubFolderList = "SubLocationSubFolderList"
    static let AuditQuestions = "AuditQuestions"
    static let AuditAnswers = "AuditAnswers"
    static let ChatUserList = "ChatUserList"
    static let UserChating = "UserChating"
    static let SubLocationSubFolderPhotos = "SubLocationSubFolderPhotos"
}

enum SQLQuery {
    enum CreateTable {
        
        static let SubLocation = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, sublocation_id INTEGER NOT NULL, work_status INTEGER NOT NULL, sublocation_count INTEGER NOT NULL, sublocation_name TEXT NOT NULL, sublocation_description TEXT NOT NULL, modified INTEGER NOT NULL, app_version NUMERIC NOT NULL )"
        
        static let LocationFolder = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, folder_name TEXT NOT NULL, folder_count INTEGER NOT NULL, app_version NUMERIC NOT NULL )"
        
        static let BuiltAuditLocation = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, location_count INTEGER NOT NULL, location_name TEXT NOT NULL, location_description TEXT NOT NULL, modified INTEGER NOT NULL, app_version NUMERIC NOT NULL, is_locked INTEGER NOT NULL )"
        
        static let MyAuditList = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, audit_title TEXT NOT NULL, audit_status INTEGER NOT NULL, assign_by TEXT NOT NULL, target_date TEXT NOT NULL, app_version NUMERIC NOT NULL, country_id INTEGER NOT NULL, lang_name TEXT NOT NULL, is_start_sync INTEGER NOT NULL )"
        
        static let LocationSubFolderList =  "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, folder_id INTEGER NOT NULL, is_archive INTEGER NOT NULL, sub_folder_name TEXT NOT NULL, sub_folder_description TEXT NOT NULL, photo TEXT, is_sync INTEGER NOT NULL )"
        
        static let SubLocationSubFolderList = "( inc_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, sublocation_id INTEGER NOT NULL, folder_id INTEGER NOT NULL, subfolder_id INTEGER NOT NULL, is_archive INTEGER NOT NULL, work_status INTEGER NOT NULL, is_locked INTEGER NOT NULL, subfolder_name TEXT NOT NULL, subfolder_description TEXT NOT NULL )"
        
        static let AuditQuestions = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, sublocation_id INTEGER NOT NULL, question_id INTEGER NOT NULL, question_type INTEGER NOT NULL, category_type INTEGER NOT NULL, priority INTEGER NOT NULL, has_subquestion INTEGER NOT NULL, is_subquestion INTEGER NOT NULL, parent_question_id INTEGER NOT NULL, subquestion_answer_id INTEGER NOT NULL, question TEXT NOT NULL, answer TEXT NOT NULL, answers_id TEXT NOT NULL, is_superuser_audit INTEGER NOT NULL)"
        
        static let AuditAnswers = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, sub_location_id INTEGER NOT NULL, folder_id INTEGER NOT NULL, question_id INTEGER NOT NULL, answer_id TEXT NOT NULL, question_type INTEGER NOT NULL, category_type INTEGER NOT NULL, priority INTEGER NOT NULL, is_update INTEGER NOT NULL, sublocation_subfolder_id INTEGER NOT NULL, subfolder_id INTEGER NOT NULL, question TEXT NOT NULL, answer TEXT NOT NULL, description TEXT, img_data TEXT, saved_answer TEXT, saved_answer_id INTEGER, has_subquestion INTEGER NOT NULL, is_subquestion INTEGER NOT NULL, parent_question_id INTEGER NOT NULL, subquestion_answer_id INTEGER, is_sync INTEGER NOT NULL )"
        
        static let ChatUserList = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, to_user_id INTEGER NOT NULL, name TEXT NOT NULL, time TEXT NOT NULL, role TEXT NOT NULL, photo TEXT NOT NULL, phone TEXT NOT NULL, email TEXT NOT NULL, last_msg TEXT NOT NULL, msg_type TEXT NOT NULL )"
        
        static let UserChating = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, to_user_id INTEGER NOT NULL, from_id INTEGER NOT NULL, from_name TEXT NOT NULL, msg TEXT NOT NULL, msg_time TEXT NOT NULL, msgtype INTEGER NOT NULL, photo TEXT NOT NULL, is_download INTEGER NOT NULL )"
        
        static let BuiltAuditSubLocation = "( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, sublocation_id INTEGER NOT NULL, folder_id INTEGER NOT NULL, subfolder_id INTEGER NOT NULL, is_modified INTEGER NOT NULL, sublocation_count INTEGER NOT NULL, work_status INTEGER NOT NULL, sublocation_name TEXT NOT NULL, sublocation_description TEXT NOT NULL, app_version NUMERIC NOT NULL, is_locked INTEGER NOT NULL )"
        
        static let SubLocationSubFolderPhotos = "( inc_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, audit_id INTEGER NOT NULL, location_id INTEGER NOT NULL, folder_id INTEGER NOT NULL, subfolder_id INTEGER NOT NULL, sublocation_id INTEGER NOT NULL, sublocationsubfolder_id INTEGER NOT NULL, location_name TEXT, folder_name TEXT, subfolder_name TEXT, sublocation_name TEXT, sublocationsubfolder_name TEXT, img_name TEXT NOT NULL, main_photo INTEGER NOT NULL, is_sync INTEGER NOT NULL )"
    }
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
            //print("user object nil and initiates")
            self.obSqlite = SqliteDB()
        } else {
            //print("user object not nil")
        }
        return self.obSqlite!
    }
    
    func createDataBaseIfNotExist() {
        let dbPath: String = getPath(fileName: strDBName)
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: dbPath) {
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(strDBName)//folderPath.appendingPathComponent(strDBName)
          
            
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
                //print("error = w\(error.debugDescription)")
            }
        }
    }
    
    private func getDataBasePath() -> String {
        let documentsURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(strDBName)
        //  fileURL.isHidden = true
        // print("fileURL = \(fileURL)")
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
                        //print("Table Already Available \(String(cString: sqlite3_column_text(statement, 0)))")
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
                    //print("error sqlite3_exec: \(errmsg)")
                } else {
                    //print("\(String(describing: strTableName)) Table Created successfuly")
                }
                sqlite3_close(auditAppDB)
            } else { }
        }
    }
    
    private func getPath(fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        //fileURL.isHidden = true
    //   print("fileURL.path =\(fileURL.path)")
        return fileURL.path
    }
    
    private func stepStatementCondition(strMsg: String, statement: OpaquePointer, auditAppDB: OpaquePointer) {
        if sqlite3_step(statement) != SQLITE_DONE {
            //print(strMsg)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("error sqlite3_step: \(errmsg)")
        }
    }
    
    /*
     To check the condition, step statement execution finished or not
     */
    private func finishedExcecution(strMsg: String, statement: OpaquePointer, auditAppDB: OpaquePointer) {
        if sqlite3_step(statement) == SQLITE_DONE {
           // //print(strMsg)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("error sqlite3_step: \(errmsg)")
        }
    }
    
    //MARK: ****************** MyAuditList Table All Operations START Here *****************

    //MARK: --- INSERT Operation
    func insertMyAuditList(obAudit: MyAuditListModel) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.MyAuditList) (user_id, audit_id, audit_title, audit_status, assign_by, target_date, app_version, country_id, lang_name, is_start_sync, is_sync_completed, auditor_link, inspector_link, is_finally_synced, audit_type, total_answers_sync, total_answers_for_sync) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obAudit.audit_id!))
                sqlite3_bind_text(statement, 3, obAudit.audit_title, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 4, Int32(obAudit.audit_status!))
                sqlite3_bind_text(statement, 5, obAudit.assign_by, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 6, obAudit.assignDate!, -1, SQLITE_TRANSIENT)
                sqlite3_bind_double(statement, 7, AppVersion!)
                sqlite3_bind_int(statement, 8, Int32(obAudit.countryId!))
                sqlite3_bind_text(statement, 9, obAudit.language, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 10, Int32(obAudit.isSyncStarted!))
                sqlite3_bind_int(statement, 11, Int32(obAudit.isSyncCompleted!))
                sqlite3_bind_text(statement, 12, obAudit.auditorLink, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 13, obAudit.inspectorLink, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 14, Int32(obAudit.isFinallySynced!))
                sqlite3_bind_int(statement, 15, Int32(obAudit.auditType!))
                sqlite3_bind_int(statement, 16, Int32(obAudit.totalAnswersAreSynced!))
                sqlite3_bind_int(statement, 17, Int32(obAudit.totalAnswersForSync!))
                
                if sqlite3_step(statement) == SQLITE_DONE {
                //    //print("\(DBTables.MyAuditList) Record added successfully")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                //print("\(sqlite3_errmsg(auditAppDB))")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: --- Fetch Audit List (InComplete ,Pending, Complete, All) Operation
    func getAuditList(status: Int, fetchType:String) -> [MyAuditListModel] {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        var arr = [MyAuditListModel]()
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var querySQL = ""
            if fetchType == "byStatus" {
                querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE audit_status = \(status) and user_id = \(UserProfile.id!)"
            } else if fetchType == "pendingComplete" {
                querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE (audit_status = \(AuditStatus.Pending) OR audit_status = \(AuditStatus.Completed)) and user_id = \(UserProfile.id!) and is_sync_completed = 0"
             //   querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE audit_status = \(AuditStatus.Pending) and user_id = \(UserProfile.id!)"
            } else if fetchType == "media" {
                querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE (audit_status = \(AuditStatus.Pending) OR audit_status = \(AuditStatus.Completed)) and user_id = \(UserProfile.id!) "
            } else if fetchType == "all" {
                querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE user_id = \(UserProfile.id!)"
            } else if fetchType == "syncCompleted" {
                //audit_status = \(AuditStatus.Completed) and
                querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE  user_id = \(UserProfile.id!) and is_sync_completed = 1"
            } else if fetchType == "reAudit" {
                querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE audit_status = \(AuditStatus.Completed) and user_id = \(UserProfile.id!) and is_sync_completed = 1"
            } else if fetchType == "notFinallySynced" {
                querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE audit_status = \(AuditStatus.Completed) and user_id = \(UserProfile.id!) and is_finally_synced = 0"
            } else if fetchType == "needFinallySynced" {
                querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE user_id = \(UserProfile.id!) and is_finally_synced = 0 and is_sync_completed = 1"
            } else if fetchType == "notSynced" {
                querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE audit_status = \(AuditStatus.Completed) and user_id = \(UserProfile.id!) and is_sync_completed = 0"
            }
       //     //print("querySQL= \(querySQL)")
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let dict = MyAuditListModel()
                    dict.id =  Int(sqlite3_column_int(statement, 0))
                    dict.audit_id =  Int(sqlite3_column_int(statement, 2))
                    dict.audit_title = String(cString:sqlite3_column_text(statement, 3))
                    dict.audit_status = Int(sqlite3_column_int(statement, 4))
                    dict.assign_by = String(cString:sqlite3_column_text(statement, 5))
                    dict.assignDate = String(cString:sqlite3_column_text(statement, 6))
                    dict.countryId = Int(sqlite3_column_int(statement, 8))
                    dict.language = String(cString:sqlite3_column_text(statement, 9))
                    dict.isSyncStarted = Int(sqlite3_column_int(statement, 10))
                    dict.isSyncCompleted = Int(sqlite3_column_int(statement, 11))
                    dict.auditorLink = String(cString:sqlite3_column_text(statement, 12))
                    dict.inspectorLink = String(cString:sqlite3_column_text(statement, 13))
                    dict.isFinallySynced = Int(sqlite3_column_int(statement, 14))
                    dict.auditType = Int(sqlite3_column_int(statement, 15))
                    dict.totalAnswersAreSynced = Int(sqlite3_column_int(statement, 16))
                    dict.totalAnswersForSync = Int(sqlite3_column_int(statement, 17))
                    arr.append(dict)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.MyAuditList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    /**
     Fetching audit hostory, read only list
     */
  
    
    //MARK: --- Fetch Audit Status in INT Parameter  Operation
    func getAuditStatusInfoWithAuditID(auditId: Int) -> Int {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        var audit_status = 0
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.MyAuditList) WHERE audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    audit_status = Int(sqlite3_column_int(statement, 4))
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.MyAuditList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return audit_status
    }
    
    func deleteSelectedAudit(auditId: Int?) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.MyAuditList) Where audit_id = \(auditId!)"
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted")
                    deleteSelectedAuditQuestions(intAuditId: auditId!)
                    deleteSelectedBuiltAuditLocation(intAuditId: auditId!)
                    deleteSelectedAuditSubLocation(intAuditId: auditId!)                    
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    //MARK: --- Fetch Audit Language & Country Parameter Dictonary Operation
    func getLang_CountryFromAuditList(auditId:Int) -> NSMutableDictionary {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        let dictData = NSMutableDictionary()
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT country_id, lang_name FROM \(DBTables.MyAuditList) WHERE user_id = \(UserProfile.id!) and audit_id = \(auditId)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    dictData.setValue(Int(sqlite3_column_int(statement, 0)), forKey: "countryId")
                    dictData.setValue(String(cString:sqlite3_column_text(statement, 1)), forKey: "language")
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.MyAuditList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return dictData
    }
    
    //MARK: --- UPDATE Audit List Parameters (Audit Status, Is Start Sync, Language & Country)  Operation
    func updateAudit(auditId:Int, updateType:String, auditStatus:Int, countryId:Int, language:String, isSyncCompleted: Int, answersAreSynced: Int, answersForSync: Int) -> Bool {
        
        var flagIsUpdated = false
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var updateSQL = ""
            
            if updateType == "auditStatus" {
                updateSQL = "UPDATE \(DBTables.MyAuditList) set audit_status = ?, is_sync_completed = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            }  else if updateType == "isStartSync" {
                updateSQL = "UPDATE \(DBTables.MyAuditList) set is_start_sync = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            } else if updateType == "lang&Country" {
                updateSQL = "UPDATE \(DBTables.MyAuditList) set country_id = ? , lang_name = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            } else if updateType == "isStartSyncProgress" {
                updateSQL = "UPDATE \(DBTables.MyAuditList) set is_start_sync = ?, total_answers_sync = ?, total_answers_for_sync = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            }
            
            if sqlite3_prepare_v2(auditAppDB, updateSQL, -1, &statement, nil) == SQLITE_OK {
                
                if updateType == "auditStatus" {
                    sqlite3_bind_int(statement, 1, Int32(auditStatus))
                    sqlite3_bind_int(statement, 2, Int32(isSyncCompleted))
                }  else if updateType == "isStartSync" {
                    sqlite3_bind_int(statement, 1, Int32(1))
                } else if updateType == "lang&Country" {
                    sqlite3_bind_int(statement, 1, Int32(countryId))
                    sqlite3_bind_text(statement, 2, language, -1, SQLITE_TRANSIENT)
                } else if updateType == "isStartSyncProgress" {
                    sqlite3_bind_int(statement, 1, Int32(1))
                    sqlite3_bind_int(statement, 2, Int32(answersAreSynced))
                    sqlite3_bind_int(statement, 3, Int32(answersForSync))
                }

                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.MyAuditList) Record updated successfully")
                    flagIsUpdated = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
                flagIsUpdated = false
            }
        }
        return flagIsUpdated
    }
    
    func updateAuditSyncedStatusAndPreview(auditId:Int, updateType:String, isFinallySync:Int, auditorReport: String, inspectorReport: String) {
        var flagIsUpdated = false
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var updateSQL = ""
            
            if updateType == "auditFinalSync" {
               // updateSQL = "UPDATE \(DBTables.MyAuditList) set audit_status = ? and is_finally_synced = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!) "
                updateSQL = "UPDATE \(DBTables.MyAuditList) set is_finally_synced = ? , audit_status = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!) "
            }  else if updateType == "updateReportLink" {
                updateSQL = "UPDATE \(DBTables.MyAuditList) set auditor_link = ?, inspector_link = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            }
            
            //print("updateSQL = \(updateSQL)")
            
            if sqlite3_prepare_v2(auditAppDB, updateSQL, -1, &statement, nil) == SQLITE_OK {
                
                if updateType == "auditFinalSync" {
                   // sqlite3_bind_int(statement, 1, Int32(2))
                    sqlite3_bind_int(statement, 1, Int32(isFinallySync))
                    sqlite3_bind_int(statement, 2, Int32(AuditStatus.Completed))
                }  else if updateType == "updateReportLink" {
                    sqlite3_bind_text(statement, 1, auditorReport, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 2, inspectorReport, -1, SQLITE_TRANSIENT)
                }
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.MyAuditList) Record updated successfully")
                    flagIsUpdated = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
                flagIsUpdated = false
            }
        }
    }
    
    //MARK: ******************************************** MyAuditList Table All Operations FINISH ********************************************
    //MARK: ****************** BuiltAuditLocation Table All Operations START Here *****************
    
    //MARK: --- INSERT Operation
    func insertLocationData(obLocation: LocationModel) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT OR IGNORE INTO \(DBTables.BuiltAuditLocation) (user_id, audit_id, location_id, location_count, location_name, location_description, modified, app_version, is_locked) VALUES (?,?,?,?,?,?,?,?,?)"
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
             //   //print("\(DBTables.BuiltAuditLocation) Record added successfully")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: --- Fetch Build Audit Locations List (All) Operation
    
    func fetchLocationData(auditId: Int) ->  [LocationModel] {
        var arr = [LocationModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.BuiltAuditLocation) WHERE audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            //print("querySQL = \(querySQL)");
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = LocationModel()
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.locationCount = Int(sqlite3_column_int(statement, 4))
                    obMAL.locationName = String(cString:sqlite3_column_text(statement, 5))
                    obMAL.locationDescription = String(cString:sqlite3_column_text(statement, 6))
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.BuiltAuditLocation) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        
        return arr
    }
    
    
    func getLocationList(isModified:Int, auditId: Int) -> [LocationModel] {
        var arr = [LocationModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.BuiltAuditLocation) WHERE modified = \(isModified) and audit_id = \(auditId) and user_id = \(UserProfile.id!) order by location_name ASC"
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
                //print("\(DBTables.BuiltAuditLocation) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    /*
     This functions checks that any audit data saved or not.....if saved then user cannot able to accept another. It returns two values Bool and Int. Bool for check condition and Int will check which audit is downloaded so that there will be no repeatation found.
     */
    func checkAnyBuiltAuditEntryExistOrNot() -> [Any] {
        var isExist = false
        var auditId = Int()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.BuiltAuditLocation) WHERE  user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    auditId = Int(sqlite3_column_int(statement, 2))
                    isExist = true
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.BuiltAuditLocation) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return  [isExist, auditId]
    }
    
    //MARK: --- UPDATE Build Audit Location Parameters (Modified, Location Count)  Operation
    
    func updateBuiltAuditLocation(isModified: Int, count: Int, auditId: Int, locationId: Int, updateType:String) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var updateSQL = ""
            
            if updateType == "modified" {
                updateSQL = "UPDATE \(DBTables.BuiltAuditLocation) set modified = ? Where audit_id = \(auditId) and location_id = \(locationId) and user_id = \(UserProfile.id!)"
            } else if updateType == "count" {
                updateSQL = "UPDATE \(DBTables.BuiltAuditLocation) set location_count = ? Where audit_id = \(auditId) and location_id = \(locationId) and user_id = \(UserProfile.id!)"
            }
            
            if sqlite3_prepare_v2(auditAppDB, updateSQL, -1, &statement, nil) == SQLITE_OK {
                if updateType == "modified" {
                    sqlite3_bind_int(statement, 1, Int32(isModified))
                }  else if updateType == "count" {
                    sqlite3_bind_int(statement, 1, Int32(count))
                }
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.BuiltAuditLocation) Record updated successfully")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
        }
    }
    
    //MARK: --- DELETE All RECORD Build Audit Location Operation
    func deleteAllRecordFromBuiltAuditLocation() {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.BuiltAuditLocation)"
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    func deleteSelectedBuiltAuditLocation(intAuditId: Int) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.BuiltAuditLocation) Where user_id = \(UserProfile.id!) and audit_id = \(intAuditId)"
            //print("insertSQl = \(insertSQL)")
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    func deleteUnModifiedBuiltAuditLocation(intAuditId: Int) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.BuiltAuditLocation) Where user_id = \(UserProfile.id!) and audit_id = \(intAuditId) and modified = 0"
            //print("insertSQl = \(insertSQL)")
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    //MARK: ******************************************** BuiltAuditLocation Table All Operations FINISH ********************************************
    //MARK: ****************** LocationFolder Table All Operations START Here *****************
    
    //MARK: --- INSERT Operation
    func insertLocationFolderData(obFolder: LocationFolderModel) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
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
            //    //print("\(DBTables.LocationFolder) Record added successfully")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: --- FETCH Operation
    func getLocationFolderList(locationId:Int, auditId:Int) -> [LocationFolderModel] {
        var arr = [LocationFolderModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
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
                //print("\(DBTables.LocationFolder) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    func getLocationFolderName(locationId:Int, auditId:Int, folderId:Int) -> String {
        var strFolderName = ""
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT folder_name FROM \(DBTables.LocationFolder) WHERE location_id = \(locationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!) and id = \(folderId)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    strFolderName = String(cString:sqlite3_column_text(statement, 0))
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.LocationFolder) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return strFolderName
    }
    
    //MARK: --- UPDATE (folder count, folder name) Operation

    func updateLocationFolder(incId: Int, folderCount: Int, folderTitle:String, updateType:String) -> Bool {
        var flagIsUpdated = false
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var updateSQL = ""
            if updateType == "count" {
                updateSQL = "UPDATE \(DBTables.LocationFolder) set folder_count = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            } else if updateType == "name_count" {
                updateSQL = "UPDATE \(DBTables.LocationFolder) set folder_count = ? , folder_name = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            }
            
            if sqlite3_prepare_v2(auditAppDB, updateSQL, -1, &statement, nil) == SQLITE_OK {
                if updateType == "count" {
                    sqlite3_bind_int(statement, 1, Int32(folderCount))
                } else if updateType == "name_count" {
                    sqlite3_bind_int(statement, 1, Int32(folderCount))
                    sqlite3_bind_text(statement, 2, folderTitle, -1, SQLITE_TRANSIENT)
                }
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.LocationFolder) Record updated successfully")
                    flagIsUpdated = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("\(DBTables.LocationFolder) error sqlite3_step: \(errmsg)")
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
                flagIsUpdated = false
            }
        }
        return flagIsUpdated
    }
    
    //MARK: --- DELETE (Location Id, All) Operation
    func deleteLocationFolder(auditId:Int, locationId:Int, deleteType:String) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var deleteSQL = ""
            if deleteType == "location" {
                deleteSQL = "DELETE FROM \(DBTables.LocationFolder) WHERE location_id = \(locationId) and audit_id = \(auditId)"
            } else if deleteType == "all" {
                deleteSQL = "DELETE FROM \(DBTables.LocationFolder)"
            }
            
            if sqlite3_prepare_v2(auditAppDB, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("LocationFolder Record Deleted")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }

    //MARK: ******************************************** LocationFolder Table All Operations FINISH ********************************************
    //MARK: ****************** LocationSubFolderList Table All Operations START Here *****************

    //MARK: --- INSERT Operation
    func insertLocationSubFolderListData(obFolder: LocationSubFolderListModel) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.LocationSubFolderList) (user_id, audit_id, location_id, folder_id, is_archive, sub_folder_name, sub_folder_description, photo, is_sync) VALUES (?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obFolder.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obFolder.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obFolder.folderId!))
                sqlite3_bind_int(statement, 5, Int32(obFolder.is_archive!))
                sqlite3_bind_text(statement, 6, obFolder.subFolderName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 7, obFolder.subFolderDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 8, "", -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 9, Int32(obFolder.isSync!))
            }
            if sqlite3_step(statement) == SQLITE_DONE {
             //   //print("\(DBTables.LocationSubFolderList) Record added successfully")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
    }

    //MARK: --- FETCH Operation
    func getLocationSubFolderList(locationId:Int, auditId:Int, folderId:Int) -> [LocationSubFolderListModel] {
        var arr = [LocationSubFolderListModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
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
                    if sqlite3_column_text(statement, 8) != nil {
                        obMAL.photo = String(cString:sqlite3_column_text(statement, 8))
                    } else {
                        obMAL.photo = ""
                    }
                    obMAL.arrSubLocationCounter = getBuiltAuditSubLocationList(auditId: auditId, locationId: locationId, folderId: folderId, subFolderId: obMAL.incId!)
                    obMAL.isSync = Int(sqlite3_column_int(statement, 9))
                    arr.append(obMAL)
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.LocationSubFolderList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    /**
     This functions gets the list of media files with name from this model
     */
    func getLocationSubFolderPhotos(auditId: Int, locationId:Int) -> [LocationSubFolderListModel] {
        var arr = [LocationSubFolderListModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.LocationSubFolderList) WHERE user_id = \(UserProfile.id!) and audit_id = \(auditId) and location_id = \(locationId)"
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
                    if sqlite3_column_text(statement, 8) != nil {
                        obMAL.photo = String(cString:sqlite3_column_text(statement, 8))
                    } else {
                        obMAL.photo = ""
                    }
                //    obMAL.arrSubLocationCounter = getBuiltAuditSubLocationList(auditId: auditId, locationId: locationId, folderId: folderId, subFolderId: obMAL.incId!)
                    obMAL.isSync = Int(sqlite3_column_int(statement, 9))
                    arr.append(obMAL)
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.LocationSubFolderList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    func getLocationSubFolderInfo(locationId:Int, auditId:Int, folderId:Int, subFolderId:Int) -> NSMutableDictionary {
        let dictData = NSMutableDictionary()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT sub_folder_name, sub_folder_description, photo , id , is_sync FROM \(DBTables.LocationSubFolderList) WHERE location_id = \(locationId) and audit_id = \(auditId) and folder_id = \(folderId) and user_id = \(UserProfile.id!) and id = \(subFolderId)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    dictData.setValue(String(cString:sqlite3_column_text(statement, 0)), forKey: "folderName")
                    dictData.setValue(String(cString:sqlite3_column_text(statement, 1)), forKey: "folderDesc")
                    dictData.setValue(String(cString:sqlite3_column_text(statement, 2)), forKey: "photo")
                    dictData.setValue(Int(sqlite3_column_int(statement, 3)), forKey: "id")
                    dictData.setValue(Int(sqlite3_column_int(statement, 4)), forKey: "is_sync")
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.LocationSubFolderList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return dictData
    }
    
    //MARK: --- UPDATE (isArchive, Photo, isSync, Title, Description) Operation
    
    func resetAuditLocationSubFolders(auditId: Int) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.LocationSubFolderList) set is_sync = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(0))
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.LocationSubFolderList) Record updated successfully")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
        }
    }
    
    func updateLocationSubFolder(incId: Int, isArchive: Int, base64Str:String, subfolderTitle:String, subfolderDescription:String, updateType:String) {

        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var updateSQL = ""
            if updateType == "isArchive" {
                updateSQL = "UPDATE \(DBTables.LocationSubFolderList) set is_archive = ?  Where id = \(incId) and user_id = \(UserProfile.id!)"
            } else if updateType == "photo" {
                updateSQL = "UPDATE \(DBTables.LocationSubFolderList) set photo = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            } else if updateType == "isSync" {
                updateSQL = "UPDATE \(DBTables.LocationSubFolderList) set is_sync = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            } else if updateType == "titleDesc" {
                updateSQL = "UPDATE \(DBTables.LocationSubFolderList) set sub_folder_name = ? , sub_folder_description = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            }
            
            if sqlite3_prepare_v2(auditAppDB, updateSQL, -1, &statement, nil) == SQLITE_OK {
                
                if updateType == "isArchive" {
                    sqlite3_bind_int(statement, 1, Int32(isArchive))
                } else if updateType == "photo" {
                    sqlite3_bind_text(statement, 1, base64Str, -1, SQLITE_TRANSIENT)
                } else if updateType == "isSync" {
                    sqlite3_bind_int(statement, 1, Int32(1))
                } else if updateType == "titleDesc" {
                    sqlite3_bind_text(statement, 1, subfolderTitle, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 2, subfolderDescription, -1, SQLITE_TRANSIENT)
                }
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.LocationSubFolderList) Record updated successfully")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("\(DBTables.LocationSubFolderList) error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
        }
    }

    //MARK: --- DELETE (LocationId, FolderId, IncId, All) Operation
    func deleteLocationSubFolder(auditId:Int, locationId:Int, incId: Int, folderId:Int, deleteType:String) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var deleteSQL = ""
            if deleteType == "location" {
                deleteSQL = "DELETE FROM \(DBTables.LocationSubFolderList) WHERE location_id = \(locationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            } else if deleteType == "incId" {
                deleteSQL = "DELETE FROM \(DBTables.LocationSubFolderList) WHERE id = \(incId)"
            } else if deleteType == "folderId" {
                deleteSQL = "DELETE FROM \(DBTables.LocationSubFolderList) WHERE location_id = \(locationId) and audit_id = \(auditId) and folder_id = \(folderId)"
            } else if deleteType == "all" {
                deleteSQL = "DELETE FROM \(DBTables.LocationSubFolderList)"
            }
            
            if sqlite3_prepare_v2(auditAppDB, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted from \(DBTables.LocationSubFolderList)")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    //MARK: ******************************************** LocationSubFolderList Table All Operations FINISH ********************************************
    //MARK: ****************** SubLocation Table All Operations START Here *****************

    //MARK: --- INSERT Operation
    func insertSubLocationData(obSubLoc: SubLocationModel) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.SubLocation) (user_id, audit_id, location_id, location_ids, sublocation_id, work_status, sublocation_count, sublocation_name, sublocation_description, modified, app_version) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obSubLoc.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obSubLoc.locationId!))
                sqlite3_bind_text(statement, 4, obSubLoc.strLocationId, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 5, Int32(obSubLoc.subLocationId!))
                sqlite3_bind_int(statement, 6, Int32(obSubLoc.work_status!))
                sqlite3_bind_int(statement, 7, Int32(obSubLoc.subLocationCount!))
                sqlite3_bind_text(statement, 8, obSubLoc.subLocationName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 9, obSubLoc.subLocationDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 10, Int32(obSubLoc.isModified!))
                sqlite3_bind_double(statement, 11, AppVersion!)
            }
            if sqlite3_step(statement) == SQLITE_DONE {
              //  //print("\(DBTables.SubLocation) Record added successfully")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: --- FETCH Operation

    /**
     This will call the sub location list that saved during questionaaries and modules time and this will be used for read only purpose
     */
    func getDefaultSubLocationList(auditId: Int, locationId: Int) -> [SubLocationModel] {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        var arr = [SubLocationModel]()
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            /// New Query
            let querySQL = "SELECT * FROM \(DBTables.SubLocation) WHERE audit_id = \(auditId) and user_id = \(UserProfile.id!) and location_ids like '%\(locationId)%' order by sublocation_name ASC"
         ///Old query///   let querySQL = "SELECT * FROM \(DBTables.SubLocation) WHERE audit_id = \(auditId) and location_id = \(locationId)  and user_id = \(UserProfile.id!)"
            
         //   //print("querySQL = \(querySQL)")
            
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = SubLocationModel()
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = locationId//Int(sqlite3_column_int(statement, 3))
                    obMAL.subLocationId = Int(sqlite3_column_int(statement, 5))
                    obMAL.subLocationCount = Int(sqlite3_column_int(statement, 7))
                    obMAL.subLocationName = String(cString:sqlite3_column_text(statement, 8))
                    obMAL.subLocationDescription = String(cString:sqlite3_column_text(statement, 9))
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.SubLocation) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    func getSubLocationDataFor(auditId: Int) -> [SubLocationModel] {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        var arr = [SubLocationModel]()
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            /// New Query
            let querySQL = "SELECT * FROM \(DBTables.SubLocation) WHERE audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            ///Old query///   let querySQL = "SELECT * FROM \(DBTables.SubLocation) WHERE audit_id = \(auditId) and location_id = \(locationId)  and user_id = \(UserProfile.id!)"
            
            //   //print("querySQL = \(querySQL)")
            
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = SubLocationModel()
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.subLocationId = Int(sqlite3_column_int(statement, 5))
                    obMAL.subLocationCount = Int(sqlite3_column_int(statement, 7))
                    obMAL.subLocationName = String(cString:sqlite3_column_text(statement, 8))
                    obMAL.subLocationDescription = String(cString:sqlite3_column_text(statement, 9))
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.SubLocation) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    
    //MARK: --- DELETE All Data Operation
    func deleteAllRecordFromSubLocation() {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.SubLocation)"
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                //sqlite3_step(statement)
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
   
    func deleteSelectedAuditSubLocation(intAuditId: Int) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var insertSQL = ""
            insertSQL = "DELETE FROM \(DBTables.SubLocation) Where user_id = \(UserProfile.id!) and audit_id = \(intAuditId)"
            let insert_stmt = insertSQL
            if sqlite3_prepare_v2(auditAppDB, insert_stmt, -1, &statement, nil) == SQLITE_OK {
                //sqlite3_step(statement)
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    //MARK: ******************************************** SubLocation Table All Operations FINISH ********************************************
    //MARK: ****************** BuiltAuditSubLocation Table All Operations START Here *****************
    
    //MARK: --- INSERT Operation
    func insertBuiltAuditSubLocationData(obBASL: BuiltAuditSubLocationModel) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.BuiltAuditSubLocation) (user_id, audit_id, location_id, sublocation_id, folder_id, subfolder_id, is_modified, sublocation_count, work_status, sublocation_name, sublocation_description, app_version, is_locked) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)"
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
                sqlite3_bind_int(statement, 13, Int32(obBASL.isLocked!))
            }
            self.finishedExcecution(strMsg: "\(DBTables.BuiltAuditSubLocation) recored added", statement: statement!, auditAppDB: auditAppDB!)
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: --- FETCH Operation
    func getBuiltAuditSubLocationList(auditId: Int, locationId: Int, folderId: Int, subFolderId: Int) -> [BuiltAuditSubLocationModel] {
        var arr = [BuiltAuditSubLocationModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT * FROM \(DBTables.BuiltAuditSubLocation) WHERE audit_id = \(auditId) and user_id = \(UserProfile.id!) and location_id = \(locationId) and folder_id = \(folderId) and subfolder_id = \(subFolderId) order by sublocation_name ASC"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obSL = BuiltAuditSubLocationModel()
                    obSL.incId = Int(sqlite3_column_int(statement, 0))
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
                    obSL.arrFolders = self.getSubLocationSubFolderList(auditId: auditId, locationId: locationId, folderId: folderId, sub_locationId: obSL.subLocationId!, subFolderId: obSL.subFolderId!)
                    arr.append(obSL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.BuiltAuditSubLocation) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    //MARK: --- UPDATE (sublocation_count, work_status) Operation
    func updateBuiltAuditSubLocation(incId: Int, auditId:Int, locationId: Int, folderId: Int, subFolderId: Int, subLocationId: Int, subLocationCount: Int, workStatus: Int, updateType: String) -> Bool {
        
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        var flagIsUpdated = false
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var updateSQL = ""
            if updateType == "count" {
                updateSQL = "UPDATE \(DBTables.BuiltAuditSubLocation) set sublocation_count = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            } else if updateType == "workstatus" {
                updateSQL = "UPDATE \(DBTables.BuiltAuditSubLocation) set work_status = ? Where audit_id = \(auditId) and location_id = \(locationId) and folder_id = \(folderId) and subfolder_id = \(subFolderId) and sublocation_id = \(subLocationId) and user_id = \(UserProfile.id!) "
            }
            
            if sqlite3_prepare_v2(auditAppDB, updateSQL, -1, &statement, nil) == SQLITE_OK {
                
                if updateType == "count" {
                    sqlite3_bind_int(statement, 1, Int32(subLocationCount))
                } else if updateType == "workstatus" {
                    sqlite3_bind_int(statement, 1, Int32(workStatus))
                }
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.BuiltAuditSubLocation) Record updated successfully")
                    flagIsUpdated = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("\(DBTables.BuiltAuditSubLocation) error sqlite3_step: \(errmsg)")
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
                flagIsUpdated = false
            }
        } // end of open
        return flagIsUpdated
    }
    
    //MARK: --- DELETE Operation
    func deleteBuiltAuditSubLocation(auditId: Int, locationId: Int, folderId: Int, subFolderId: Int, sublocationId: Int, deleteType:String) {

        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var deleteSQL = ""
            if deleteType == "subFolder" {
                deleteSQL = "DELETE FROM \(DBTables.BuiltAuditSubLocation) WHERE location_id = \(locationId) and sublocation_id = \(sublocationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!) and folder_id = \(folderId) and subfolder_id = \(subFolderId)"
            } else if deleteType == "location" {
                deleteSQL = "DELETE FROM \(DBTables.BuiltAuditSubLocation) WHERE audit_id = \(auditId) and location_id = \(locationId) and user_id = \(UserProfile.id!)"
            } else if deleteType == "all" {
                deleteSQL = "DELETE FROM \(DBTables.BuiltAuditSubLocation)"
            }
            
            if sqlite3_prepare_v2(auditAppDB, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted from \(DBTables.BuiltAuditSubLocation)")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    //MARK: ******************************************** BuiltAuditSubLocation Table All Operations FINISH ********************************************
    //MARK: ****************** SubLocationSubFolderList Table All Operations START Here *****************

    //MARK: --- INSERT Operation
    func insertintoSubLocationSubFolderList(oblist: SubLocationSubFolderModel) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.SubLocationSubFolderList) (user_id, audit_id, location_id, sublocation_id, folder_id, subfolder_id, is_archive, work_status, is_locked, subfolder_name, subfolder_description) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(oblist.auditId!))
                sqlite3_bind_int(statement, 3, Int32(oblist.locationId!))
                sqlite3_bind_int(statement, 4, Int32(oblist.subLocationId!))
                sqlite3_bind_int(statement, 5, Int32(oblist.folderId!))
                sqlite3_bind_int(statement, 6, Int32(oblist.subFolderId!))
                sqlite3_bind_int(statement, 7, Int32(oblist.isArchive!))
                sqlite3_bind_int(statement, 8, Int32(oblist.workStatus!))
                sqlite3_bind_int(statement, 9, Int32(oblist.isLocked!))
                sqlite3_bind_text(statement, 10, oblist.subFolderName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 11, oblist.subFolderDescription, -1, SQLITE_TRANSIENT)
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                ////print("\(DBTables.SubLocationSubFolderList) Record added successfully")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: --- FETCH Operation
    func getSubLocationSubFolderList(auditId:Int, locationId:Int, folderId:Int, sub_locationId:Int, subFolderId: Int) -> [SubLocationSubFolderModel] {
        var arr = [SubLocationSubFolderModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            
            let querySQL = "SELECT * FROM \(DBTables.SubLocationSubFolderList) WHERE audit_id = \(auditId) and location_id = \(locationId) and folder_id = \(folderId) and sublocation_id = \(sub_locationId) and user_id = \(UserProfile.id!) and subfolder_id = \(subFolderId)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = SubLocationSubFolderModel()
                    obMAL.incId = Int(sqlite3_column_int(statement, 0))
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.subLocationId = Int(sqlite3_column_int(statement, 4))
                    obMAL.folderId = Int(sqlite3_column_int(statement, 5))
                    obMAL.subFolderId = Int(sqlite3_column_int(statement, 6))
                    obMAL.isArchive = Int(sqlite3_column_int(statement, 7))
                    obMAL.workStatus = Int(sqlite3_column_int(statement, 8))
                    obMAL.isLocked = Int(sqlite3_column_int(statement, 9))
                    obMAL.subFolderName = String(cString:sqlite3_column_text(statement, 10))
                    obMAL.subFolderDescription = String(cString:sqlite3_column_text(statement, 11))
                    obMAL.answeredCount = self.getAuditAnswersCounts(auditId: auditId, locationId: locationId, folderId: folderId, subfolderId: obMAL.subFolderId!, sub_locationId: sub_locationId, sub_locationsub_folderId: obMAL.incId!, parentId: 0, fetchType: "count")
                    obMAL.totalCount = self.getAuditAnswersCounts(auditId: auditId, locationId: locationId, folderId: folderId, subfolderId: obMAL.subFolderId!, sub_locationId: sub_locationId, sub_locationsub_folderId: obMAL.incId!, parentId: 0, fetchType: "totalcount")
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.SubLocationSubFolderList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    func getSubLocationSubFolderInfo(auditId:Int, locationId:Int, folderId:Int, sub_locationId:Int, sublocation_subfolderId:Int) -> NSMutableDictionary {
        let dictData = NSMutableDictionary()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            
            let querySQL = "SELECT subfolder_name, subfolder_description FROM \(DBTables.SubLocationSubFolderList) WHERE audit_id = \(auditId) and location_id = \(locationId) and folder_id = \(folderId) and sublocation_id = \(sub_locationId) and user_id = \(UserProfile.id!) and inc_id = \(sublocation_subfolderId)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    dictData.setValue(String(cString:sqlite3_column_text(statement, 0)), forKey: "Name")
                    dictData.setValue(String(cString:sqlite3_column_text(statement, 1)), forKey: "Desc")
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.SubLocationSubFolderList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return dictData
    }
    
    //MARK: --- UPDATE (isArchive, Title, Description) Operation
    func updateSubLocationSubFolder(incId: Int, isArchive: Int, subFolderTitle:String, subFolderDescription:String, updateType:String) -> Bool {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        var flagIsUpdated = false

        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var updateSQL = ""
            if updateType == "isArchive" {
                updateSQL = "UPDATE \(DBTables.SubLocationSubFolderList) set isArchive = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            } else if updateType == "titleDesc" {
               updateSQL = "UPDATE \(DBTables.SubLocationSubFolderList) set subfolder_name = ? , subfolder_description = ? Where inc_id = \(incId) and user_id = \(UserProfile.id!)"
            }
            
            if sqlite3_prepare_v2(auditAppDB, updateSQL, -1, &statement, nil) == SQLITE_OK {
                if updateType == "isArchive" {
                    sqlite3_bind_int(statement, 1, Int32(isArchive))
                } else if updateType == "titleDesc" {
                    sqlite3_bind_text(statement, 1, subFolderTitle, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 2, subFolderDescription, -1, SQLITE_TRANSIENT)
                }
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.SubLocationSubFolderList) Record updated successfully")
                    flagIsUpdated = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("\(DBTables.SubLocationSubFolderList) error sqlite3_step: \(errmsg)")
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
                flagIsUpdated = false
            }
        } // end of open
        return flagIsUpdated
    }
    
    //MARK: --- DELETE  Operation
    
    func deleteSubLocationSubFolder(incId: Int, auditId:Int, locationId:Int, folderId:Int, subFolderId: Int, sub_locationId:Int, deleteType:String) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var deleteSQL = ""
            if deleteType == "subLocation" {
                deleteSQL = "DELETE FROM \(DBTables.SubLocationSubFolderList) WHERE location_id = \(locationId) and audit_id = \(auditId) and folder_id = \(folderId) and sublocation_id = \(sub_locationId) and subfolder_id = \(subFolderId)"
            } else if deleteType == "location" {
                deleteSQL = "DELETE FROM \(DBTables.SubLocationSubFolderList) WHERE location_id = \(locationId) and audit_id = \(auditId)"
            } else if deleteType == "incId" {
                deleteSQL = "DELETE FROM \(DBTables.SubLocationSubFolderList) WHERE inc_id = \(incId)"
            } else if deleteType == "all" {
                deleteSQL = "DELETE FROM \(DBTables.SubLocationSubFolderList)"
            }
            
            if sqlite3_prepare_v2(auditAppDB, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
 
    //MARK: ******************************************** SubLocationSubFolderList Table All Operations FINISH ********************************************
    //MARK: ****************** AuditQuestions Table All Operations START Here *****************

    //MARK: INSERT Operation
    func insertQuestionsData(obQuestion: QuestionsModel) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        //print("obQuestion = \(obQuestion.question)")
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.AuditQuestions) (user_id, audit_id, location_id, location_ids, sublocation_id,  question_id, question_type, category_type, priority, has_subquestion, is_subquestion, parent_question_id, subquestion_answer_id, question, answers, answers_id, is_superuser_audit) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obQuestion.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obQuestion.locationId!))
                sqlite3_bind_text(statement, 4, obQuestion.locationIds, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 5, Int32(obQuestion.subLocationId!))
                sqlite3_bind_int(statement, 6, Int32(obQuestion.questionId!))
                sqlite3_bind_int(statement, 7, Int32(obQuestion.questionType!))
                sqlite3_bind_int(statement, 8, Int32(obQuestion.categoryType!))
                sqlite3_bind_int(statement,9, Int32(obQuestion.priority!))
                sqlite3_bind_int(statement, 10, Int32(obQuestion.hasSubQuestion!))
                sqlite3_bind_int(statement, 11, Int32(obQuestion.isSubQuestion!))
                sqlite3_bind_int(statement, 12, Int32(obQuestion.parentQuestionId!))
                sqlite3_bind_int(statement, 13, Int32(obQuestion.selectedAnswerIdForSubQuestion!))
                sqlite3_bind_text(statement, 14, obQuestion.question, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 15, obQuestion.answers, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 16, obQuestion.answerId, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 17, Int32(obQuestion.isSuperUserAudit!))
            }
            self.finishedExcecution(strMsg: "\(DBTables.AuditQuestions) recored added", statement: statement!, auditAppDB: auditAppDB!)
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: FETCH Operation
    
    func getQuestionsCountForSubLocation(locationId:Int, subLocationId: Int, auditId:Int) -> Int {
        
        var intCount = Int()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT count(*) FROM \(DBTables.AuditQuestions) WHERE  sublocation_id = \(subLocationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
       //     //print("querySQL = \(querySQL)")
            
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    intCount = Int(sqlite3_column_int(statement, 0))
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.AuditQuestions) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        
        return intCount
    }
    
    func getQuestionList(locationId:Int, subLocationId: Int, auditId:Int) -> [QuestionsModel] {
        var arr = [QuestionsModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
         //   let querySQL = "SELECT * FROM \(DBTables.AuditQuestions) WHERE  sublocation_id = \(subLocationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!) and location_ids like '%\(locationId)%'"
             let querySQL = "SELECT * FROM \(DBTables.AuditQuestions) WHERE  sublocation_id = \(subLocationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
             //print("querySQL = \(querySQL)")
            
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = QuestionsModel()
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = locationId//Int(sqlite3_column_int(statement, 3))
                    obMAL.locationIds = String(cString:sqlite3_column_text(statement, 4))
                    obMAL.subLocationId = Int(sqlite3_column_int(statement, 5))
                    obMAL.questionId = Int(sqlite3_column_int(statement, 6))
                    obMAL.questionType = Int(sqlite3_column_int(statement, 7))
                    obMAL.categoryType = Int(sqlite3_column_int(statement, 8))
                    obMAL.priority = Int(sqlite3_column_int(statement, 9))
                    obMAL.hasSubQuestion = Int(sqlite3_column_int(statement, 10))
                    obMAL.isSubQuestion = Int(sqlite3_column_int(statement, 11))
                    obMAL.parentQuestionId = Int(sqlite3_column_int(statement, 12))
                    obMAL.selectedAnswerIdForSubQuestion = Int(sqlite3_column_int(statement, 13))
                    obMAL.question = String(cString:sqlite3_column_text(statement, 14))
                    obMAL.answers = String(cString:sqlite3_column_text(statement, 15))
                    obMAL.answerId = String(cString:sqlite3_column_text(statement, 16))
                    obMAL.isSuperUserAudit = Int(sqlite3_column_int(statement, 17))
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.AuditQuestions) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    func getQuestionData(auditId:Int) -> [QuestionsModel] {
        var arr = [QuestionsModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            //   let querySQL = "SELECT * FROM \(DBTables.AuditQuestions) WHERE  sublocation_id = \(subLocationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!) and location_ids like '%\(locationId)%'"
            let querySQL = "SELECT * FROM \(DBTables.AuditQuestions) WHERE  audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            //print("querySQL = \(querySQL)")
            
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = QuestionsModel()
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.locationIds = String(cString:sqlite3_column_text(statement, 4))
                    obMAL.subLocationId = Int(sqlite3_column_int(statement, 5))
                    obMAL.questionId = Int(sqlite3_column_int(statement, 6))
                    obMAL.questionType = Int(sqlite3_column_int(statement, 7))
                    obMAL.categoryType = Int(sqlite3_column_int(statement, 8))
                    obMAL.priority = Int(sqlite3_column_int(statement, 9))
                    obMAL.hasSubQuestion = Int(sqlite3_column_int(statement, 10))
                    obMAL.isSubQuestion = Int(sqlite3_column_int(statement, 11))
                    obMAL.parentQuestionId = Int(sqlite3_column_int(statement, 12))
                    obMAL.selectedAnswerIdForSubQuestion = Int(sqlite3_column_int(statement, 13))
                    obMAL.question = String(cString:sqlite3_column_text(statement, 14))
                    obMAL.answers = String(cString:sqlite3_column_text(statement, 15))
                    obMAL.answerId = String(cString:sqlite3_column_text(statement, 16))
                    obMAL.isSuperUserAudit = Int(sqlite3_column_int(statement, 17))
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.AuditQuestions) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    
    //MARK: DELETE Operation
    func deleteAllRecordFromAuditQuestions() {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        let dbpath = getDataBasePath()
        
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            let deleteSQL = "DELETE FROM \(DBTables.AuditQuestions)"
            if sqlite3_prepare_v2(auditAppDB, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    func deleteSelectedAuditQuestions(intAuditId: Int) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        let dbpath = getDataBasePath()
        
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            let deleteSQL = "DELETE FROM \(DBTables.AuditQuestions) Where user_id = \(UserProfile.id!) and audit_id = \(intAuditId)"
            if sqlite3_prepare_v2(auditAppDB, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("Record Deleted")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    
    //MARK: ******************************************** AuditQuestions Table All Operations FINISH ********************************************
    //MARK: ****************** AuditAnswers Table All Operations START Here *****************

    //MARK: INSERT Operation
    func insertAnswersData(obAns: AuditAnswerModel) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.AuditAnswers) (user_id, audit_id, location_id, sub_location_id, folder_id, question_id, answer_id, question_type, category_type, priority, is_update, sublocation_subfolder_id, subfolder_id, question, answer, description, img_data, saved_answer, saved_answer_id, has_subquestion, is_subquestion, parent_question_id, subquestion_answer_id, is_sync, is_superuser_audit ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(obAns.auditId!))
                sqlite3_bind_int(statement, 3, Int32(obAns.locationId!))
                sqlite3_bind_int(statement, 4, Int32(obAns.subLocationId!))
                sqlite3_bind_int(statement, 5, Int32(obAns.folderId!))
                sqlite3_bind_int(statement, 6, Int32(obAns.questionId!))
                sqlite3_bind_text(statement, 7, obAns.answerId, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 8, Int32(obAns.questionType!))
                sqlite3_bind_int(statement, 9, Int32(obAns.categoryType!))
                sqlite3_bind_int(statement, 10, Int32(obAns.priority!))
                sqlite3_bind_int(statement, 11, Int32(obAns.isUpdate!))
                sqlite3_bind_int(statement, 12, Int32(obAns.sublocation_subfolder_id!))
                sqlite3_bind_int(statement, 13, Int32(obAns.subfolder_id!))
                sqlite3_bind_text(statement, 14, obAns.question, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 15, obAns.answers, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 16, obAns.answerDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 17, obAns.imgName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 18, obAns.savedAnswer, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 19, obAns.savedAnswer_id, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 20, Int32(obAns.hasSubQuestion!))
                sqlite3_bind_int(statement, 21, Int32(obAns.isSubQuestion!))
                sqlite3_bind_int(statement, 22, Int32(obAns.parentQuestionId!))
                sqlite3_bind_int(statement, 23, Int32(obAns.selectedAnswerIdForSubQuestion!))
                sqlite3_bind_int(statement, 24, Int32(obAns.isSync!))
                sqlite3_bind_int(statement, 25, Int32(obAns.isSuperUserAudit!))
            }
            if sqlite3_step(statement) == SQLITE_DONE {
               // //print("\(DBTables.AuditAnswers) Record added successfully")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: FETCH Operation
    func getAuditAnswers(auditId:Int, locationId:Int, folderId:Int, subfolderId:Int, sub_locationId:Int, sub_locationsub_folderId:Int, parentQueId:Int, selectedAnsId:Int, fetchType:String) -> [AuditAnswerModel] {
        var arr = [AuditAnswerModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var fetchSQL = ""
            if fetchType == "mainQue" {
                fetchSQL = "SELECT * FROM \(DBTables.AuditAnswers) WHERE audit_id = \(auditId) and location_id = \(locationId) and folder_id = \(folderId) and subfolder_id = \(subfolderId) and sub_location_id = \(sub_locationId) and sublocation_subfolder_id = \(sub_locationsub_folderId) and parent_question_id = \(parentQueId) and user_id = \(UserProfile.id!)"
            }  else if fetchType == "subQue" {
                fetchSQL = "SELECT * FROM \(DBTables.AuditAnswers) WHERE location_id = \(locationId) and sub_location_id = \(sub_locationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!) and parent_question_id = \(parentQueId) and subquestion_answer_id = \(selectedAnsId) and folder_id = \(folderId) and sublocation_subfolder_id = \(sub_locationsub_folderId)"
            } else if fetchType == "resetwithParentQueId" {
                fetchSQL = "SELECT * FROM \(DBTables.AuditAnswers) WHERE location_id = \(locationId) and sub_location_id = \(sub_locationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!) and parent_question_id = \(parentQueId)  and folder_id = \(folderId) and sublocation_subfolder_id = \(sub_locationsub_folderId)"
            } else if fetchType == "updateSync" {
                fetchSQL = "Select * from \(DBTables.AuditAnswers) where is_update = 1 and is_sync = 0 and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            } else if fetchType == "superAudit" {
                fetchSQL = "SELECT * FROM \(DBTables.AuditAnswers) WHERE audit_id = \(auditId) and location_id = \(locationId) and folder_id = \(folderId) and subfolder_id = \(subfolderId) and sub_location_id = \(sub_locationId) and sublocation_subfolder_id = \(sub_locationsub_folderId) and parent_question_id > \(parentQueId) and user_id = \(UserProfile.id!) and is_superuser_audit = 1"
            } else if fetchType == "totalAnswersForSync" {
                //fetchSQL = "Select * from \(DBTables.AuditAnswers) where is_update = 1 and is_sync = 0 and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
                fetchSQL = "Select * from \(DBTables.AuditAnswers) where is_update = 1 and (is_sync = 0 or is_sync = 1)  and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            } else if fetchType == "totalAnswersAreSync" {
                fetchSQL = "Select * from \(DBTables.AuditAnswers) where is_update = 1 and is_sync = 1 and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            }
            
          //print("fetch Answer data = \(fetchSQL)")
            
            if sqlite3_prepare_v2(auditAppDB, fetchSQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = AuditAnswerModel()
                    obMAL.incId = Int(sqlite3_column_int(statement, 0))
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.subLocationId = Int(sqlite3_column_int(statement, 4))
                    obMAL.folderId = Int(sqlite3_column_int(statement, 5))
                    obMAL.questionId = Int(sqlite3_column_int(statement, 6))
                    obMAL.answerId = String(cString:sqlite3_column_text(statement, 7))
                    obMAL.questionType = Int(sqlite3_column_int(statement, 8))
                    obMAL.categoryType = Int(sqlite3_column_int(statement, 9))
                    obMAL.priority = Int(sqlite3_column_int(statement, 10))
                    obMAL.isUpdate = Int(sqlite3_column_int(statement, 11))
                    obMAL.sublocation_subfolder_id = Int(sqlite3_column_int(statement, 12))
                    obMAL.subfolder_id = Int(sqlite3_column_int(statement, 13))
                    obMAL.question = String(cString:sqlite3_column_text(statement, 14))
                    obMAL.answers = String(cString:sqlite3_column_text(statement, 15))
                    obMAL.answerDescription = String(cString:sqlite3_column_text(statement, 16))
                    obMAL.imgName = String(cString:sqlite3_column_text(statement, 17))
                    obMAL.savedAnswer = String(cString:sqlite3_column_text(statement, 18))
                    obMAL.savedAnswer_id = String(cString:sqlite3_column_text(statement, 19))
                    obMAL.hasSubQuestion = Int(sqlite3_column_int(statement, 20))
                    obMAL.isSubQuestion = Int(sqlite3_column_int(statement, 21))
                    obMAL.parentQuestionId = Int(sqlite3_column_int(statement, 22))
                    obMAL.selectedAnswerIdForSubQuestion = Int(sqlite3_column_int(statement, 23))
                    obMAL.isSync = Int(sqlite3_column_int(statement, 24))
                    obMAL.isSuperUserAudit = Int(sqlite3_column_int(statement, 25))
                    
                    if fetchType == "mainQue" {
                        obMAL.arrSubAnswers = self.getSubAnswersDataWith(auditId: auditId, locationId: locationId, folderId: folderId, subfolderId: subfolderId, sub_locationId: sub_locationId, sub_locationsub_folderId: sub_locationsub_folderId, parentQuestionId: obMAL.parentQuestionId!)
                    }
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.AuditAnswers) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    // SubQuestion
    func getSubAnswersDataWith(auditId:Int, locationId:Int, folderId:Int, subfolderId:Int, sub_locationId:Int, sub_locationsub_folderId:Int, parentQuestionId: Int) -> [AuditAnswerModel] {
        var arr = [AuditAnswerModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "Select * from \(DBTables.AuditAnswers) where location_id = \(locationId) and sub_location_id = \(sub_locationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!) and is_subquestion = 1 and  parent_question_id = \(parentQuestionId) "
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = AuditAnswerModel()
                    obMAL.incId = Int(sqlite3_column_int(statement, 0))
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.subLocationId = Int(sqlite3_column_int(statement, 4))
                    obMAL.folderId = Int(sqlite3_column_int(statement, 5))
                    obMAL.questionId = Int(sqlite3_column_int(statement, 6))
                    obMAL.answerId = String(cString:sqlite3_column_text(statement, 7))
                    obMAL.questionType = Int(sqlite3_column_int(statement, 8))
                    obMAL.categoryType = Int(sqlite3_column_int(statement, 9))
                    obMAL.priority = Int(sqlite3_column_int(statement, 10))
                    obMAL.isUpdate = Int(sqlite3_column_int(statement, 11))
                    obMAL.sublocation_subfolder_id = Int(sqlite3_column_int(statement, 12))
                    obMAL.subfolder_id = Int(sqlite3_column_int(statement, 13))
                    obMAL.question = String(cString:sqlite3_column_text(statement, 14))
                    obMAL.answers = String(cString:sqlite3_column_text(statement, 15))
                    obMAL.answerDescription = String(cString:sqlite3_column_text(statement, 16))
                    obMAL.imgName = String(cString:sqlite3_column_text(statement, 17))
                    obMAL.savedAnswer = String(cString:sqlite3_column_text(statement, 18))
                    obMAL.savedAnswer_id = String(cString:sqlite3_column_text(statement, 19))
                    obMAL.hasSubQuestion = Int(sqlite3_column_int(statement, 20))
                    obMAL.isSubQuestion = Int(sqlite3_column_int(statement, 21))
                    obMAL.parentQuestionId = Int(sqlite3_column_int(statement, 22))
                    obMAL.selectedAnswerIdForSubQuestion = Int(sqlite3_column_int(statement, 23))
                    obMAL.isSync = Int(sqlite3_column_int(statement, 24))
                    obMAL.isSuperUserAudit = Int(sqlite3_column_int(statement, 25))
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.AuditAnswers) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    // Count & TotalCount
    func getAuditAnswersCounts(auditId:Int, locationId:Int, folderId:Int, subfolderId:Int, sub_locationId:Int, sub_locationsub_folderId:Int, parentId:Int, fetchType:String) -> Int {
        
        var count = 0
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var fetchSQL = ""
            if fetchType == "count" {
                fetchSQL = "SELECT COUNT(*) AS `count` FROM \(DBTables.AuditAnswers) WHERE audit_id = \(auditId) and location_id = \(locationId) and folder_id = \(folderId) and subfolder_id = \(subfolderId) and sub_location_id = \(sub_locationId) and sublocation_subfolder_id = \(sub_locationsub_folderId) and is_update = \(1) and user_id = \(UserProfile.id!) and category_type = 1 and parent_question_id >= \(parentId) and is_subquestion = 0"
            } else if fetchType == "totalcount" {
                fetchSQL = "SELECT COUNT(*) AS `totalcount` FROM \(DBTables.AuditAnswers) WHERE audit_id = \(auditId) and location_id = \(locationId) and folder_id = \(folderId) and subfolder_id = \(subfolderId) and sub_location_id = \(sub_locationId) and sublocation_subfolder_id = \(sub_locationsub_folderId) and user_id = \(UserProfile.id!) and category_type = 1 and parent_question_id >= \(parentId) and is_subquestion = 0"
            }
            ////print("fetchSQL = \(fetchSQL)")
            if sqlite3_prepare_v2(auditAppDB, fetchSQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    count = Int(sqlite3_column_int(statement, 0))
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.AuditAnswers) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return count
    }

    /**
     This functions helps to check the audit completion status, here I will fetch audit questions isupdate status and return it. After It will on check the progress.
     */
    func getAuditWorkingStatus(auditId: Int) -> NSMutableArray {
       let arrQuestions = NSMutableArray()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
           let querySQL = "SELECT is_update from \(DBTables.AuditAnswers) where audit_id = \(auditId) and user_id = \(UserProfile.id!) and parent_question_id >= 0 and is_subquestion = 0 and category_type = 1"
         //   //print("query = \(querySQL)")
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                   let dict = NSMutableDictionary()
                    dict.setValue(Int(sqlite3_column_int(statement, 0)), forKey: "isUpdate")
                    arrQuestions.add(dict)
                }
                 sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.AuditAnswers) error sqlite3_step: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arrQuestions
    }
    
    //MARK: --- UPDATE Operation
    func updateAuditAnswerData(obAns: AuditAnswerModel, incId: Int, updateType: String) -> Bool {
        var flagIsUpdated = false
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var updateSQL = ""
            if updateType == "updatedata" {
                updateSQL = "UPDATE \(DBTables.AuditAnswers) set priority = ? , is_update = ? , description = ? , img_data = ? , saved_answer = ? , saved_answer_id = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            } else if updateType == "reset" {
                updateSQL = "UPDATE \(DBTables.AuditAnswers) set priority = ? , is_update = ? , description = ? , img_data = ? , saved_answer = ? , saved_answer_id = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            } else if updateType == "sync" {
                updateSQL = "UPDATE \(DBTables.AuditAnswers) set is_sync = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            }

            if sqlite3_prepare_v2(auditAppDB, updateSQL, -1, &statement, nil) == SQLITE_OK {
                
                if updateType == "updatedata" {
                    sqlite3_bind_int(statement, 1, Int32(obAns.priority!))
                    sqlite3_bind_int(statement, 2, Int32(obAns.isUpdate!))
                    sqlite3_bind_text(statement, 3, obAns.answerDescription, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 4, obAns.imgName, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 5, obAns.savedAnswer, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 6, obAns.savedAnswer_id, -1, SQLITE_TRANSIENT)
                }  else if updateType == "reset" {
                    sqlite3_bind_int(statement, 1, Int32(QuestionPriority.Low))
                    sqlite3_bind_int(statement, 2, Int32(0))
                    sqlite3_bind_text(statement, 3, "", -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 4, "", -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 5, "", -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 6, "", -1, SQLITE_TRANSIENT)
                }  else if updateType == "sync" {
                    sqlite3_bind_int(statement, 1, Int32(1))
                }
               
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.AuditAnswers) Record updated successfully")
                    flagIsUpdated = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
                flagIsUpdated = false
            }
        }
        return flagIsUpdated
    }
    
    //MARK: --- DELETE Operation
    func deleteQuestionAnswer(auditId:Int, locationId:Int, folderId:Int, subFolderId:Int, subLocationId:Int, subLocationSubFolderId: Int, deleteType:String, questionId: Int = 0) {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var deleteSQL = ""
            if deleteType == "location" {
                deleteSQL = "DELETE FROM \(DBTables.AuditAnswers) WHERE location_id = \(locationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            } else if deleteType == "locationSubfolder" {
                deleteSQL = "DELETE FROM \(DBTables.AuditAnswers) WHERE location_id = \(locationId) and audit_id = \(auditId) and folder_id = \(folderId) and subfolder_id = \(subFolderId) and user_id = \(UserProfile.id!)"
            } else if deleteType == "sublocation" {
                deleteSQL = "DELETE FROM \(DBTables.AuditAnswers) WHERE location_id = \(locationId) and audit_id = \(auditId) and folder_id = \(folderId) and subfolder_id = \(subFolderId) and sub_location_id = \(subLocationId) and user_id = \(UserProfile.id!)"
            } else if deleteType == "sublocationSubFolder" {
                deleteSQL = "DELETE FROM \(DBTables.AuditAnswers) WHERE location_id = \(locationId) and audit_id = \(auditId) and folder_id = \(folderId) and subfolder_id = \(subFolderId) and sub_location_id = \(subLocationId) and sublocation_subfolder_id = \(subLocationSubFolderId) and user_id = \(UserProfile.id!)"
            } else if deleteType == "all" {
                deleteSQL = "DELETE FROM \(DBTables.AuditAnswers)"
            } else if deleteType == "selectedId" {
                deleteSQL = "DELETE FROM \(DBTables.AuditAnswers) WHERE question_id = \(questionId) and location_id = \(locationId) and audit_id = \(auditId) and folder_id = \(folderId) and subfolder_id = \(subFolderId) and sub_location_id = \(subLocationId) and sublocation_subfolder_id = \(subLocationSubFolderId) and user_id = \(UserProfile.id!)"
            }
            //print("Delete Quesry = \(deleteSQL)")
            
            if sqlite3_prepare_v2(auditAppDB, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("AuditAnswers Record Deleted")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
    }
    
    //MARK: ******************************************** AuditAnswers Table All Operations FINISH ********************************************

    //MARK: ****************** SubLocationSubFolderPhotos Table All Operations START Here *****************

    //MARK: --- INSERT Operation
    func insertPhotosSubLocationSubFolder(oblist: SubLocationSubFolder_PhotoModel) -> Int {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        var lastinsertid = 0
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "INSERT INTO \(DBTables.SubLocationSubFolderPhotos) (user_id, audit_id, location_id, folder_id, subfolder_id, sublocation_id, sublocationsubfolder_id, location_name, folder_name, subfolder_name, sublocation_name, sublocationsubfolder_name, img_name, main_photo, is_sync) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(UserProfile.id!))
                sqlite3_bind_int(statement, 2, Int32(oblist.auditId!))
                sqlite3_bind_int(statement, 3, Int32(oblist.locationId!))
                sqlite3_bind_int(statement, 4, Int32(oblist.folderId!))
                sqlite3_bind_int(statement, 5, Int32(oblist.subFolderId!))
                sqlite3_bind_int(statement, 6, Int32(oblist.subLocationId!))
                sqlite3_bind_int(statement, 7, Int32(oblist.subLocation_subFolderId!))
                sqlite3_bind_text(statement, 8, oblist.locationName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 9, oblist.folderName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 10, oblist.subFolderName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 11, oblist.subLocationName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 12, oblist.subLocation_subFolderName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 13, oblist.imgName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 14, Int32(oblist.main_photo!))
                sqlite3_bind_int(statement, 15, Int32(oblist.isSync!))
            }
            if sqlite3_step(statement) == SQLITE_DONE {
             //   //print("\(DBTables.SubLocationSubFolderPhotos) Record added successfully")
                lastinsertid = getPhotosSubLocationSubFolderLastID()
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return lastinsertid
    }
    
    //MARK: --- FETCH Operation
    func getPhotosSubLocationSubFolder(auditId:Int, locationId:Int, folderId:Int, subfolderId:Int, sub_locationId:Int, sub_locationsub_folderId:Int, main_photo:Int, fetchType:String) -> [SubLocationSubFolder_PhotoModel] {
        var arr = [SubLocationSubFolder_PhotoModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            var fetchSQL = ""
            if fetchType == "audit" {
                fetchSQL = "SELECT * FROM \(DBTables.SubLocationSubFolderPhotos) WHERE audit_id = \(auditId) and location_id = \(locationId) and folder_id = \(folderId) and subfolder_id = \(subfolderId) and sublocation_id = \(sub_locationId) and sublocationsubfolder_id = \(sub_locationsub_folderId) and main_photo = \(main_photo) and user_id = \(UserProfile.id!)"
            } else if fetchType == "media" {
              //  fetchSQL = "SELECT * FROM \(DBTables.SubLocationSubFolderPhotos) WHERE audit_id = \(auditId) and location_id = \(locationId) and sublocation_id = \(sub_locationId) and user_id = \(UserProfile.id!)"
                fetchSQL = "SELECT * FROM \(DBTables.SubLocationSubFolderPhotos) WHERE audit_id = \(auditId) and location_id = \(locationId) and folder_id = \(folderId) and subfolder_id = \(subfolderId) and sublocation_id = \(sub_locationId) and sublocationsubfolder_id = \(sub_locationsub_folderId) and user_id = \(UserProfile.id!)"
            }
            if sqlite3_prepare_v2(auditAppDB, fetchSQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let obMAL = SubLocationSubFolder_PhotoModel()
                    obMAL.incId = Int(sqlite3_column_int(statement, 0))
                    obMAL.auditId = Int(sqlite3_column_int(statement, 2))
                    obMAL.locationId = Int(sqlite3_column_int(statement, 3))
                    obMAL.folderId = Int(sqlite3_column_int(statement, 4))
                    obMAL.subFolderId = Int(sqlite3_column_int(statement, 5))
                    obMAL.subLocationId = Int(sqlite3_column_int(statement, 6))
                    obMAL.subLocation_subFolderId = Int(sqlite3_column_int(statement, 7))
                    obMAL.locationName = String(cString:sqlite3_column_text(statement, 8))
                    obMAL.folderName = String(cString:sqlite3_column_text(statement, 9))
                    obMAL.subFolderName = String(cString:sqlite3_column_text(statement, 10))
                    obMAL.subLocationName = String(cString:sqlite3_column_text(statement, 11))
                    obMAL.subLocation_subFolderName = String(cString:sqlite3_column_text(statement, 12))
                    obMAL.imgName = String(cString:sqlite3_column_text(statement, 13))
                    obMAL.main_photo = Int(sqlite3_column_int(statement, 14))
                    obMAL.isSync = Int(sqlite3_column_int(statement, 15))
                    arr.append(obMAL)
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.SubLocationSubFolderPhotos) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    // --- Get Last Row ID
    func getPhotosSubLocationSubFolderLastID() -> Int {
        var rowId = 0
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT MAX(inc_id) FROM \(DBTables.SubLocationSubFolderPhotos)"
            //      //print("querySQL = \(querySQL)")
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    rowId = Int(sqlite3_column_int(statement, 0))
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.SubLocationSubFolderPhotos) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return rowId
    }
    
    // --- Get Photos for Sync
    func getPhotoNameSubLocationSubFolder(auditId:Int, locationId:Int, folderId:Int, subfolderId:Int, sub_locationId:Int, sub_locationsub_folderId:Int, main_photo:Int, isSync:Int) -> NSMutableDictionary {
        let dictData = NSMutableDictionary()
        let arrImages = NSMutableArray()
        let arrIds = NSMutableArray()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            
            let querySQL = "SELECT img_name, inc_id FROM \(DBTables.SubLocationSubFolderPhotos) WHERE audit_id = \(auditId) and location_id = \(locationId) and folder_id = \(folderId) and subfolder_id = \(subfolderId) and sublocation_id = \(sub_locationId) and sublocationsubfolder_id = \(sub_locationsub_folderId) and main_photo = \(main_photo) and user_id = \(UserProfile.id!) and is_sync = \(isSync)"
            //  //print("querySQL = \(querySQL)")
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    arrImages.add(String(cString:sqlite3_column_text(statement, 0)))
                    arrIds.add(Int(sqlite3_column_int(statement, 1)))
                }
                
                dictData.setValue(arrImages, forKey: "Name")
                dictData.setValue(arrIds, forKey: "Id")
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.SubLocationSubFolderPhotos) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return dictData
    }
    
    //MARK: --- UPDATE Operation
    func updatePhotoSyncData(primaryId: Int) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "UPDATE \(DBTables.SubLocationSubFolderPhotos) set is_sync = ? Where inc_id = \(primaryId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(1))
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.SubLocationSubFolderPhotos) Record updated successfully")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
        }
    }
    
    //MARK: --- DELETE Operation
    func deleteSubLocationSubFolderPhoto(incId: Int, auditId:Int, locationId:Int, sublocationId:Int, deleteType:String) -> Bool {
        let dbpath = getDataBasePath()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        var flagIsUpdated = false
        
        if sqlite3_open(dbpath, &auditAppDB) == SQLITE_OK {
            var deleteSQL = ""
            if deleteType == "incID" {
                deleteSQL = "DELETE FROM \(DBTables.SubLocationSubFolderPhotos) WHERE inc_id = \(incId)"
            } else if deleteType == "location" {
                deleteSQL = "DELETE FROM \(DBTables.SubLocationSubFolderPhotos) WHERE location_id = \(locationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            } else if deleteType == "sublocation" {
                deleteSQL = "DELETE FROM \(DBTables.SubLocationSubFolderPhotos) WHERE sublocation_id = \(sublocationId) and audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            } else if deleteType == "all" {
                deleteSQL = "DELETE FROM \(DBTables.SubLocationSubFolderPhotos)"
            }
            
            if sqlite3_prepare_v2(auditAppDB, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.SubLocationSubFolderPhotos) Record Deleted successfully")
                    flagIsUpdated = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                    flagIsUpdated = false
                }
            } else { }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        }
        return flagIsUpdated
    }
    
    //MARK: ******************************************** SubLocationSubFolderPhotos Table All Operations FINISH ********************************************
    //MARK: ****************** ChatUserList & UserChating Table All Operations START Here *****************

    //MARK: --- INSERT Operation
    func insertUserChatList(oblist: ChatListModel) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
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
              //  //print("\(DBTables.ChatUserList) Record added successfully")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
    }
    
    //MARK: --- FETCH Operation
    func getChatList() -> [ChatListModel] {
        var arr = [ChatListModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
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
                //print("\(DBTables.ChatUserList) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return arr
    }
    
    //MARK: --- INSERT Operation
    func insertChatData(obchat: ChatModel) -> Bool {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
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
             //   //print("\(DBTables.UserChating) Record added successfully")
            } else {
                insertsuccess = false
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
            sqlite3_finalize(statement)
            sqlite3_close(auditAppDB)
        } else {
            insertsuccess = false
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return insertsuccess
    }

    //MARK: --- FETCH Operation
    func getChatLastId() -> Int {
        var primaryid = 0
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let querySQL = "SELECT MAX(id) FROM \(DBTables.UserChating)"
            if sqlite3_prepare_v2(auditAppDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    primaryid = Int(sqlite3_column_int(statement, 0))
                }
                sqlite3_finalize(statement)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("\(DBTables.UserChating) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        return primaryid
    }
    
    // --- GET All chat user
    func getChat(to_user_id: Int) -> NSMutableArray {
        var flag = false
        var arr = [ChatModel]()
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
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
                //print("\(DBTables.UserChating) error sqlite3_step: \(errmsg)")
            }
            sqlite3_close(auditAppDB)
        } else {
            flag = false
            let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
            //print("data base is not opened \(errmsg)")
        }
        let arr1 = NSMutableArray()
        arr1.add(arr)
        arr1.add(flag)
        return arr1
    }
    
    //MARK: --- UPDATE Operation
    func updateChatDownload(isDownload: Int, msg:String, incId: Int) -> Bool {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        var flagIsUpdated = false
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.UserChating) set is_download = ? , msg = ? Where id = \(incId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(isDownload))
                sqlite3_bind_text(statement, 2, msg, -1, SQLITE_TRANSIENT)
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.UserChating) Record updated successfully")
                    flagIsUpdated = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                    flagIsUpdated = false
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
                flagIsUpdated = false
            }
        }
        return flagIsUpdated
    }
    
    //MARK: ReEdit Audit:-
    
    func resetAuditPhotosSyncStatus(auditId: Int) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.SubLocationSubFolderPhotos) set is_sync = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(0))
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.SubLocationSubFolderPhotos) Record updated successfully")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
        }
    }
    
    func resetAuditAnswersSyncStatus(auditId: Int) {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.AuditAnswers) set is_sync = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(0))
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.AuditAnswers) Record updated successfully")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
        }
    }
    
    func resetAuditForReAudit(auditId: Int) -> Bool {
        var statement: OpaquePointer?
        var auditAppDB: OpaquePointer?
        var flagIsUpdated: Bool? = false
        if sqlite3_open(getDataBasePath(), &auditAppDB) == SQLITE_OK {
            let insertSQL = "UPDATE \(DBTables.MyAuditList) set is_start_sync = ?, is_sync_completed = ?, total_answers_sync = ?, total_answers_for_sync = ? Where audit_id = \(auditId) and user_id = \(UserProfile.id!)"
            if sqlite3_prepare_v2(auditAppDB, insertSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(0))
                sqlite3_bind_int(statement, 2, Int32(0))
                sqlite3_bind_int(statement, 3, Int32(0))
                sqlite3_bind_int(statement, 4, Int32(0))
                if sqlite3_step(statement) == SQLITE_DONE {
                    //print("\(DBTables.MyAuditList) Record updated successfully")
                    self.resetAuditAnswersSyncStatus(auditId: auditId)
                    self.resetAuditPhotosSyncStatus(auditId: auditId)
                    self.resetAuditLocationSubFolders(auditId: auditId)
                    flagIsUpdated = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                    //print("error sqlite3_step: \(errmsg)")
                }
                sqlite3_finalize(statement)
                sqlite3_close(auditAppDB)
            } else {
                let errmsg = String(cString: sqlite3_errmsg(auditAppDB)!)
                //print("error sqlite3_step: \(errmsg)")
            }
        }
        return flagIsUpdated!
    }
 }
