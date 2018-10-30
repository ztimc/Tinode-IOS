//
//  MetaGetBuilder.swift
//  Tinode
//
//  Created by ztimc on 2018/10/23.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public class MetaGetBuilder {
    let topic: Topic
    var meta: MsgGetMeta
    
    init(topic: Topic) {
        self.topic = topic
        self.meta  = MsgGetMeta()
    }
    
    public func withGetData() -> MetaGetBuilder {
        meta.setData()
        return self
    }
    public func withGetData(limit: Int) -> MetaGetBuilder {
        meta.setData(limit: limit)
        return self
    }
    
    public func withGetData(since: Int, limit: Int) -> MetaGetBuilder {
        meta.setData(since: since, limit: limit)
        return self
    }
    
    public func withGetData(since: Int, before: Int, limit: Int) -> MetaGetBuilder {
        meta.setData(since: since, before: before, limit: limit)
        return self
    }
    
    public func withGetLaterData(limit: Int) -> MetaGetBuilder {
        if let r = topic.getCachedMessageRange(), r.max > 0 {
            return withGetData(since: r.max+1, limit: limit)
        } else {
            return withGetData(limit: limit)
        }
    }
    
    public func withGetEarlierData(limit: Int) -> MetaGetBuilder {
        if let r = topic.getCachedMessageRange(), r.min > 0 {
            return withGetData(since: r.min, limit: limit)
        } else {
            return withGetData(limit: limit)
        }
    }
    
    public func withGetDesc(ims: Date) -> MetaGetBuilder {
        meta.setDesc(date: ims)
        return self
    }
    
    public func withGetDesc() -> MetaGetBuilder {
        meta.setDesc(date: topic.getUpdated())
        return self
    }
    
    public func withGetSub(user: String, ims: Date, limit: Int) -> MetaGetBuilder  {
        meta.setSub(user: user, ims: ims, limit: limit)
        return self
    }
    
    public func withGetSub(user: String, limit: Int) -> MetaGetBuilder {
        meta.setSub(user: user, ims: nil, limit: limit)
        return self
    }
    
    public func withGetSub(user: String) -> MetaGetBuilder {
        meta.setSub(user: user, ims: nil, limit: nil)
        return self
    }
    
    public func withGetSub() -> MetaGetBuilder {
        meta.setSub(user: nil, ims: topic.subsUpdated, limit: nil)
        return self
    }
    
    public func withGetDel(since: Int, limit: Int) -> MetaGetBuilder {
        meta.setDel(since: since, limit: limit)
        return self
    }
    
    public func withGetLaterDel(limit: Int) -> MetaGetBuilder {
        meta.setDel(since: topic.maxDel + 1, limit: limit)
        return self
    }
    
    public func withGetDel() -> MetaGetBuilder {
        meta.setDel(since: nil, limit: nil)
        return self
    }

    public func withGetTags() -> MetaGetBuilder {
        meta.setTags()
        return self
    }
    
    public func build() -> MsgGetMeta {
        return meta
    }
    
}
