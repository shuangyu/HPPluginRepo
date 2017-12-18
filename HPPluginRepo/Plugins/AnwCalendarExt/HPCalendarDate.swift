//
//  NSDateCalExt.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 11/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

/*
 * !!! Cautions: this Extension only works for Gregorian calendar
 */

import UIKit

typealias HPCalDate = Date
typealias HPCalYear = Int
typealias HPCalMonth = Int
typealias HPCalDay = Int
typealias HPCalWeekDay = Int

let kHPCalMonthLengths = [31,28,31,30,31,30,31,31,30,31,30,31]
let kHPCalLeapMonthLengths = [31,29,31,30,31,30,31,31,30,31,30,31]
let kHPCalMonthName = ["January","February","March","April","May","Jun","July","August","September","October","November","December"]
let kHPCalMonthShortName = ["Jan.","Feb.","Mar.","Apr.","May","Jun","July","Agu.","Sept.","Oct.","Nov.","Dec."]

enum HPCalendarError: Error {
    case invalidParameter
}

extension HPCalDate {
    static var today: HPCalDate {
        return Date()
    }
    var year: HPCalYear {
        return Calendar(identifier:.gregorian).component(.year, from: self)
    }
    
    var month: HPCalMonth {
        return Calendar(identifier:.gregorian).component(.month, from: self)
    }
    
    var day: HPCalDay {
        return Calendar(identifier:.gregorian).component(.day, from: self)
    }
    // start from 1 to 7, and 1 represent Sunday
    var weekDay: HPCalWeekDay {
        return Calendar(identifier:.gregorian).component(.weekday, from: self)
    }
}

extension HPCalYear {
    var isLeapYear: Bool {
        return (self%4 == 0 && self%100 != 0) || (self%400 == 0);
    }
}

struct HPMonth {
    
    let year: HPCalYear
    let month: HPCalMonth
    
    // contains pre-month's tail and next-month's head
    // use this value to draw month view
    let lengthIncludePadding: Int
    let length: Int
    let startWeekDay: HPCalWeekDay
    let endWeekDay: HPCalWeekDay
    var days: [String] = []
    
    var name: String {
        return "\(kHPCalMonthName[month - 1]) \(year)"
    }
    var shortName: String {
        return "\(kHPCalMonthShortName[month - 1]) \(year)"
    }

    init(year: HPCalYear=HPCalDate.today.year, month: HPCalMonth=HPCalDate.today.month) throws {
        
        self.year = year
        self.month = month
        
        let monthStr =  month > 9 ? "\(month)" : "0\(month)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let startDateStr = "\(year)-\(monthStr)-01"
        let startDate = formatter.date(from: startDateStr)
        
        guard let unwrappedStartDate = startDate else {
            throw HPCalendarError.invalidParameter
        }
        
        self.length = year.isLeapYear ? kHPCalLeapMonthLengths[month-1] : kHPCalMonthLengths[month-1]
        
        let endDateStr = "\(year)-\(monthStr)-\(self.length)"
        let endDate: HPCalDate! = formatter.date(from: endDateStr)!
        
        self.startWeekDay = unwrappedStartDate.weekDay
        self.endWeekDay = endDate.weekDay
        
        let preOffset = (self.startWeekDay - 1)
        let sufOffset = (7 - self.endWeekDay)
        
        self.lengthIncludePadding = self.length + preOffset + sufOffset
        
        for _ in 0..<preOffset {
            days.append("")
        }
        
        for i in 0..<length {
            days.append("\(i+1)")
        }
        
        for _ in 0..<sufOffset {
            days.append("")
        }
    }
    
    func nextMonth() throws -> HPMonth {
        let nextMonth = self.month + 1
        let month = nextMonth > 12 ? nextMonth%12 : nextMonth
        let year = nextMonth > 12 ? self.year + 1 : self.year
        return try HPMonth(year: year, month: month)
    }
    
    func preMonth() throws -> HPMonth {
        let preMonth = self.month - 1
        let month = preMonth < 1 ? preMonth + 12  : preMonth
        let year = preMonth < 1 ? self.year - 1 : self.year
        return try HPMonth(year: year, month: month)
    }
}
