//
//  String+Acs.swift
//  Tinode
//
//  Created by ztimc on 2018/10/30.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import Foundation


extension String {
    
    mutating func merge(_ ace: String?) -> Bool {
        if let a = ace {
            if self != a{
                self = a
                return true
            }
        }
        return false
    }
    
    static func and(_ a1: String?, a2: String?) -> String? {
        let ah1 = AcsHelper(a: a1!)
        let ah2 = AcsHelper(a: a2!)
        
        let result = AcsHelper.and(a1: ah1, a2: ah2)
        
        return AcsHelper.encode(val: result?.a)
    }
    
    
    public func update(_ umode: String) -> Bool {
        // TODO: 需要补充
        return true
    }
    
    
    public func isReader() -> Bool {
        return self.contains("R") || self.contains("r")
    }
    
    public func isWriter() -> Bool {
        return self.contains("W") || self.contains("w")
    }
    
    public func isMuted() -> Bool {
        return self.contains("P") || self.contains("p")
    }
    
    public func isAdmin() -> Bool {
        return self.contains("A") || self.contains("a")
    }
    
    public func isDeleter() -> Bool {
        return self.contains("D") || self.contains("d")
    }
    
    public func isOwner() -> Bool {
         return self.contains("O") || self.contains("o")
    }
    
    public func isJoiner() -> Bool {
        return self.contains("J") || self.contains("j")
    }
    
    public func isDefined() -> Bool {
        return self.contains("N") || self.contains("n")
    }
    
    public func isInvalid() -> Bool {
        return self == ""
    }
    
    
    
}


