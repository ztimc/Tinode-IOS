//
//  MsgServerInfo.swift
//  Tinode
//
//  Created by ztimc on 2018/10/29.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import Foundation

public struct MsgServerInfo: Codable {
    public var topic: String?
    public var from: String?
    public var what: String?
    public var seq: Int?
}
