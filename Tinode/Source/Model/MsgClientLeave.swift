//
//  MsgClientLeave.swift
//  Tinode
//
//  Created by ztimc on 2018/11/1.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import Foundation

struct MsgClientLeave: Codable {
    let id: String
    let topic: String
    let unsub: Bool
    
    init(id: String, topic: String, unsub: Bool) {
        self.id = id
        self.topic = topic
        self.unsub = unsub
    }
}
