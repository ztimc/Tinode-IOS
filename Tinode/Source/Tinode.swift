//
//  Tinode.swift
//  tinode
//
//  Created by ztimc on 2018/10/11.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public class Tinode : NSObject, ConfigSettable {
   
    static let logType = "Tinode"
    static let VERSION = "0.15"
    static let LIBRARY = "tinode/" + VERSION;
    
    static let TOPIC_NEW        = "new"
    static let TOPIC_ME         = "me"
    static let TOPIC_FND        = "fnd"
    static let TOPIC_GRP_PREFIX = "grp"
    static let TOPIC_USR_PREFIX = "new"
    
    static let NOTE_KP = "kp"
    static let NOTE_RAED = "read"
    static let NOTE_RECV = "recv"
    
    
    // MARK: Properties
    
    private var host: String?
    
    private var socket:  SocketEngine?
    private var _config: TinodeConfigration
    private var appName: String?
    private var storage: Storage?
    
    
    private var msgId: Int = 0
    private let lock = NSLock.init()
    private var futures: [String: Pine<ServerMessage>]
    private var topics:  [String: Topic]
    private var users:   [String: User]
    
    public var delegete: TinodeDelegate?
    public private(set) var userId: String?
    public private(set) var token: String?
    public private(set) var expires: Date?
    
    // MARK: Initializers
    public init(config: TinodeConfigration) {
        self._config = config
        self.futures = [String: Pine<ServerMessage>]()
        self.topics  = [String: Topic]()
        self.users  = [String: User]()
        super.init()
        
        setConfigs(config)
        
    }
    
    // MARK: Method
    
    public func connect(host: String) {
        
        DefaultSocketLogger.Logger.log("connect", type: Tinode.logType)
        
        socket = SocketEngine(host: host, config: self._config)
        
        // Handle Socket Event
        socket?.onConnect = {[weak self] in
            guard let this = self else { return }
        
            DefaultSocketLogger.Logger.log("onConnect", type: Tinode.logType)
            
            // Must send hi Message
            let clientHi = MsgClientHi.init(id: this.getMessageId(), lang: SystemUtils.getCurrentLanguage(), ua: this.makeUserAgent(), ver: Tinode.VERSION)
            var clientMsg = ClientMessage<EmptyType, EmptyType>(hi: clientHi)
            
             this.sendMessage(id: clientHi.id, msg: &clientMsg).then(result: { (msg) in
                if(msg.ctrl?.code == 201){
                    this.delegete?.TinodeDidConnect(tinode: this)
                }
                return nil
            })
        }
        socket?.onDisconnect = {[weak self] error in
            guard let this = self else { return }
            this.delegete?.TinodeDidDisconnect(tinode: this, error: error)
            DefaultSocketLogger.Logger.log("onDisconnect", type: Tinode.logType)
        }
        socket?.onText = {[weak self] text in
            guard let this = self else { return }
            DefaultSocketLogger.Logger.log("in: " + text, type: Tinode.logType)
            
            let serverMsg = try! ServerMessage.init(text, using: .utf8)
            this.dispatchMessage(msg: serverMsg)
        }
        
        socket?.connect(reConnect: true)
    }
    
    public func disConnect() {
        socket?.disConnect()
    }
    
    public func isConnect() -> Bool {
        return socket?.isConnect() ?? false
    }
    
    /// login by basic
    ///
    /// - Parameters:
    ///   - userName: user
    ///   - password: password
    /// - Returns: server message
    public func login(userName: String, password: String) -> Pine<ServerMessage>  {
        let secret = (userName + ":" + password).toBase64()
        
        return login(type: .basic, secret: secret, cred: nil)
    }
    
    
    /// Login by token
    ///
    /// - Parameters:
    ///   - token: toekn
    ///   - cred: `Credential`
    /// - Returns: server message
    public func loginByToken(token: String, cred: [Credential]) -> Pine<ServerMessage> {
        return login(type: .token, secret: token, cred: cred)
    }
    
    /// Login by token
    ///
    /// - Parameter token: token
    /// - Returns: server message
    public func loginToken(token: String) -> Pine<ServerMessage> {
        return login(type: .token, secret: token, cred: nil)
    }
    
    
    /// Create user
    ///
    /// - Parameters:
    ///   - uname: user name
    ///   - password: password
    ///   - login: is login
    ///   - tags: tags
    ///   - desc: `MetaSetDesc`
    ///   - cred: `Credential`
    /// - Returns: server message
    public func createAccountBasic<Pu: Codable,Pr: Codable>(uname: String,
                                                            password: String,
                                                            login: Bool,
                                                            tags: [String]?,
                                                            desc: MetaSetDesc<Pu,Pr>,
                                                            cred: [Credential]) -> Pine<ServerMessage> {
        return account(uid: nil, type: .basic, secret: (uname + ":" + password).toBase64(), loginNow: login, tags: tags, desc: desc, cred: cred)
    }
    
    
    public func getFilteredTopics<T: Topic>(type: TopicType, date: Date?) -> [T] {
        if type == .any && date == nil {
            let ts = Array(topics.values)
            return ts as! [T]
        }
        
        var retTopic = Array<T>()
        let ts = Array(topics.values) as! [T]
        
        for t in ts {
            if t.getTopicType() == .any && (date == nil || date!.before(date: t.getUpdated()!)){
                retTopic.append(t)
            }
        }
        
        return retTopic
    }
    
    
    public func subscribe<Pu: Codable,Pr: Codable>(topicName: String,
                                                   set: MsgSetMeta<Pu,Pr>?,
                                                   get: MsgGetMeta?) -> Pine<ServerMessage>{
        let msgSub: MsgClientSub<Pu,Pr> = MsgClientSub<Pu,Pr>(id: getMessageId(),
                                                            topic: topicName,
                                                            set: set,
                                                            get: get)
        var msg: ClientMessage<Pu,Pr>   = ClientMessage<Pu,Pr>.init(sub: msgSub)
        
        return sendMessage(id: msgSub.id, msg: &msg)
    }
    
    public func registerTopic(topic: Topic) {
        if topic.isPersisted() {
            storage?.topicAdd(topic: topic)
        }
        topics[topic.name] = topic
    }
    
    public func getTopic(name: String) -> Topic? {
        return topics[name]
    }
    
    public func newTopic(sub: Subscription) -> Topic{
        /*
        if Tinode.TOPIC_ME == name {
            let topic:MeTopic<DP> = MeTopic(tinode: self, name: name, delegate: nil)
            return topic
        }*/
        
        let topic:MeTopic = MeTopic(tinode: self)
        return topic
    }
    
    public func changeTopicName(topic: Topic, oldName: String) {
        if let _ = topics[oldName]{
            topics.removeValue(forKey: oldName)
            topics[topic.name] = topic
        }
    }
    
    public func unregisterTopic(topicName: String) {
        topics.removeValue(forKey: topicName)
    }
    
    public func getMeta(topicName: String, query: MsgGetMeta) -> Pine<ServerMessage> {
        let msgGet = MsgClientGet.init(id: getMessageId(), topic: topicName, query: query)
        var msg: ClientMessage<EmptyType,EmptyType> = ClientMessage.init(get: msgGet)
        
        return sendMessage(id: msg.get!.id, msg: &msg)
    }
    
    public func getUser(uid: String) -> User? {
        var user = users[uid]
        if user == nil && storage != nil {
            user = storage?.userGet(uid: uid)
            if user != nil {
                users[uid] = user
            }
        }
        return user
    }
    
    
    public func updateUser(sub: Subscription) {
        var user = users[sub.user!]
        if user == nil {
            user = User(sub: sub)
            users[sub.user!] = user
        } else {
            user?.merge(sub: sub)
        }
        storage?.userUpdate(user: user!)
    }
    
    public func updateUser(uid: String, desc: Description) {
        var user = users[uid]
        if user == nil {
            user = User(uid: uid, desc: desc)
            users[uid] = user
        } else {
            user?.merge(desc: desc)
        }
        storage?.userUpdate(user: user!)
    }
    
    public func setConfigs(_ config: TinodeConfigration) {
        for option in config {
            switch option {
            case let .log(log):
                DefaultSocketLogger.Logger.log = log
            case let .logger(logger):
                DefaultSocketLogger.Logger = logger
            case let .appName(appName):
                self.appName = appName
            case let .storage(storage):
                self.storage = storage
            default:
                continue
            }
        }
    }
    
    private func login(type: AuthType, secret: String, cred: [Credential]?) -> Pine<ServerMessage> {
        
        var msgLogin = MsgClientLogin.init(id: getMessageId(), scheme: type.rawValue, secret: secret)
        
        if let cd = cred {
            for c in cd {
                msgLogin.addCred(cred: c)
            }
        }
        
        var msg = ClientMessage<EmptyType, EmptyType>(login: msgLogin)
        
        return sendMessage(id: msg.login!.id, msg: &msg)
    }

    
    private func account<Pu: Codable,Pr: Codable> (uid: String?,
                                                    type: AuthType,
                                                    secret: String,
                                                    loginNow: Bool,
                                                    tags: [String]?,
                                                    desc: MetaSetDesc<Pu,Pr>,
                                                    cred: [Credential]?) -> Pine<ServerMessage>  {
        var msgAcc: MsgClientAcc<Pu,Pr> = MsgClientAcc<Pu,Pr>(id: getMessageId(), uid: uid, scheme: type.rawValue, secret: secret, doLogin: loginNow, desc: desc)
        
        if let ts = tags {
            for tag in ts {
                msgAcc.addTag(tag: tag)
            }
        }
        
        if let creds = cred {
            for cd in creds {
                msgAcc.addCred(cred: cd)
            }
        }
        
        var msg = ClientMessage<Pu,Pr>.init(acc: msgAcc)
        return sendMessage(id: msgAcc.id!, msg: &msg).then(result: { (result) -> Pine<ServerMessage>? in
            self.saveLoginInfo(msg: result.ctrl!)
            return Pine<ServerMessage>(result: result)
        })
    }
    
    @discardableResult
    private func maybeCreateTopic(meta: MsgServerMeta) -> Topic? {
        if (meta.desc == nil) { return nil }
        
        var topic: Topic
        
        if Tinode.TOPIC_ME == meta.topic {
            topic = MeTopic(tinode: self, desc: meta.desc!)
        } else if Tinode.TOPIC_FND == meta.topic {
            topic = FndTopic(tinode: self)
        } else {
            topic = ComTopic(tinode: self, name: meta.topic!, desc: meta.desc!)
        }
        
        registerTopic(topic: topic)
        
        return topic
    }
    
    private func dispatchMessage(msg: ServerMessage) {
        
        if let id = msg.ctrl?.id, let code = msg.ctrl?.code {
            let pine = futures.removeValue(forKey: id)
            
            if code >= 200 && code < 400 {
                pine?.resolve(result: msg)
            }else {
                pine?.reject(error: TOError(err: msg.ctrl?.text, code: msg.ctrl?.code, reson: msg.ctrl?.params?.getStringValue(key: "what")))
            }
            futures.removeValue(forKey: id)
        } else if let id = msg.meta?.id {
            if let topic = getTopic(name: (msg.meta?.topic)!) {
                topic.routeMeta(meta: msg.meta!)
            } else {
                maybeCreateTopic(meta: msg.meta!)
            }
            
            resolveWithMsg(id: id, msg: msg)
        } else if msg.pres != nil {
            if let topic = getTopic(name: msg.pres!.topic!) {
                topic.routePres(pres: msg.pres!)
                
                if Tinode.TOPIC_ME == msg.pres!.topic && Topic.getTopicType(name: msg.pres!.src!) == .p2p {
                    if let forwardTo = getTopic(name: msg.pres!.src!){
                        forwardTo.routePres(pres: msg.pres!)
                    }
                }
            }
        } else if msg.info != nil {
            if let topic = getTopic(name: msg.info!.topic!) {
                topic.routeInfo(info: msg.info!)
            }
        }
        
        
    }
    
    private func resolveWithMsg(id: String, msg: ServerMessage) {
        if let pine = futures.removeValue(forKey: id) {
            pine.resolve(result: msg)
        }
    }
    
    private func sendMessage<Pu: Codable, Pr: Codable>(id: String, msg: inout ClientMessage<Pu, Pr>) -> Pine<ServerMessage> {
        
        let pine = Pine<ServerMessage>()
        futures[id] = pine
        let json = try! msg.jsonString()!
        DefaultSocketLogger.Logger.log("out: " + json, type: Tinode.logType)
        socket?.send(message: json)
        
        return pine
    }
    
    private func makeUserAgent() -> String {
        return appName! + "(IOS " + SystemUtils.getSystemVersion() + "; " + SystemUtils.getCurrentLanguage() + "); " + Tinode.LIBRARY
    }
    
    private func getMessageId() -> String {
        lock.lock()
        msgId += 1
        lock.unlock()
        return String(msgId)
    }
    
    private func saveLoginInfo(msg: MsgServerCtrl) {
        userId = msg.params?.getStringValue(key: "user")
        token  = msg.params?.getStringValue(key: "token")
        if let dateStr = msg.params?.getStringValue(key: "expires") {
            expires = Formatter.iso8601.date(from: dateStr)
        }
    }
    
}

@objc public protocol TinodeDelegate : AnyObject {
    
    func TinodeDidConnect(tinode: Tinode)
    
    func TinodeDidDisconnect(tinode: Tinode, error: Error?)
    
}
