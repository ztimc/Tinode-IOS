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
    
    
    public var attached: Bool = false
    public var subsUpdated: Date?
    public var name:    String
    
    var tinode:  Tinode
    var storage: Storage?
    
    var desc: Description!
    var subs: Dictionary<String, Subscription>?
    var tags: [String]?
    
    var lastKeyPress: Int64 = 0
    var isOnline: Bool?
    var lastSeen: LastSeen?
    var maxDel: Int = 0
    
    init(tinode: Tinode, sub: Subscription) {
        self.tinode   = tinode
        self.name     = sub.topic!
        self.isOnline = sub.online
        self.desc     = Description()
        
        self.desc.merge(sub: sub)
    }
    
    init(tinode: Tinode, name: String, desc: Description) {
        self.tinode = tinode
        self.name   = name
        self.desc   = Description()
        
        self.desc.merge(desc: desc)
    }
    
    init(tinode: Tinode, name: String) {
        self.tinode   = tinode
        self.name     = name
        self.desc     = Description()
    }
    
    convenience init(tinode: Tinode) {
        self.init(tinode: tinode, name: Tinode.TOPIC_NEW)
    }
    
    public func subscribe() -> Pine<ServerMessage> {
        let getMeta = getMetaGetBuilder()
            .withGetDesc()
            .withGetSub()
            .withGetData()
            .withGetTags()
            .build()
        var setMeta = MsgSetMeta<JSON,JSON>()
        
        if isNew() && desc.pub != nil || desc.priv != nil {
            setMeta.desc = MetaSetDesc(p: desc.pub, r: desc.pub)
        }
        
        return subscribe(set: setMeta, get: getMeta)
    }
    
    public func subscribe<Pu: Codable, Pr: Codable>(set: MsgSetMeta<Pu, Pr>?, get: MsgGetMeta?) -> Pine<ServerMessage>{
        if attached || !tinode.isConnect() {
            return Pine(TOError(err: "attached", code: -1, reson: "not need call"))
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
                        this.desc.acs = Acs(am: acsDict)
                        if this.isNew() {
                            this.setUpdated(updated: msg.ctrl?.ts)
                            this.name = (msg.ctrl?.topic)!
                            this.tinode.changeTopicName(topic: this, oldName: topicName)
                        }
                        this.storage?.topicUpdate(topic: this)
                        this.onSubscribe?((msg.ctrl?.code)!, (msg.ctrl?.text)!)
                    }
                }
                return Pine(msg)
            }, failure: { [weak self] (err) -> Pine<ServerMessage>? in
                guard let this = self else { return nil}
                if let code = err.code {
                    if code >= 400 && code < 500 && newTopic {
                        this.tinode.unregisterTopic(topicName: topicName)
                        this.storage?.topicDelete(topic: this)
                        this.setStorage(store: nil)
                    }
                }
                return Pine(err)
            })
    }
    
    public func setUpdated(updated: Date?) {
        desc.updated = updated
    }
    
    public func getUpdated() -> Date? {
        return desc.updated
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
        return desc.priv
    }
    
    public func getPub() -> JSON? {
        return desc.pub
    }
    
    public func setRecv(_ recv: Int) {
        if recv > desc.recv! {
            desc.recv = recv
        }
    }
    
    public func getRevc() -> Int {
        return desc.recv!
    }
    
    public func setRead(_ read: Int) {
        if read > desc.read! {
            desc.read = read
        }
    }
    
    public func getRead() -> Int {
        return desc.read!
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
    
    public func getSubscription(_ key: String) -> Subscription? {
        if subs == nil { loadSubs() }
        
        return subs?[key]
    }
    
    public func getMeta(_ query: MsgGetMeta) -> Pine<ServerMessage> {
        return tinode.getMeta(topicName: name, query: query)
    }
    
    public func updateAccessMode(ac: AccessChange) ->Bool {
        if desc.acs == nil {
            desc.acs = Acs()
        }
        return desc.acs?.update(ac: ac) ?? false
    }
    
    public func update(desc: Description) {
        if (self.desc.merge(desc: desc)) {
            storage?.topicUpdate(topic: self)
        }
    }
    
    public func update(sub: Subscription) {
        if (self.desc.merge(sub: sub)) {
            storage?.topicUpdate(topic: self)
        }
        
        isOnline = sub.online
    }
    
    public func update(tags: [String]) {
        self.tags = tags
        storage?.topicUpdate(topic: self)
    }
    
    @discardableResult public func leave(_ unsub: Bool) -> Pine<ServerMessage> {
        if attached {
            return tinode.leave(topicName: name, unsub: unsub).then(result: { [weak self] (msg) -> Pine<ServerMessage>? in
                guard let this = self else { return  Pine(TOError(err: "self is free", code: -1, reson: "error"))}
                
                this.topticLeft(unsub: unsub, code: msg.ctrl!.code, reason: msg.ctrl!.text)
                if unsub {
                    this.tinode.unregisterTopic(topicName: this.name)
                }
                return Pine(msg)
            })
        }
        return Pine(TOError(err: "not attach ", code: -1, reson: "you mut attach topic"))
    }
    
    @discardableResult public func leave() -> Pine<ServerMessage> {
        return leave(false)
    }

    fileprivate func publish(content: Content, id: Int64) -> Pine<ServerMessage> {
        return tinode.publish(topicName: name, conten: content).then(result: {[weak self] (msg) -> Pine<ServerMessage>? in
            guard let this = self else { return Pine(TOError(err: "self is err")) }
            this.processDelivery(ctrl: msg.ctrl!, id: id)
            return Pine(msg)
        }, failure: { (err) -> Pine<ServerMessage>? in
            return Pine(err)
        })
    }
    
    public func publish(_ content: Content) -> Pine<ServerMessage> {
        var id:Int64 = -1
        if let sId = storage?.msgSend(topic: self, data: content) {
            id = sId
        }
        
        if attached {
            return publish(content: content, id: id)
        } else {
            return subscribe().then(result: {[weak self] (msg) -> Pine<ServerMessage>? in
                guard let this = self else {return Pine(TOError(err: "self is nil "))}
                return this.publish(content: content, id: id)
                }, failure: { (err) -> Pine<ServerMessage>? in
                    return Pine(err)
            })
        }
    }
    
    public func publish(_ content: String) -> Pine<ServerMessage> {
        return publish(Content.string(content))
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
        return Topic.getTopicType(name: self.name)
    }
    
    public static func getTopicType(name: String) -> TopicType {
        var tp:TopicType = .any
        
        if name == Tinode.TOPIC_ME {
            tp = .me
        } else if name == Tinode.TOPIC_FND {
            tp = .fnd
        } else if name.starts(with: Tinode.TOPIC_GRP_PREFIX) || name.starts(with: Tinode.TOPIC_NEW){
            tp = .grp
        } else if name.starts(with: Tinode.TOPIC_USR_PREFIX) {
            tp = .p2p
        }
        
        return tp
    }
    
    public func isMeType() -> Bool {
       return getTopicType() == .me
    }
    
    public func isP2PType() -> Bool {
        return getTopicType() == .p2p
    }
    public func isFndType() -> Bool {
        return getTopicType() == .fnd
    }
    public func isGrpType() -> Bool {
        return getTopicType() == .grp
    }
    
    public func getMetaGetBuilder() -> MetaGetBuilder {
        return MetaGetBuilder.init(topic: self)
    }
    
    public func processSub(newSub: Subscription) {
        var sub: Subscription?
        
        if newSub.deleted != nil {
            storage?.subDelete(topic: self, sub: newSub)
            removeSubFromCache(sub: newSub)
            sub = newSub
        } else {
            sub = getSubscription(newSub.user!)
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
    
    public func routePres(pres: MsgServerPres) {
        var sub: Subscription?
        switch pres.what {
        case What.on.rawValue,
             What.off.rawValue:
            sub = getSubscription(pres.src!)
            sub?.online = What.on.rawValue == pres.what
            break
        case What.del.rawValue:
            routeMetaDel(clear: pres.clear, delseq: pres.delseq)
            break
        case What.acs.rawValue:
            sub = getSubscription(pres.src!)
            if sub != nil {
                var acs = Acs()
                acs.update(ac: pres.dacs)
                if acs.isModeDefined() {
                     getMeta(getMetaGetBuilder().withGetSub(user: pres.src!).build()).then()
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
            if subsUpdated == nil || meta.ts!.after(date: subsUpdated!) {
                subsUpdated = meta.ts
            }
            routeMetaSub(meta: meta)
        }
        
        if meta.del != nil {
            routeMetaDel(clear: meta.del!.clear!, delseq: meta.del!.delseq!)
        }
        
        if meta.tags != nil {
            routeMetaTgas(tags: meta.tags!)
        }
        
        onMeta?(meta)
        
    }
    
    public func routeMateDesc(meta: MsgServerMeta) {
        
        update(desc: meta.desc!)
        if getTopicType() == .p2p {
            tinode.updateUser(uid: name, desc: meta.desc!)
        }
        
        self.onMetaDesc?(meta.desc!)
    }
    
    public func routeInfo(info: MsgServerInfo) {
        if info.what == Tinode.NOTE_KP {
            if var sub = getSubscription(info.from!) {
                switch info.what! {
                case Tinode.NOTE_RAED:
                    sub.read = info.seq!
                    storage?.msgReadByRemote(sub: sub, read: info.seq!)
                    break
                case Tinode.NOTE_RECV:
                    sub.recv = info.seq!
                    storage?.msgRecvByRemote(sub: sub, recv: info.seq!)
                    break
                default:
                    break
                }
            }
        }
    }
    
    public func routeData(data: MsgServerData) {
        storage?.msgReceived(topic: self, sub: getSubscription(data.from!)!, msg: data)
        noteRecv()
        
        setSeq(seq: data.seq!)
        
        onData?(data)
    }
    
    func routeMetaSub(meta: MsgServerMeta) {
        if let subs = meta.sub {
            for sub in subs {
                processSub(newSub: sub)
            }
        }
        
        onSubsUpdated?()
    }
    
    func routeMetaDel(clear: Int, delseq: [MsgDelRange]) {
        if let store = storage {
            for rage in delseq {
                let toId: Int
                if rage.hi != nil {
                    toId = rage.hi!
                } else {
                    toId = rage.low! + 1
                }
                store.msgDelete(topic: self, delId: clear, fromId: rage.low!, toId: toId)
            }
        }
        
        setMaxDel(max: clear)
        
        onData?(nil)
    }
    
    func routeMetaTgas(tags: [String]) {
        update(tags: tags)
        
        onMetaTags?(tags)
    }
    
    public func setSeq(seq: Int) {
        desc.seq = seq
    }
    
    public func getSeq() -> Int {
        if let seq = desc.seq {
            return seq
        }
        return 0
    }
    
    private func processDelivery(ctrl: MsgServerCtrl, id: Int64) {
        if let seq = ctrl.params?.getIntValue(key: "seq") {
            setSeq(seq: seq)
        }
        if id > 0 && storage != nil {
            if storage!.msgDelivered(topic: self, dbMessageId: id, timestamp: ctrl.ts, seq: desc.seq!) {
                setRecv(desc.seq!)
            }
        } else {
             setRecv(desc.seq!)
        }
        storage?.setRead(topic: self, read: desc.seq!)
    }
    
    func noteReadRecv(what: NoteType) -> Int {
        var result = 0
        
        switch what {
        case .read:
            if desc.read! < desc.seq! {
                tinode.noteRead(topic: name, seq: desc.seq!)
                desc.read = desc.seq
                result = desc.read!
            }
        case .recv:
            if desc.recv! < desc.seq! {
                tinode.noteRecv(topic: name, seq: desc.seq!)
                desc.recv = desc.seq
                result = desc.recv!
            }
        }
        return result
    }
    
    @discardableResult
    func noteRead() -> Int {
        let result = noteReadRecv(what: .read)
        storage?.setRead(topic: self, read: result)
        return result
    }
    
    @discardableResult
    func noteRecv() -> Int {
        let result = noteReadRecv(what: .recv)
        storage?.setRecv(topic: self, recv: result)
        return result
    }
    
    func noteKeyPress() {
        tinode.noteKeyPress(topic: name)
    }
    
    func topticLeft(unsub: Bool, code: Int, reason: String) {
        if attached {
            attached = false
            
            onLeave?(unsub, code, reason)
        }
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
    
    public func compare(_ type: TopicType) -> Bool {
        return self.rawValue & type.rawValue != 0
    }
}

public enum NoteType {
    case read
    case recv
}
