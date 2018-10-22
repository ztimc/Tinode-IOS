//
//  MsgServerMeta.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgServerMeta<DP: Codable, DR: Codable, SP: Codable, SR: Codable> {
    var id: String?
    var topic: String?
    var ts: String?
    var desc: Description<DP,DR>?
    var sub: [Subscription<SP,SR>]?
    var tags: [String]?
    var del: DelValues?
}
