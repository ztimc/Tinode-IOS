//
//  MeTopic.swift
//  Tinode
//
//  Created by ztimc on 2018/10/23.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public class MeTopic: Topic {
    
    public init(tinode: Tinode) {
        super.init(tinode: tinode, name: Tinode.TOPIC_ME)
    }
    
    public init(tinode: Tinode, desc: Description) {
        super.init(tinode: tinode, name: Tinode.TOPIC_NEW, desc: desc)
    }

    override public func routeMeta(meta: MsgServerMeta) {
        if let subs = meta.sub {
            for sub in subs {
                let topic: Topic? = tinode.getTopic(name: sub.topic!)
                
                if topic != nil {
                    if sub.deleted != nil {
                        tinode.unregisterTopic(topicName: sub.topic!)
                    } else {
                        topic?.update(sub: sub)
                        
                        onContUpdate?(sub)
                    }
                } else if sub.deleted == nil {
                    let t:Topic = tinode.newTopic(sub: sub)
                    tinode.registerTopic(topic: t)
                    
                    onMetaSub?(sub)
                }
                
            }
            onSubsUpdated?()
        }
    }
    
}
