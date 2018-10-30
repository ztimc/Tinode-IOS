//
//  MetaGetSub.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MetaGetSub : Codable {
    public var user: String?
    public var ims: Date?
    public var limit: Int?
    
    init() {}
    
    
    init(user: String?,
         ims: Date?,
         limit: Int?) {
        self.user = user
        self.ims = ims
        self.limit = limit
    }
}
