//
//  MsgServerPres.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgServerPres: Codable {
    var topic: String?
    var src: String?
    var what: String?
    var seq: Int?
    var clear: Int?
    var delseq: [MsgDelRange]?
    var ua: String?
    var act: String?
    var tgt: String?
    var dacs: AccessChange?
}

public enum What: String {
    case on, off, upd, gone, acs, msg, ua, recv, read, del, unknown
}
