//
//  MsgServerMeta.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgServerMeta : Decodable {
    public var id: String?
    public var topic: String?
    public var ts: String?
    public var desc: Description?
    public var sub: [Subscription]?
    public var tags: [String]?
    public var del: DelValues?
    
}
