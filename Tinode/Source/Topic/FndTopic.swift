//
//  FndTopic.swift
//  Tinode
//
//  Created by ztimc on 2018/10/30.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import Foundation

public class FndTopic: Topic {
    
    public init(tinode: Tinode) {
        super.init(tinode: tinode, name: Tinode.TOPIC_FND)
    }
    
    public override func addSubToCache(sub: Subscription) {
        if subs == nil {
            subs = Dictionary<String, Subscription>()
        }
    }
    
    
}
