//
//  MsgServerData.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgServerData: Decodable {
    
    public var id: String?
    public var topic: String?
    public var from: String?
    public var ts: String?
    public var seq: Int?
    public var content: JSON?
    
}
