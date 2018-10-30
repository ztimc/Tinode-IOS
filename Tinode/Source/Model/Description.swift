//
//  Description.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct Description : Decodable {
    
    var created: Date?
    var updated: Date?
    var touched: Date?
    var topic  : Date?
    
    var seq:   Int = 0
    var read:  Int = 0
    var recv:  Int = 0
    var clear: Int = 0
    
    var defacs: Defacs?
    var acs: Acs?
    var pub: JSON?
    var priv: JSON?
    
    init() {}
    
    @discardableResult
    mutating func merge(desc: Description) -> Bool {
        var changed = 0
        
        if created == nil && desc.created != nil {
            created = desc.created
            changed += 1
        }
        
        if desc.updated != nil && (updated == nil || updated!.before(date: desc.updated!)){
            updated = desc.updated
            changed += 1
        }
        
        if desc.touched != nil && (touched == nil || touched!.before(date: desc.touched!)) {
            touched = desc.touched
            changed += 1
        }
        
        
        //TODO: Merge defacs
        if desc.acs != nil {
            if acs == nil {
                acs = desc.acs
                changed += 1
            } else {
                //TODO: Merge acs
            }
        }
        
        if desc.seq > seq {
            seq = desc.seq
            changed += 1
        }
        
        if desc.read > read {
            read = desc.read
            changed += 1
        }
        
        if desc.recv > recv {
            recv = desc.recv
            changed += 1
        }
        
        if desc.clear > clear {
            clear = desc.clear
            changed += 1
        }
        
        if desc.pub != nil {
            pub = desc.pub
            changed += 1
        }
        
        if desc.priv != nil {
            priv = desc.priv
        }
        
        return changed > 0
    }
    
    @discardableResult
    public mutating func merge(sub: Subscription) -> Bool {
        var changed = 0
        
        if sub.updated != nil && (updated == nil || updated!.before(date: sub.updated!)){
            updated = sub.updated
            changed += 1
        }
        
        if sub.seq > seq {
            seq = sub.seq
            changed += 1
        }
        
        if sub.read > read {
            read = sub.read
            changed += 1
        }
        
        if sub.recv > recv {
            recv = sub.recv
            changed += 1
        }
        
        if sub.clear > clear {
            clear = sub.clear
            changed += 1
        }
        
        if sub.pub != nil {
            pub = sub.pub
            if pub != nil {
                changed += 1
            }
        }
        
        if sub.priv != nil {
            priv = sub.priv
            if priv != nil {
                changed += 1
            }
        }
        
        return changed > 0
    }
    
    enum CodingKeys : String, CodingKey {
        case created = "created"
        case updated = "updated"
        case touched = "touched"
        case topic   = "topic"
        case defacs  = "defacs"
        case acs     = "acs"
        case seq     = "seq"
        case read    = "read"
        case recv    = "recv"
        case clear   = "clear"
        case pub     = "public"
        case priv    = "private"
    }
}
