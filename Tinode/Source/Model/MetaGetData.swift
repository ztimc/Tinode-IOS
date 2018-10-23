//
//  MetaGetData.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MetaGetData : Codable {
    var since:  Int?
    var before: Int?
    var limit:  Int?
    
    init(since:  Int,
         before: Int,
         limit:  Int) {
        self.since  = since
        self.before = before
        self.limit  = limit
    }
    
    init(since:  Int,
         limit:  Int) {
        self.since  = since
        self.limit  = limit
    }
    
    init(limit:  Int) {
        self.limit  = limit
    }
    
    init() {}
}
