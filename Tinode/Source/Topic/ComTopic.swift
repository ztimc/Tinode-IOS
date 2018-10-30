//
//  ComTopic.swift
//  Tinode
//
//  Created by ztimc on 2018/10/27.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import Foundation

public class ComTopic: Topic {
    
    public override init(tinode: Tinode, sub: Subscription) {
        super.init(tinode: tinode, sub: sub)
    }
    
    override init(tinode: Tinode, name: String, desc: Description) {
        super.init(tinode: tinode, name: name, desc: desc)
    }
    
    public func getComment() -> String? {
        if let p = super.getPriv() {
            return p.getStringValue(key: "comment")
        }
        return nil
    }
    
}
