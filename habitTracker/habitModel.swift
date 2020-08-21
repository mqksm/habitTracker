//
//  habitModel.swift
//  habit tracker
//
//  Created by Maks on 18.08.2020.
//  Copyright © 2020 Maxim. All rights reserved.
//

import Foundation

struct Habit {
    var tittle: String
    var isDone: Bool = false
    var dayCheck = Array(repeating: false, count: 30)
    
}
