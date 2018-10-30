//
//  Subscription.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct Subscription: Decodable {
    var user:    String?
    var deleted: Date?
    var updated: Date?
    var touched: Date?
    var topic:   String?
    
    var seq:   Int?
    var read:  Int?
    var recv:  Int?
    var clear: Int?
    
    var online: Bool?
    
    var acs:  Acs?
    var seen: LastSeen?
    
    var priv: JSON?
    var pub:  JSON?
    
    enum CodingKeys : String, CodingKey {
        case user    = "user"
        case deleted = "deleted"
        case updated = "updated"
        case touched = "touched"
        case topic   = "topic"
        case seq     = "seq"
        case read    = "read"
        case recv    = "recv"
        case clear   = "clear"
        case online  = "online"
        case acs     = "acs"
        case seen    = "seen"
        case pub     = "public"
        case priv    = "private"
    }
    
    @discardableResult
    public mutating func merge(sub: Subscription) -> Bool {
        var changed = 0
        
        if let u = sub.user, user == nil {
            user = u
            changed += 1
        }
        
        if (sub.updated != nil) && (updated == nil || ((updated?.before(date: sub.updated!))!)) {
            updated = sub.updated
            
            if sub.pub != nil {
                pub = sub.pub
            }
            
            changed += 1
        }else if pub == nil && sub.pub != nil {
            pub = sub.pub
        }
        
        if (sub.touched != nil) && (touched != nil || ((touched?.before(date: sub.touched!))!)) {
            touched = sub.touched
        }
        
        if sub.acs != nil {
            if acs == nil {
                acs = Acs(acs: sub.acs!)
                changed += 1
            } else {
                if acs!.merge(am: sub.acs) {
                    changed += 1
                }
            }
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
        
        
        if sub.priv != nil {
            priv = sub.priv
        }
        
        online = sub.online
        
        if (topic == nil || topic == "") && sub.topic != nil && sub.topic != "" {
            topic = sub.topic
            changed += 1
        }
        
       
        
        if sub.seen != nil {
            if seen == nil {
                seen = sub.seen
                changed += 1
            } else {
                if seen!.merge(seen: sub.seen!) {
                    changed += 1
                }
            }
        }
        
        return changed > 0
    }
    
    @discardableResult
    public mutating func merge(sub: MetaSetSub) -> Bool {
        var changed = 0
        
        if sub.mode != nil && acs == nil {
            acs = Acs()
        }
        
        if sub.user != nil && sub.user != "" {
            if user == nil {
                user = sub.user
                changed += 1
            }
            
            if sub.mode != nil {
                acs?.given = sub.mode
                changed += 1
            }
        } else {
            if sub.mode != nil {
                acs?.want = sub.mode!
                changed += 1
            }
        }
        
        return changed > 0
    }
    
    public mutating func updateAccessMode(ac: AccessChange) {
        if acs == nil {
            acs = Acs()
        }
        acs?.update(ac: ac)
    }
}
