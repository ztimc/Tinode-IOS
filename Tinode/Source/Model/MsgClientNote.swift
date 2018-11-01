//
//  MsgClientNote.swift
//  Tinode
//
//  Created by ztimc on 2018/11/1.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import Foundation

struct MsgClientNote: Codable {
    let topic: String
    let what: String
    let seq: Int
    
    init(topic: String, what: String, seq: Int) {
        self.topic = topic
        self.what = what
        self.seq = seq
    }
}
