//
//  Date+Compare.swift
//  Tinode
//
//  Created by ztimc on 2018/10/30.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import Foundation

extension Date {
    func before(date: Date) -> Bool {
       return self.compare(date) == .orderedAscending
    }
    
    func after(date: Date) -> Bool {
        return self.compare(date) == .orderedDescending
    }
}
