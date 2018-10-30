//
//  MsgServerMeta.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgServerMeta : Decodable {
    var id: String?
    var topic: String?
    var ts: String?
    var desc: Description?
    var sub: [Subscription]?
    var tags: [String]?
    var del: DelValues?
    
    
}
