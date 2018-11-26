//
//  DateClassFunctions.swift
//  Productivity Planner
//
//  Created by Gourav Joshi on 02/06/18.
//  Copyright © 2018 Gourav Joshi. All rights reserved.
//

import UIKit

class DateClassFunctions: NSObject {
    //MARK: Date Functions:
    func change(date inputDate:String , format inputFormat:String, to outputFormat:String) -> String {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = inputFormat
        inputDateFormatter.timeZone = TimeZone.init(identifier: TimeZone.current.identifier)
        let inDate = inputDateFormatter.date(from: inputDate)
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = outputFormat
        outputDateFormatter.timeZone = TimeZone.init(identifier: TimeZone.current.identifier)
        return outputDateFormatter.string(from: inDate!)
    }
    
    func changeDate(date inputDate:String , format inputFormat:String, to outputFormat:String) -> Date {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = inputFormat
        inputDateFormatter.timeZone = TimeZone.init(identifier: TimeZone.current.identifier)
        let inDate = inputDateFormatter.date(from: inputDate)
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = outputFormat
        outputDateFormatter.timeZone = TimeZone.init(identifier: TimeZone.current.identifier)
        
        let finalDF = DateFormatter()
        finalDF.dateFormat = outputFormat
        finalDF.timeZone = TimeZone.init(identifier: TimeZone.current.identifier)
        let fDate = inputDateFormatter.date(from: outputDateFormatter.string(from: inDate!))
        return fDate!
    }
    
    func getTimeDifferenceBetweenTwoDates(strMsgDate: String) -> String  {
        
        var strTimeMessage = ""
        if(strMsgDate.count > 0){
            let df1 = DateFormatter()
            df1.dateFormat = "YYYY-MM-dd HH:mm:ss"
            df1.timeZone = TimeZone.init(identifier: "GMT")
            let dateMsg = df1.date(from: strMsgDate)
            let todaysDate = NSDate()
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"//DataBaseConstants.ChatDateFormatAlter
            df.timeZone = TimeZone.init(identifier: "GMT")
            let strdate = df.string(from: todaysDate as Date)
            let date2 = df.date(from: strdate)
            //
            var date1 = df.date(from: strMsgDate)
            if(date1 == nil) {
                df.dateFormat = "YYYY-MM-dd HH:mm:ss"
                df.timeZone = TimeZone.init(identifier: "GMT")
                date1 = df.date(from: strMsgDate)
                //       print(" case date1 = \(date1)")
            }
            
            let interval = date1!.timeIntervalSince(date2!) + 47
            let hours = Int(interval) / 3600
            let minutes = (Int(interval) - (hours * 3600)) / 60
            let seconds = (Int(interval) - (hours * 3600))
            // print("seconds = \(seconds), hours = \(hours), minutes = \(minutes)")
            // interval minus hours part (in seconds) divided by 60 yields minutes
            
            let df5 = DateFormatter()
            df5.dateFormat = "YYYY-MM-dd"
            df5.timeZone = TimeZone.init(identifier: "GMT")
            print("df5 date = \(df5.string(from: date1!))")
            
            let strDateS1 = df5.string(from: date1!)
            let strDateS2 = df5.string(from: date2!)
            
            if strDateS1 == strDateS2 {
             print("seconds = \(seconds), hours = \(hours), minutes = \(minutes)")
          //  if comparedates == true {
                
                let df6 = DateFormatter()
                df6.dateFormat = "hh:mm a"
                df6.timeZone = TimeZone.init(identifier: "GMT")
                let strTimeS1 = df6.string(from: date1!)
                
                strTimeMessage = String(format: "Today,%@", strTimeS1)
                
                /*
                if(seconds < 0 && hours == 0 && minutes == 0) {
                    strTimeMessage = "Today,Just now"
                } else if (seconds >= 1 && seconds < 59 && hours == 0 && minutes == 0) {
                    strTimeMessage = "Today," + String(seconds) + " seconds ago"
                } else if (minutes > 0 && minutes <= 59 && hours == 0) {
                    if(minutes > 1) {
                        strTimeMessage = "Today," + String(minutes) + " minutes ago"
                    } else {
                        strTimeMessage = "Today," + String(minutes) + " minute ago"
                    }
                } else if (hours >= 1 && hours < 24) {
                    if(hours > 1) {
                        strTimeMessage = "Today," + String(hours) + " hours ago"
                    } else {
                        strTimeMessage = "Today," + String(hours) + " hour ago"
                    }
                } */
            }
            else {
                if (hours < 48) {
                    df1.dateFormat = "hh:mm a"//DataBaseConstants.ChatDateFormatAlter
                    let strdate = df1.string(from: dateMsg!)
                    strTimeMessage = String(format:"Yesterday,%@", strdate)
                } else if (hours > 48) {
                    df1.dateFormat = "dd MMM yyyy"//DataBaseConstants.ChatDateFormatAlter
                    let strdate = df1.string(from: dateMsg!)
                    df1.dateFormat = "HH:mm a"//DataBaseConstants.ChatDateFormatAlter
                    let strtime = df1.string(from: dateMsg!)
                    strTimeMessage = String(format:"%@,%@", strdate,strtime)
                }
            }
          
        }
        return strTimeMessage
    }
    
