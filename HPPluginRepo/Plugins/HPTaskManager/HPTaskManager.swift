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
    static let OneWeek: Int = Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday
    
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
        var weekdays: Weekdays = OneWeek
    }
    
    public struct Task: Equatable {
        let type: TaskType
        let key : String
        var user: String = "com.hp.task.default.key"
        let taskTime: TaskTime
        var times: Int
        var wrappedKey: String
        
        func getWrappedKey() -> String {
            let formatter = __HPTaskManagerDateFormatter()
            let dailyPrefix = formatter.string(from: Date())
            
            switch type {
            case .daily:
                return "\(dailyPrefix)*(\(key)"
            case .weekly:
                return key
            default:
                return key
            }
            
            
        }
        
        public static func == (lhs: Task, rhs: Task) -> Bool {
            return lhs.key == rhs.key && lhs.user == rhs.user
        }
        public static func != (lhs: Task, rhs: Task) -> Bool {
            return lhs.key != rhs.key || lhs.user != rhs.user
        }
    }
    
    enum HPTaskManagerError: Error {
        case duplicatedTask(key: String, user: String)
        case taskNotFound(key: String, user: String)
    }

    
    static let `default` = HPTaskManager()
    private var tasks: Array<Task> = []
    private let cache = UserDefaults.standard
    private let cacheKey = "com.HPTaskManager.tasks.cacheKey"
    private let threadSafeQueue = DispatchQueue(label: "com.HPTaskManager.threadSafeQ", attributes: .concurrent)
    
    private override init() {
        super.init()
        loadTasks()
    }
    
    private func loadTasks() {
        let caches = cache.object(forKey: cacheKey) as? Array<Task>
        tasks = (caches ?? tasks)
    }
    
    private func saveTasks() {
        cache.set(tasks, forKey: cacheKey)
    }
    
    private func validateTasks() {
        // remove expired tasks
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
        guard index != nil else {
            throw HPTaskManagerError.taskNotFound(key: task.key, user: task.user)
        }
        tasks.remove(at: index!)
    }
    
    public func complete( task: inout Task) throws {
        let index = tasks.index(of: task)
        guard index != nil else {
            throw HPTaskManagerError.taskNotFound(key: task.key, user: task.user)
        }
        task.times -= 1
    }
    
}
