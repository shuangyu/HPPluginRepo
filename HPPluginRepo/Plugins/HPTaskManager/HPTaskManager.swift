//
//  HPTaskManager.swift
//  HPPluginRepo
//
//  Created by 胡鹏 on 23/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

private func HPTaskManager_DateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar.init(identifier: .gregorian)
    return formatter
}

//extension HPTaskManager.TaskTime: Archivable {
//    public func archive() -> NSDictionary {
//        let count = self.duration!.count
//        var from = ""
//        var to = ""
//        if count == 2 {
//            let formatter = HPTaskManager_DateFormatter()
//            let fDate = self.duration![0]
//            let tDate = self.duration![1]
//            from = formatter.string(from: fDate)
//            to = formatter.string(from: tDate)
//        }
//        return ["weekdays" : self.weekdays,
//                "from" : from,
//                "to" : to]
//    }
//
//    public init?(unarchive: NSDictionary?) {
//        let formatter = HPTaskManager_DateFormatter()
//        let from = unarchive!["from"] as! String
//        let to = unarchive!["to"] as! String
//        self.weekdays = unarchive!.object(forKey: "weekdays") as! HPTaskManager.Weekdays
//
//        let fDate = formatter.date(from: from)
//        let tDate = formatter.date(from: to)
//        self.duration = [fDate!, tDate!]
//    }
//}
//
//extension HPTaskManager.Task: Archivable {
//    public func archive() -> NSDictionary {
//        return ["type" : self.type,
//                "key" : self.key,
//                "user" : self.user,
//                "times" : self.times,
//                "taskTime" : self.taskTime.archive()]
//    }
//
//    public init?(unarchive: NSDictionary?) {
//        self.type = unarchive?.object(forKey: "type") as! HPTaskManager.TaskType
//        self.key = unarchive?.object(forKey: "key") as! String
//        self.user = unarchive?.object(forKey: "type") as! String
//        self.times = unarchive?.object(forKey: "type") as! Int
//        self.taskTime = HPTaskManager.TaskTime(unarchive: unarchive?.object(forKey: "taskTime") as? NSDictionary)!
//    }
//}

public class HPTaskManager: NSObject {
    
    typealias Duration = Array<Date>
    typealias Weekdays = Int
    static let Monday: Int = 1 << 0
    static let Tuesday: Int = 1 << 1
    static let Wednesday: Int = 1 << 2
    static let Thursday: Int = 1 << 3
    static let Friday: Int = 1 << 4
    static let Saturday: Int = 1 << 5
    static let Sunday: Int = 1 << 6
    
    public enum TaskType: Int {
        /*
         * task will exist all the time until completed
         * task can be completed anytime
         */
        case normal
        /*
         * task will only exist for one day
         * task can only be completed on registed day
         */
        case daily
        /*
         * task will only exist for one day
         * task can only be registed on specifical weekdays
         * task can only be completed on registed day
         */
        case weekly
        /*
         * task will only exist for specifical duration
         * task can only be completed on specifical duration
         */
        case periodic
    }
    
    public struct TaskTime {
        let duration: Duration?
        var weekdays: Weekdays = 0
    }
    
    public struct Task {
        let type: TaskType
        let key : String
        var user: String = "com.hp.task.default.key"
        let taskTime: TaskTime
        let times: Int
        
        static func == (lhs: Task, rhs: Task) -> Bool {
            return lhs.key == rhs.key
        }
        static func != (lhs: Task, rhs: Task) -> Bool {
            return lhs.key != rhs.key
        }
    }

    
    static let `default` = HPTaskManager()
    private var tasks: Array<Task>?
    private let cache = UserDefaults.standard
    private let cacheKey = "com.hpDemo.tasks.cacheKey"
    private override init() {
        super.init()
        loadTasks()
    }
    
    private func loadTasks() {
        tasks = cache.object(forKey: cacheKey) as? Array<Task>
    }
    
    private func saveTasks() {
        if tasks != nil {
            cache.set(tasks, forKey: cacheKey)
        } else {
            cache.removeObject(forKey: cacheKey)
        }
    }
    
    public func register(task: Task) -> Bool {
        return true
    }
    public func revoke(task: Task) -> Bool {
        return true
    }
    public func complete(task: Task) -> Bool {
        return true
    }
    
}
