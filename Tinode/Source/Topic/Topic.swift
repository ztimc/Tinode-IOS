//
//  Topic.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public class Topic {
    
    
    public var onSubscribe: ((_ code: Int, _ text: String) -> ())?
    public var onLeave: ((_ unsub: Bool, _ code: Int, _ text: String) -> ())?
    public var onData: ((_ data: MsgServerData?) -> ())?
    public var onAllMessagesReceived: ((_ count: Int) -> ())?
    public var onInfo: ((_ info: MsgServerData) -> ())?
    public var onMeta: ((_ meta: MsgServerMeta) -> ())?
    public var onMetaDesc: ((_ desc: Description) -> ())?
    public var onMetaSub: ((_ sub: Subscription) -> ())?
    public var onMetaTags: ((_ tags: [String]) -> ())?
    public var onSubsUpdated: (() -> ())?
    public var onPres: ((_ pres: MsgServerPres) -> ())?
    public var onOnline: ((_ online: Bool) -> ())?
    public var onContUpdate: ((_ sub: Subscription) -> ())?
    
    
    var tinode:  Tinode
    var name:    String
    var storage: Storage?
    
    var desc:        Description?
    var subs:        Dictionary<String, Subscription>?
    var tags:        [String]?
    
    public var attached: Bool = false
    public var subsUpdated: Date?
    var lastKeyPress: Int64 = 0
    var isOnline = false
    var lastSeen: LastSeen?
    var maxDel: Int = 0
    
    init(tinode: Tinode, sub: Subscription) {
        self.tinode   = tinode
        self.name     = sub.topic!
        self.isOnline = sub.online
        self.desc     = Description()
        
        self.desc?.merge(sub: sub)
    }
    
    init(tinode: Tinode, name: String, desc: Description) {
        self.tinode = tinode
        self.name   = name
        self.desc   = Description()
        
        self.desc?.merge(desc: desc)
    }
    
    init(tinode: Tinode, name: String) {
        self.tinode   = tinode
        self.name     = name
        self.desc     = Description()
    }
    
    convenience init(tinode: Tinode) {
        self.init(tinode: tinode, name: Tinode.TOPIC_NEW)
    }
    
    public func subscribe<Pu: Codable, Pr: Codable>(set: MsgSetMeta<Pu, Pr>?, get: MsgGetMeta?) -> Pine<ServerMessage>{
        if attached || !tinode.isConnect() {
            return Pine(err: TOError(err: "attached", code: -1, reson: "not need call"))
        }
        
        var newTopic: Bool
        let topicName = name
        let topic: Topic? = tinode.getTopic(name: topicName)
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
                        this.onSubscribe?((msg.ctrl?.code)!, (msg.ctrl?.text)!)
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
    
    public func setUpdated(updated: Date?) {
        desc?.updated = updated
    }
    
    public func getUpdated() -> Date? {
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
    
    public func getPriv() -> JSON?{
        return desc?.priv
    }
    
    @discardableResult
    public func loadSubs() -> Int {
        guard let ss = storage?.getSubscriptions(topic: self) else {
            return 0
        }
        
        for s in ss {
            if subsUpdated == nil || subsUpdated!.before(date: s.updated!){
                subsUpdated = s.updated
            }
            addSubToCache(sub: s)
        }
        
        return subs?.count ?? 0
    }
    
    public func addSubToCache(sub: Subscription) {
        if subs == nil {
            subs = Dictionary<String, Subscription>()
        }
        subs![sub.user!] = sub
    }
    
    public func removeSubFromCache(sub: Subscription) {
        subs?.removeValue(forKey: sub.user!)
    }
    
    public func getSubscription(key: String) -> Subscription? {
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
    
    public func update(desc: Description) {
        if (self.desc!.merge(desc: desc)) {
            storage?.topicUpdate(topic: self)
        }
    }
    
    public func update(sub: Subscription) {
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
        
        onData?(nil)
    }
    
    public func getTopicType() -> TopicType {
        return getTopicType(name: self.name)
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
    
    public func processSub(newSub: Subscription) {
        var sub: Subscription?
        
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
        
        onMetaSub?(sub!)
    }
    
    public func getMetaGetBuilder() -> MetaGetBuilder {
        return MetaGetBuilder.init(topic: self)
    }
    
    public func routePres(pres: MsgServerPres) {
        var sub: Subscription?
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
                    sub?.deleted = Date()
                }
                
            }
            break
        default:
            break
        }

        onPres?(pres)
    }
    
    public func routeMeta(meta: MsgServerMeta) {
        if meta.desc != nil {
            routeMateDesc(meta: meta)
        }
        
        if meta.sub != nil {
            
        }
    }
    
    public func routeMateDesc(meta: MsgServerMeta) {
        update(desc: meta.desc!)
        
        if getTopicType(name: name) == .p2p {
            tinode.updateUser(uid: name, desc: meta.desc!)
        }
        
        onMetaDesc?(meta.desc!)
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
