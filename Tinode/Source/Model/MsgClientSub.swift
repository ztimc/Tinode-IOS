//
//  MsgClientSub.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgClientSub<Pu:Codable, Pr:Codable> : Codable {
    var id: String
    var topic: String
    var set: MsgSetMeta<Pu,Pr>
    var get: MsgGetMeta
    
    init(id: String,
         topic: String,
         set: MsgSetMeta<Pu,Pr>,
         get: MsgGetMeta) {
        self.id    = id
        self.topic = topic
        self.set   = set
        self.get   = get
    }
}
