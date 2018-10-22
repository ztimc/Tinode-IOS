//
//  MsgServerData.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgServerData {
    
    var id: String
    var topic: String
    var from: String
    var ts: String
    var seq: Int
    var content: Drafty
    
    var head: Dictionary<String, JSON>
    
}