    func convertDateFormat(date: String) -> String {
        dateFormatCustom.locale = NSLocale(localeIdentifier: "en") as Locale?
        dateFormatCustom.dateFormat = "YYYY-MM-dd HH:mm:ss"
        guard let cDate = dateFormatCustom.date(from: date) else {
            print("no date from string")
            return ""
        }
        dateFormatCustom.dateFormat = "YYYY-MM-dd hh:mm a"
        dateFormatCustom.timeZone = TimeZone.current
        let timeStamp = dateFormatCustom.string(from: cDate.toLocalTime())
        return timeStamp
    }
    
    func getTodaysDate() -> String {
        dateFormatCustom.dateFormat = "dd MMM YYYY, EEEE"
        let date = dateFormatCustom.string(from: Date())
        return date
    }
    
    func getCurrentDate() -> String {
        dateFormatCustom.dateFormat = "dd MMM YYYY"
        let date = dateFormatCustom.string(from: Date())
        return date
    }
    
    func getWeekStartDate_DMY() -> String {
        dateFormatCustom.dateFormat = DateFormat_DMY
        let date = dateFormatCustom.string(from: Date().startOfWeek!)
        return date
    }
    
    func getWeekEndDate_DMY() -> String {
        dateFormatCustom.dateFormat = DateFormat_DMY
        let date = dateFormatCustom.string(from: Date().endOfWeek!)
        return date
    }
    
    func getMonthStartDate_DMY() -> String {
        dateFormatCustom.dateFormat = DateFormat_DMY
        let date = dateFormatCustom.string(from: Date().startOfMonth())
        return date
    }
    
    func getMonthEndDate_DMY() -> String {
        dateFormatCustom.dateFormat = DateFormat_DMY
        let date = dateFormatCustom.string(from: Date().endOfMonth())
        return date
    }
    
    func getCurrentDate_YMD() -> String {
        dateFormatCustom.dateFormat = DateFormat_YMD
        let date = dateFormatCustom.string(from: Date())
        return date
    }
    
    func getCurrentDateTime_YMD_HMS() -> String {
        dateFormatCustom.dateFormat = DateFormat_YMD_HMS
        let date = dateFormatCustom.string(from: Date())
        return date
    }
    
    func getWeekStartDate_YMD() -> String {
        dateFormatCustom.dateFormat = DateFormat_YMD
        let date = dateFormatCustom.string(from: Date().startOfWeek!)
        return date
    }
    
    func getWeekEndDate_YMD() -> String {
        dateFormatCustom.dateFormat = DateFormat_YMD
        let date = dateFormatCustom.string(from: Date().endOfWeek!)
        return date
    }
    
    func getCurrentMonth_MY() -> String {
        dateFormatCustom.dateFormat = "MMM YYYY"
        let date = dateFormatCustom.string(from: Date())
        return date
    }
    
    func getMonthStartDate_YMD() -> String {
        dateFormatCustom.dateFormat = DateFormat_YMD
        let date = dateFormatCustom.string(from: Date().startOfMonth())
        return date
    }
    
    func getMonthEndDate_YMD() -> String {
        dateFormatCustom.dateFormat = DateFormat_YMD
        let date = dateFormatCustom.string(from: Date().endOfMonth())
        return date
    }
    
}

extension Date{
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
}
