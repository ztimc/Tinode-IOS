//
//  MsgGetMeta.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgGetMeta : Codable {
    
    private static let DESC_SET = 0x01
    private static let SUB_SET  = 0x02
    private static let DATA_SET = 0x04
    private static let DEL_SET  = 0x08
    private static let TAGS_SET = 0x10
    
    public static let DESC = "desc";
    public static let SUB = "sub";
    public static let DATA = "data";
    public static let DEL = "del";
    public static let TAGS = "tags";
    
    var what: String?
    var desc: MetaGetDesc?
    var sub:  MetaGetSub?
    var data: MetaGetData?
    var del:  MetaGetData?
    
    var set: Int = 0
    
    init() {
        self.what = MsgGetMeta.DESC + " " + MsgGetMeta.SUB + " " + MsgGetMeta.DATA + " " + MsgGetMeta.DEL + " " + MsgGetMeta.TAGS
    }
    
    public mutating func setDesc(date: Date?) {
        self.desc?.ims = date
        set |= MsgGetMeta.DESC_SET
        buildWhat()
    }
    
    public mutating func setSub(user: String?, ims: Date?, limit: Int?) {
        sub  = MetaGetSub(user: user, ims: ims, limit: limit)
        set |= MsgGetMeta.SUB_SET
        buildWhat()
    }
    
    public mutating func setData(since: Int, before: Int, limit: Int) {
        data = MetaGetData(since: since, before: before, limit: limit)
        set |= MsgGetMeta.DATA_SET
        buildWhat()
    }
    
    public mutating func setData(since: Int, limit: Int) {
        data = MetaGetData(since: since, limit: limit)
        set |= MsgGetMeta.DATA_SET
        buildWhat()
    }
    
    public mutating func setData() {
        data = MetaGetData()
        set |= MsgGetMeta.DATA_SET
        buildWhat()
    }
    
    public mutating func setData(limit: Int) {
        data = MetaGetData(limit: limit)
        set |= MsgGetMeta.DATA_SET
        buildWhat()
    }
    
    public mutating func setDel(since: Int?, limit: Int?) {
        del = MetaGetData(since: since, limit: limit)
        set |= MsgGetMeta.DEL_SET
        buildWhat()
    }
    
    public mutating func setTags() {
        set |= MsgGetMeta.TAGS_SET
        buildWhat()
    }
    
    public mutating func buildWhat() {
        var parts = [String]()
        
        if desc != nil || (set & MsgGetMeta.DESC_SET) != 0 {
            parts.append(MsgGetMeta.DESC)
        }
        if sub != nil || (set & MsgGetMeta.SUB_SET) != 0 {
            parts.append(MsgGetMeta.SUB)
        }
        if data != nil || (set & MsgGetMeta.DATA_SET) != 0 {
            parts.append(MsgGetMeta.DATA)
        }
        if del != nil || (set & MsgGetMeta.DEL_SET) != 0 {
            parts.append(MsgGetMeta.DEL)
        }
        if (set & MsgGetMeta.TAGS_SET) != 0 {
            parts.append(MsgGetMeta.TAGS)
        }
        
        if parts.count > 0 {
            what = ""
            what?.append(parts[0])
            if parts.count > 1 {
                for index in 1...(parts.count-1) {
                    what?.append(" ")
                    what?.append(parts[index])
                }
            }
        }
    }
}
