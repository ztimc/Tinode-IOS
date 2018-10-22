//
//  MetaSetSub.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MetaSetSub : Codable {
    var user: String
    var mode: String
    
    public init(user: String, mode: String) {
        self.user = user
        self.mode = mode
    }
}
