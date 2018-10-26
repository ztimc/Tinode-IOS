//
//  MeTopic.swift
//  Tinode
//
//  Created by ztimc on 2018/10/23.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public class MeTopic<DP: Codable>: Topic<DP, Dictionary<String,String>, DP, Dictionary<String,String>> {
    
    public init(tinode: Tinode, delegate: TopicDelegete?) {
        super.init(tinode: tinode, name: Tinode.TOPIC_ME, delegate: delegate)
    }
    
    override init(tinode: Tinode, name: String, desc: Description<DP, Dictionary<String,String>>) {
        super.init(tinode: tinode, name: name, desc: desc)
    }
    
    
    override public func routeMeta(meta: MsgServerMeta<DP, Dictionary<String, String>, DP, Dictionary<String, String>>) {
        if let subs = meta.sub {
            for sub in subs {
                let topic: Topic<DP,Dictionary<String, String>,DP,Dictionary<String, String>>? = tinode.getTopic(name: sub.topic!)
                
                if topic != nil {
                    if sub.deleted != nil {
                        tinode.unregisterTopic(topicName: sub.topic!)
                    } else {
                        topic?.update(sub: sub)
                        
                        delegeta?.onContUpdate(sub: sub)
                    }
                } else if sub.deleted == nil {
                    let t:Topic<DP,Dictionary<String, String>,DP,Dictionary<String, String>> = tinode.newTopic(sub: sub)
                    tinode.registerTopic(topic: t)
                    
                    delegeta?.onMetaSub(sub: sub)
                }
                
                delegeta?.onSubsUpdated()
                
            }
        }
    }
    
}
