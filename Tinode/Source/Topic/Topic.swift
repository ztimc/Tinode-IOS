//
//  Topic.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public class Topic<DP: Codable, DR: Codable, SP: Codable, SR: Codable> {
    
    var tinode:  Tinode
    var name:    String
    var storage: Storage?
    var delegeta: TopicDelegete?
    
    var desc:        Description<DP,DR>?
    var subs:        Dictionary<String, Subscription<SP,SR>>?
    public var subsUpdated: String?
    var tags:        [String]?
    
    public var attached: Bool = false
    var lastKeyPress: Int64 = 0
    var isOnline = false
    var lastSeen: LastSeen?
    var maxDel: Int = 0
    
    init(tinode: Tinode, sub: Subscription<SP,SR>) {
        self.tinode   = tinode
        self.name     = sub.topic!
        self.isOnline = sub.online
        self.desc     = Description<DP,DR>()
        
        self.desc?.merge(sub: sub)
    }
    
    init(tinode: Tinode, name: String, desc: Description<DP,DR>) {
        self.tinode = tinode
        self.name   = name
        self.desc   = Description<DP,DR>()
        
        self.desc?.merge(desc: desc)
    }
    
    init(tinode: Tinode, name: String, delegate: TopicDelegete?) {
        self.tinode   = tinode
        self.delegeta = delegate
        self.name     = name
        self.desc     = Description<DP,DR>()
    }
    
    convenience init(tinode: Tinode, delegate: TopicDelegete) {
        self.init(tinode: tinode, name: Tinode.TOPIC_NEW, delegate: delegate)
    }
    
    public func subscribe(set: MsgSetMeta<DP,DR>?, get: MsgGetMeta?) -> Pine<ServerMessage>{
        if attached || !tinode.isConnect() {
            return Pine(err: TOError(err: "attached", code: -1, reson: "not need call"))
        }
        
        var newTopic: Bool
        let topicName = name
        let topic: Topic<DP,DR,SP,SR>? = tinode.getTopic(name: topicName)
        if topic == nil {
            tinode.registerTopic(topic: self)
            newTopic = true
        } else {
            newTopic = false
        }
        
        return tinode.subscribe(topicName: topicName, set: set, get: get)
            .then(result: { [weak self] (msg) -> Pine<ServerMessage>? in
                guard let this = self else { return nil}
                
                if !this.attached {
                    this.attached = true
                    if let acsDict = msg.ctrl?.params?.getDictionary(key: "acs") {
                        this.desc?.acs = Acs(am: acsDict)
                        if this.isNew() {
                            this.setUpdated(updated: msg.ctrl?.ts)
                            this.name = (msg.ctrl?.topic)!
                            this.tinode.changeTopicName(topic: this, oldName: topicName)
                        }
                        this.storage?.topicUpdate(topic: this)
                        this.delegeta?.onSubscribe(code: (msg.ctrl?.code)!, text: (msg.ctrl?.text)!)
                    }
                }
                return Pine(result: msg)
            }, failure: { [weak self] (err) -> Pine<ServerMessage>? in
                guard let this = self else { return nil}
                if let code = err.code {
                    if code >= 400 && code < 500 && newTopic {
                        this.tinode.unregisterTopic(topicName: topicName)
                        this.storage?.topicDelete(topic: this)
                        this.setStorage(store: nil)
                    }
                }
                return Pine(err: err)
            })
    }
    
    public func setUpdated(updated: String?) {
        desc?.updated = updated
    }
    
    public func getUpdated() -> String? {
        return desc?.updated
    }
    
    
    
    public func isNew() -> Bool {
       return name.starts(with: Tinode.TOPIC_NEW)
    }
    
    public func setStorage(store: Storage?){
        storage = store
    }
    
    public func getCachedMessageRange() -> TRange? {
        return storage?.getCachedMessageSSRange(topic: self)
    }
    
    public func setMaxDel(max: Int) {
        if max > maxDel {
            maxDel = max
        }
    }
    
    @discardableResult
    public func loadSubs() -> Int {
        guard let ss = storage?.getSubscriptions(topic: self) else {
            return 0
        }
        
        for s in ss {
            if subsUpdated == nil || subsUpdated?.compareDate(date: s.updated) == .orderedAscending{
                subsUpdated = s.updated
            }
            addSubToCache(sub: s)
        }
        
        return subs?.count ?? 0
    }
    
    public func addSubToCache(sub: Subscription<SP,SR>) {
        if subs == nil {
            subs = Dictionary<String, Subscription<SP,SR>>()
        }
        subs![sub.user!] = sub
    }
    
    public func removeSubFromCache(sub: Subscription<SP,SR>) {
        subs?.removeValue(forKey: sub.user!)
    }
    
    public func getSubscription(key: String) -> Subscription<SP,SR>? {
        if subs == nil { loadSubs() }
        
        return subs![key]
    }
    
    public func getMeta(query: MsgGetMeta) -> Pine<ServerMessage> {
        return tinode.getMeta(topicName: name, query: query)
    }
    
    public func updateAccessMode(ac: AccessChange) ->Bool {
        if desc?.acs == nil {
            desc?.acs = Acs()
        }
        return desc?.acs?.update(ac: ac) ?? false
    }
    
    public func update(desc: Description<DP,DR>) {
        if (self.desc!.merge(desc: desc)) {
            storage?.topicUpdate(topic: self)
        }
    }
    
    public func update(sub: Subscription<SP,SR>) {
        if (self.desc!.merge(sub: sub)) {
            storage?.topicUpdate(topic: self)
        }
        
        isOnline = sub.online
    }
    
    public func leave() {
        // TODO: 需要填写
    }
    
    public func routeMetaDel(clear: Int?, delseq: [MsgDelRange]?) {
        if let dels = delseq {
            for range in dels {
                storage?.msgDelete(topic: self, delId: clear!, fromId: range.low!, toId: range.hi == nil ? range.low! + 1 : range.hi!)
            }
        }
        
        setMaxDel(max: clear!)
        
        delegeta?.onData(data: nil)
    }
    
    public func getTopicType(name: String) -> TopicType {
        var tp:TopicType = .any
        
        switch name {
        case Tinode.TOPIC_ME:
            tp = .me
        case Tinode.TOPIC_FND:
            tp = .fnd
        case Tinode.TOPIC_GRP_PREFIX:
            tp = .grp
        case Tinode.TOPIC_USR_PREFIX:
            tp = .p2p
        default:
            tp = .any
        }
        
        return tp
    }
    
    public func isMeType() -> Bool {
       return getTopicType(name: name) == .me
    }
    
    public func isP2PType() -> Bool {
        return getTopicType(name: name) == .p2p
    }
    public func isFndType() -> Bool {
        return getTopicType(name: name) == .fnd
    }
    public func isGrpType() -> Bool {
        return getTopicType(name: name) == .grp
    }
    
    public func processSub(newSub: Subscription<SP,SR>) {
        var sub: Subscription<SP,SR>?
        
        if newSub.deleted != nil {
            storage?.subDelete(topic: self, sub: newSub)
            removeSubFromCache(sub: newSub)
            sub = newSub
        } else {
            sub = getSubscription(key: newSub.user!)
            if sub != nil {
                sub!.merge(sub: newSub)
                storage?.subUpdate(topic: self, sub: newSub )
            } else {
                sub = newSub
                addSubToCache(sub: sub!)
                storage?.subAdd(topic: self, sub: sub!)
            }
            
            tinode.updateUser(sub: sub!)
        }
        
        delegeta?.onMetaSub(sub: sub!)
        
    }
    
    public func getMetaGetBuilder() -> MetaGetBuilder<DP,DR,SP,SR> {
        return MetaGetBuilder.init(topic: self)
    }
    
    public func routePres(pres: MsgServerPres) {
        var sub: Subscription<SP,SR>?
        switch pres.what {
        case What.on.rawValue,
             What.off.rawValue:
            sub = getSubscription(key: pres.src!)
            sub?.online = What.on.rawValue == pres.what
            break
        case What.del.rawValue:
            routeMetaDel(clear: pres.clear, delseq: pres.delseq)
            break
        case What.acs.rawValue:
            sub = getSubscription(key: pres.src!)
            if sub != nil {
                var acs = Acs()
                acs.update(ac: pres.dacs)
                if acs.isModeDefined() {
                     getMeta(query: getMetaGetBuilder().withGetSub(user: pres.src!).build()).then()
                }
            } else {
                sub?.updateAccessMode(ac: pres.dacs!)
                
                if sub?.user == tinode.userId {
                    if updateAccessMode(ac: pres.dacs!) {
                        storage?.topicUpdate(topic: self)
                    }
                }
                
                if sub?.acs?.isModeDefined() ?? false {
                    if isP2PType() {
                        leave()
                    }
                    sub?.deleted = Formatter.iso8601.string(from: Date())
                    
                }
                
            }
            break
        default:
            break
        }
        delegeta?.onPres(pres: pres)
    }
    
    public func routeMeta(meta: MsgServerMeta<DP,DR,SP,SR>) {
        if meta.desc != nil {
            routeMeta(meta: meta)
        }
    }
    
    public func routeMateDesc(meta: MsgServerMeta<DP,DR,SP,SR>) {
        update(desc: meta.desc!)
        
        if getTopicType(name: name) == .p2p {
            tinode.updateUser(uid: name, desc: meta.desc!)
        }
        
        delegeta?.onMetaDesc(desc: meta.desc!)
    }
    
    
    func isPersisted() -> Bool {
        return false
    }
}

public enum TopicType : Int {
    case me   = 0x01
    case fnd  = 0x02
    case grp  = 0x04
    case p2p  = 0x08
    // grp | p2p
    case user = 0x0C
    // me | fnd
    case system = 0x03
    // me | fnd | grp | p2p
    case any = 0x0F
}

public enum NoteType {
    case read
    case recv
}
