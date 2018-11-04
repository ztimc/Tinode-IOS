//
//  MsgClientPub.swift
//  Tinode
//
//  Created by ztimc on 2018/11/2.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import Foundation

struct MsgClientPub: Codable {
    
    var id: String
    var topic: String
    var noecho: Bool
    var head: Dictionary<String,String>?
    var content: Content
    
    init(id: String, topic: String, noecho: Bool, content: Content) {
        self.id = id
        self.topic = topic
        self.noecho = noecho
        self.content = content
    }
    
}
