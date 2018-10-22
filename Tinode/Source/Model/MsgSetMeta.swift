//
//  MsgSetMate.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgSetMeta<Pu: Codable,Pr: Codable> : Codable{
    var desc: MetaSetDesc<Pu,Pr>
    var sub: MetaSetSub
    var tags: [String]
    
    init(desc: MetaSetDesc<Pu,Pr>,
         sub: MetaSetSub,
         tags: [String]) {
        self.desc = desc
        self.sub  = sub
        self.tags = tags
    }
}
