//
//  MetaGetSub.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MetaGetSub : Codable {
    var user: String
    var ims: String
    var limit: Int
    
    init(user: String,
         ims: String,
         limit: Int) {
        self.user = user
        self.ims = ims
        self.limit = limit
    }
}
