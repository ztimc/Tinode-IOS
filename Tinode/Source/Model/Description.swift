//
//  Description.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct Description<DP: Codable, DR: Codable> : Codable {
    
    var created: String?
    var updated: String?
    var touched: String?
    var topic  : String?
    
    var seq:   Int = 0
    var read:  Int = 0
    var recv:  Int = 0
    var clear: Int = 0
    
    var defacs: Defacs?
    var acs: Acs?
    var pub: DP?
    var priv: DR?
    
    init() {}
    
    @discardableResult
    mutating func merge(desc: Description<DP,DR>) -> Bool {
        var changed = 0
        
        if created == nil && desc.created != nil {
            created = desc.created
            changed += 1
        }
        
        if desc.updated != nil && (updated == nil || (updated!.compareDate(date: desc.updated) == .orderedAscending)){
            updated = desc.updated
            changed += 1
        }
        
        if desc.touched != nil && (touched == nil || (touched!.compareDate(date: desc.touched) == .orderedAscending)) {
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
    public mutating func merge<SP, SR>(sub: Subscription<SP,SR>) -> Bool {
        var changed = 0
        
        if let subUpdated = Formatter.iso8601.date(from: sub.updated ?? "") {
            if updated == nil {
                updated = Formatter.iso8601.string(from: subUpdated)
                changed += 1
            }
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
            pub = sub.pub as? DP
            if pub != nil {
                changed += 1
            }
        }
        
        if sub.priv != nil {
            priv = sub.priv as? DR
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
