//
//  MsgClientGet.swift
//  Tinode
//
//  Created by ztimc on 2018/10/24.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgClientGet: Codable {
    var id:    String
    var topic: String
    var what:  String?
    
    var desc: MetaGetDesc?
    var sub: MetaGetSub?
    var data: MetaGetData?
    
    public init(id: String, topic: String, query: MsgGetMeta) {
        self.id = id
        self.topic = topic
        self.what  = query.what
        self.desc  = query.desc
        self.sub   = query.sub
        self.data  = query.data
    }
}
