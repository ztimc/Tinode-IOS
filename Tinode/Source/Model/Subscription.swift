//
//  Subscription.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct Subscription<SP: Codable,SR : Codable> {
    var user:    String?
    var created: String?
    var updated: String?
    var touched: String?
    var topic:   String?
    
    var seq:   Int = 0
    var read:  Int = 0
    var recv:  Int = 0
    var clear: Int = 0
    
    var online: Bool = false
    
    var acs:  Acs?
    var seen: LastSeen?
    
    var priv: SR?
    var pub:  SP?
    
    
}
