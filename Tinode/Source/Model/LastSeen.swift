//
//  LastSeen.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct LastSeen {
    var when: String?
    var ua: String?
    
    public mutating func merge(seen: LastSeen?) -> Bool {
        guard let sn = seen else {return false}
        
        if sn.when != nil && (when == nil || when?.compareDate(date: sn.when) == .orderedAscending) {
                when = sn.when
                ua   = sn.ua
                return true
        }
        
        return false
    }
}
