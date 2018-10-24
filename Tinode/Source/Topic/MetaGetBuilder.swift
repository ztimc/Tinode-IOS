//
//  MetaGetBuilder.swift
//  Tinode
//
//  Created by ztimc on 2018/10/23.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public class MetaGetBuilder<DP: Codable, DR: Codable, SP: Codable, SR: Codable> {
    let topic: Topic<DP,DR,SP,SR>
    var meta: MsgGetMeta
    
    init(topic: Topic<DP,DR,SP,SR>) {
        self.topic = topic
        self.meta  = MsgGetMeta()
    }
    
    public func withGetData() -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setData()
        return self
    }
    public func withGetData(limit: Int) -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setData(limit: limit)
        return self
    }
    
    public func withGetData(since: Int, limit: Int) -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setData(since: since, limit: limit)
        return self
    }
    
    public func withGetData(since: Int, before: Int, limit: Int) -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setData(since: since, before: before, limit: limit)
        return self
    }
    
    public func withGetLaterData(limit: Int) -> MetaGetBuilder<DP,DR,SP,SR> {
        if let r = topic.getCachedMessageRange(), r.max > 0 {
            return withGetData(since: r.max+1, limit: limit)
        } else {
            return withGetData(limit: limit)
        }
    }
    
    public func withGetEarlierData(limit: Int) -> MetaGetBuilder<DP,DR,SP,SR> {
        if let r = topic.getCachedMessageRange(), r.min > 0 {
            return withGetData(since: r.min, limit: limit)
        } else {
            return withGetData(limit: limit)
        }
    }
    
    public func withGetDesc(ims: String) -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setDesc(date: ims)
        return self
    }
    
    public func withGetDesc() -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setDesc(date: topic.getUpdated()!)
        return self
    }
    
    public func withGetSub(user: String, ims: String, limit: Int) -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setSub(user: user, ims: ims, limit: limit)
        return self
    }
    
    public func withGetSub(user: String, limit: Int) -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setSub(user: user, ims: nil, limit: limit)
        return self
    }
    
    public func withGetSub(user: String) -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setSub(user: user, ims: nil, limit: nil)
        return self
    }
    
    public func withGetSub() -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setSub(user: nil, ims: topic.subsUpdated, limit: nil)
        return self
    }
    
    public func withGetDel(since: Int, limit: Int) -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setDel(since: since, limit: limit)
        return self
    }
    
    public func withGetLaterDel(limit: Int) -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setDel(since: topic.maxDel + 1, limit: limit)
        return self
    }
    
    public func withGetDel() -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setDel(since: nil, limit: nil)
        return self
    }

    public func withGetTags() -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setTags()
        return self
    }
    
    public func build() -> MsgGetMeta {
        return meta
    }
    
}
