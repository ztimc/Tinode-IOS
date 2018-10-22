//
//  MsgGetMeta.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgGetMeta : Codable {
    var what: String
    var desc: MetaGetDesc
    var sub:  MetaGetSub
    var data: MetaGetData
    var del:  MetaGetData
    
}
