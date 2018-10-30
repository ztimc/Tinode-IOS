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
    
    var seq:   Int?
    var read:  Int?
    var recv:  Int?
    var clear: Int?
    
    var defacs: Defacs?
    var acs: Acs?
    var pub: JSON?
    var priv: JSON?
    
    enum CodingKeys : String, CodingKey {
        case created = "created"
        case updated = "updated"
        case touched = "touched"
        case defacs  = "defacs"
        case acs     = "acs"
        case seq     = "seq"
        case read    = "read"
        case recv    = "recv"
        case clear   = "clear"
        case pub     = "public"
        case priv    = "private"
    }

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
        
        if let q1 = desc.seq, let q2 = seq {
            if q1 > q2 {
                seq = desc.seq
                changed += 1
            }
        }
        
        if let r1 = desc.read, let r2 = read {
            if r1 > r2 {
                read = desc.read
                changed += 1
            }
        }
        
        if let re1 = desc.recv, let re2 = recv {
            if re1 > re2 {
                recv = desc.recv
                changed += 1
            }
        }
        
        if let c1 = desc.clear, let c2 = clear {
            if c1 > c2 {
                clear = desc.clear
                changed += 1
            }
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
        
        if let q1 = sub.seq, let q2 = seq {
            if q1 > q2 {
                seq = sub.seq
                changed += 1
            }
        }
        
        if let r1 = sub.read, let r2 = read {
            if r1 > r2 {
                read = sub.read
                changed += 1
            }
        }
        
        if let re1 = sub.recv, let re2 = recv {
            if re1 > re2 {
                recv = sub.recv
                changed += 1
            }
        }
        
        if let c1 = sub.clear, let c2 = clear {
            if c1 > c2 {
                clear = sub.clear
                changed += 1
            }
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
    
    
}
