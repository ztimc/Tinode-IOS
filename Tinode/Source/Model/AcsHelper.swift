//
//  Acs.swift
//  Tinode
//
//  Created by ztimc on 2018/10/18.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

struct AcsHelper: Codable {
    var a: Int?
    
    init(a: String) {
        self.a = Int(a)
    }
    
    init(ah: AcsHelper) {
        a = ah.a
    }
    
    init(a: Int) {
        self.a = a
    }
    
    func update(umode: String) {
        
    }
    
    static func update(val: Int, umode: String?) -> Int{
        guard let mode = umode, mode.count > 0 else {
            return val
        }
        
        
        let action = mode[mode.startIndex]
        
        if action == "+" || action == "-" {
            
        }
        
        return 0;
    }
}

enum AccessMode: Int {
    case none = 0x00
    case join = 0x01
    case read = 0x02
    case write = 0x04
    case pres = 0x08
    case approve = 0x10
    case share = 0x20
    case delete = 0x40
    case owner = 0x80
    case INVALID = 0x100000
}
