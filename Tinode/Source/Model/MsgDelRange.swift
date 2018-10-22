//
//  File.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgDelRange: Codable {
    var low: Int?
    var hi:  Int?
    
    init(id: Int) {
        low = id
    }
    
    init(low: Int, hi: Int) {
        self.low = low
        self.hi  = hi
    }
}
