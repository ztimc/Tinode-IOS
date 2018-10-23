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
    
    
    public func withGetData(user: String, ims: String, limit: Int) -> MetaGetBuilder<DP,DR,SP,SR> {
        meta.setSub(user: user, ims: ims, limit: limit)
        return self
    }
    
}
