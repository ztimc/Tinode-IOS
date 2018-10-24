//
//  Acs.swift
//  Tinode
//
//  Created by ztimc on 2018/10/18.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct AcsHelper: Codable {
    var a: Int?
    
    init(a: String) {
        self.a = Int(a)
    }
    
    init(ah: AcsHelper?) {
        a = ah?.a
    }
    
    init(a: Int) {
        self.a = a
    }
    
   
    
    public func update(umode: String) -> Bool {
        return true
    }
    
    public func equals(ah: AcsHelper?) -> Bool {
        if let a1 = ah?.a, let a2 = self.a {
            return a1 == a2
        }
        return false
    }
    
    public mutating func merge(ah: AcsHelper?) -> Bool{
        if ah != nil && ah?.a != nil && ah!.a != AccessMode.invalid.rawValue {
            if let a1 = ah?.a, let a2 = self.a {
                if !(a1 == a2) {
                    self.a = ah?.a
                    return true
                }
            }
        }
        return false
    }
    
    public func isReader() -> Bool {
        return a == nil && ((a! & AccessMode.read.rawValue) != 0)
    }
    
    public func isWriter() -> Bool {
        return a == nil && ((a! & AccessMode.write.rawValue) != 0)
    }
    
    public func isMuted() -> Bool {
        return a == nil && ((a! & AccessMode.pres.rawValue) != 0)
    }
    
    public func isAdmin() -> Bool {
        return a == nil && ((a! & AccessMode.approve.rawValue) != 0)
    }
    
    public func isDeleter() -> Bool {
        return a == nil && ((a! & AccessMode.delete.rawValue) != 0)
    }
    
    public func isOwner() -> Bool {
        return a == nil && ((a! & AccessMode.owner.rawValue) != 0)
    }
    
    public func isJoiner() -> Bool {
        return a == nil && ((a! & AccessMode.join.rawValue) != 0)
    }
    
    public func isDefined() -> Bool {
        return a != nil && a != AccessMode.none.rawValue && a != AccessMode.invalid.rawValue
    }
    
    public func isInvalid() -> Bool {
        return a != nil && a == AccessMode.invalid.rawValue
    }
    
    // TODO: 权限处理
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

extension AcsHelper {
    static func and(a1: AcsHelper?, a2: AcsHelper?) -> AcsHelper? {
        if let ah1 = a1, let ah2 = a2 {
             return AcsHelper(a: ah1.a! & ah2.a!)
        }
        return nil
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
    case invalid = 0x100000
}
