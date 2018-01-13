//
//  HPTaskManager.swift
//  HPPluginRepo
//
//  Created by 胡鹏 on 23/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

private func __HPTaskManagerDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar.init(identifier: .gregorian)
    return formatter
}

enum HPTaskManagerError: Error {
    case duplicatedTask(key: String, user: String)
    case taskNotFound(key: String, user: String)
    case taskHasBeenCompleted(key: String, user: String)
    case taskInactive(key: String, user: String)
    case invalidParameter(message: String)
}

public class HPTaskManager {
    
    public typealias TaskTimeDuration = Array<Date>
    public typealias TaskTimeWeekdays = Int
    public typealias TaskTimeWeekday = Int
    public static let Monday: TaskTimeWeekday = 1 << 0
    public static let Tuesday: TaskTimeWeekday = 1 << 1
    public static let Wednesday: TaskTimeWeekday = 1 << 2
    public static let Thursday: TaskTimeWeekday = 1 << 3
    public static let Friday: TaskTimeWeekday = 1 << 4
    public static let Saturday: TaskTimeWeekday = 1 << 5
    public static let Sunday: TaskTimeWeekday = 1 << 6
    
    public enum TaskType: Int {
        /*
         * task can be registed anytime
         * task can be completed anytime
         */
        case normal
        /*
         * task will be refreshed everyday automatically
         */
        case daily
        /*
         * task will be achievable only on specified weekdays
         */
        case weekly
        /*
         * task can only be registed before the end date of the duration
         * task will be removed after the end date of the duration
         */
        case periodic
    }
    
    public struct TaskTimeArg {
        var duration: TaskTimeDuration?
        var weekdays: TaskTimeWeekdays?
        
        init(duration: TaskTimeDuration) throws {
            guard duration.count == 2 else {
                throw HPTaskManagerError.invalidParameter(message: "duration must has two date string element")
            }
            self.duration = duration
        }
        init(weekdays: TaskTimeWeekdays) {
            self.weekdays = weekdays
        }
    }
    
    public struct Task: Equatable {
        
        let type: TaskType
        let key : String
        var user: String
        let taskTimeArg: TaskTimeArg?
        var times: Int
        var leftTimes: Int
        // string of date & dateFormat = "yyyy-MM-dd"
        var updateTime: String
        
        init(type: TaskType = .normal,
             key: String,
             user: String = "com.hp.task.default.key",
             arg: TaskTimeArg? = nil,
             times: Int = 1) {

            self.type = type
            self.key = key
            self.user = user
            self.taskTimeArg = arg
            self.times = Task.taskIsActive(with: arg) ? times : 0
            self.leftTimes = times
            self.updateTime = Task.getLatestUpdateTime()
        }
        public static func weekDay(of date: Date) -> TaskTimeWeekday {
            let cal = Calendar.init(identifier: .gregorian)
            let weekDay = cal.component(.weekday, from: Date())
            switch weekDay {
            case 1:
                return HPTaskManager.Sunday
            case 2:
                return HPTaskManager.Monday
            case 3:
                return HPTaskManager.Tuesday
            case 4:
                return HPTaskManager.Wednesday
            case 5:
                return HPTaskManager.Thursday
            case 6:
                return HPTaskManager.Friday
            case 7:
                return HPTaskManager.Saturday
            default:
                return HPTaskManager.Sunday
            }
        }
        
        public static func taskIsActive(with arg: TaskTimeArg?) -> Bool {
            guard let taskTimeArg = arg else {
                return true
            }
            let today = Date()
            if taskTimeArg.duration != nil {
                let beginDate = taskTimeArg.duration![0]
                let endDate = taskTimeArg.duration![1]
                guard today.timeIntervalSince(beginDate) < 0 else {
                    return false
                }
                guard today.timeIntervalSince(endDate) > 0 else {
                    return false
                }
            } else if taskTimeArg.weekdays != nil {
                let today = weekDay(of: Date())
                return today | taskTimeArg.weekdays! > 0
            }
            return true
        }
        public static func getLatestUpdateTime() -> String {
            let formatter = __HPTaskManagerDateFormatter()
            return formatter.string(from: Date())
        }
        public static func == (lhs: Task, rhs: Task) -> Bool {
            return lhs.key == rhs.key && lhs.user == rhs.user
        }
        public static func != (lhs: Task, rhs: Task) -> Bool {
            return lhs.key != rhs.key || lhs.user != rhs.user
        }
    }

    static let `default` = HPTaskManager()
    private var tasks: Array<Task> = []
    private let persistence = UserDefaults.standard
    private let cacheKey = "com.HPTaskManager.tasks.cacheKey"
    private let threadSafeQueue = DispatchQueue(label: "com.HPTaskManager.threadSafeQ", attributes: .concurrent)
    
    private init() {
        loadTasks()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: self, queue: nil) { (notif) in
            self.saveTasks()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillTerminate, object: self, queue: nil) { (notif) in
            self.saveTasks()
        }
    }
    
    private func saveTasks() {
        persistence.set(tasks, forKey: cacheKey)
    }
    
    private func loadTasks() {
        let caches: Array<Task> = (persistence.object(forKey: cacheKey) as? Array<Task>) ?? []
        for t in caches {
            var task = t
            let type = task.type
            let today = Task.getLatestUpdateTime()
            if type == .normal {
                if task.leftTimes > 0 { // remove completed tasks
                    tasks.append(task)
                }
            } else if type == .daily {
                if today != task.updateTime { // refresh daily task
                    task.leftTimes = task.times
                    task.updateTime = today
                }
                tasks.append(task)
            } else if type == .weekly {
                if today != task.updateTime { // refresh weekly task
                    let isSpecifiedWeekday = Task.taskIsActive(with: task.taskTimeArg)
                    task.leftTimes = isSpecifiedWeekday ? task.times : 0
                    task.updateTime = today
                }
                tasks.append(task)
            } else if type == .periodic {
                let endDate = task.taskTimeArg!.duration![1]
                if Date().timeIntervalSince(endDate) <= 0 { // remove expired task
                    tasks.append(task)
                }
            }
        }
        
    }
    
    public func register(task: Task) throws {
        let index = tasks.index(of: task)
        guard index == nil else {
            throw HPTaskManagerError.duplicatedTask(key: task.key, user: task.user)
        }
        tasks.append(task)
    }
    
    public func revoke(task: Task) throws {
        let index = tasks.index(of: task)
        guard let unwrappedIndex = index else {
            throw HPTaskManagerError.taskNotFound(key: task.key, user: task.user)
        }
        tasks.remove(at: unwrappedIndex)
    }
    
    public func complete( task: inout Task) throws {
        let index = tasks.index(of: task)
        guard index != nil else {
            throw HPTaskManagerError.taskNotFound(key: task.key, user: task.user)
        }
        guard Task.taskIsActive(with: task.taskTimeArg) != false else {
            throw HPTaskManagerError.taskInactive(key: task.key, user: task.user)
        }
        guard task.leftTimes > 0 else {
            throw HPTaskManagerError.taskHasBeenCompleted(key: task.key, user: task.user)
        }
        task.leftTimes -= 1
    }
    
}
