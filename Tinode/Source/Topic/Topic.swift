//
//  Topic.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public class Topic<DP: Codable, DR: Codable, SP: Codable, SR: Codable> {
    
    var tinode:  Tinode
    var name:    String?
    var storage: Storage?
    
    var desc:        Description<DP,DR>?
    var subs:        Dictionary<String, Subscription<SP,SR>>?
    var subsUpdated: Date?
    var tags:        [String]?
    
    var attached: Bool = false
    var lastKeyPress: Int64 = 0
    var isOnline = false
    var lastSeen: LastSeen?
    var maxDel: Int64 = 0
    
    init(tinode: Tinode, sub: Subscription<SP,SR>) {
        self.tinode   = tinode
        self.name     = sub.topic
        self.isOnline = sub.online
        self.desc     = Description<DP,DR>()
        self.desc?.merge(sub: sub)
    }
    
    init(tinode: Tinode, name: String, desc: Description<DP,DR>) {
        self.tinode = tinode
        self.name   = name
        self.desc     = Description<DP,DR>()
        self.desc?.merge(desc: desc)
    }
    
}

public enum TopicType : Int {
    case me   = 0x01
    case fnd  = 0x02
    case grp  = 0x04
    case p2p  = 0x08
    // grp | p2p
    case user = 0x0C
    // me | fnd
    case system = 0x03
    // me | fnd | grp | p2p
    case any = 0x0F
}

public enum NoteType {
    case read
    case recv
}
