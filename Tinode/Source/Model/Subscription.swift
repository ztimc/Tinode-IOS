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
    
    var seq:   Int = 0
    var read:  Int = 0
    var recv:  Int = 0
    var clear: Int = 0
    
    var online: Bool = false
    
    var acs:  Acs?
    var seen: LastSeen?
    
    var priv: JSON?
    var pub:  JSON?
    
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
        
        if sub.priv != nil {
            priv = sub.priv
        }
        
        online = sub.online
        
        if (topic == nil || topic == "") && sub.topic != nil && sub.topic != "" {
            topic = sub.topic
            changed += 1
        }
        
        if sub.seq > seq {
            seq = sub.seq
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
                acs?.given = AcsHelper(a: sub.mode!)
                changed += 1
            }
        } else {
            if sub.mode != nil {
                acs?.want = AcsHelper(a: sub.mode!)
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
