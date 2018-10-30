//
//  User.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct User: Decodable {
    var updated: Date?
    var uid: String?
    var pub: JSON?
    
    init() {}
    
    init(uid: String) {
        self.uid = uid
    }
    
    init(sub: Subscription) {
        if sub.user != nil && sub.user?.count ?? -1 > 0{
            uid = sub.user
            updated = sub.updated
            pub = sub.pub
        }
    }
    
    init(uid: String, desc: Description) {
        self.uid = uid
        self.updated = desc.updated
        pub = desc.pub
    }
    @discardableResult
    public mutating func merge(user: User) -> Bool {
        var changed = false
        if user.updated != nil && (updated == nil || updated!.before(date: user.updated!)) {
            updated = user.updated
            if user.pub != nil {
                pub = user.pub
            }
            changed = true
        } else if (pub == nil && user.pub != nil){
            pub = user.pub
            changed = true
        }
        return changed
    }
    
    @discardableResult
    public mutating func merge(sub: Subscription) -> Bool {
        var changed = false
        if sub.updated != nil && (updated == nil || updated!.before(date: sub.updated!)) {
            updated = sub.updated
            if sub.pub != nil {
                pub = sub.pub
            }
            changed = true
        } else if (pub == nil && sub.pub != nil){
            pub = sub.pub
            changed = true
        }
        return changed
    }
    
    
    @discardableResult
    public mutating func merge(desc: Description) -> Bool {
        var changed = false
        if desc.updated != nil && (updated == nil || updated!.before(date: desc.updated!)) {
            updated = desc.updated
            if desc.pub != nil {
                pub = desc.pub
            }
            changed = true
        } else if (pub == nil && desc.pub != nil){
            pub = desc.pub
            changed = true
        }
        return changed
    }
    
    
    
}
