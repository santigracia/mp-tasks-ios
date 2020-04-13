//
//  Task.swift
//  MPTasks
//
//  Created by Santi Gracia on 4/10/20.
//  Copyright © 2020 Mixpanel. All rights reserved.
//

import Foundation

// Model for Task
public class Task {
    
    var id : Int = 0
    var taskName : String = ""
    var completed : Bool = false
    
    init(id : Int, taskName : String, completed : Bool) {
        self.id = id
        self.taskName = taskName
        self.completed = completed
    }
    
}
