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
    
    
    // MARK: Properties
    
    private var host: String?
    
    private var socket:  SocketEngine?
    private var _config: TinodeConfigration
    private var appName: String?
    
    private var msgId: Int = 0
    private let lock = NSLock.init()
    private var futures: [String: Pine<ServerMessage>]
    
    public var delegete: TinodeDelegate?
    
    
    // MARK: Initializers
    
    public init(config: TinodeConfigration) {
        self._config = config
        self.futures = [String: Pine<ServerMessage>]()
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
            var clientMsg = ClientMessage(hi: clientHi)
            
            this.sendMessage(id: clientHi.id, msg: &clientMsg).then(result: { (msg) in
                if(msg.ctrl?.code == 201){
                    this.delegete?.TinodeDidConnect(tinode: this)
                }
            })
        }
        socket?.onDisconnect = {[weak self] error in
            guard let this = self else { return }
            this.delegete?.TinodeDidDisconnect(tinode: this, error: error)
            DefaultSocketLogger.Logger.log("onDisconnect", type: Tinode.logType)
        }
        socket?.onText = {[weak self] text in
            guard let this = self else { return }
            DefaultSocketLogger.Logger.log("onText" + text, type: Tinode.logType)
            
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
    
    public func login(userName: String, password: String) -> Pine<ServerMessage>  {
        let secret = (userName + ":" + password).toBase64()
        
        return login(type: .basic, secret: secret)
    }
    
    
    public func setConfigs(_ config: TinodeConfigration) {
        for option in config {
            switch option {
            case let .log(log):
                DefaultSocketLogger.Logger.log = log
            case let .logger(logger):
                DefaultSocketLogger.Logger = logger
            case let .appName(name):
                appName = name
            default:
                continue
            }
        }
    }
    
    private func login(type: AuthType, secret: String) -> Pine<ServerMessage> {
        let msgLogin = MsgClientLogin.init(id: getMessageId(), scheme: type.rawValue, secret: secret)
        
        var msg = ClientMessage(login: msgLogin)
        
        return sendMessage(id: msg.login!.id, msg: &msg)
    }
    
    private func account(uid: String, type: AuthType, secret: String, loginNow: Bool, tags: [String]) {
        
    }
    
    private func dispatchMessage(msg: ServerMessage) {
        
        if let id = msg.ctrl?.id, let code = msg.ctrl?.code {
            let pine = futures[id]
            
            if code >= 200 && code < 400 {
                pine?.resolve(result: msg)
            }else {
                pine?.reject(error: TOError(err: msg.ctrl?.text, code: msg.ctrl?.code, reson: msg.ctrl?.params?["what"] as? String))
            }
            futures.removeValue(forKey: id)
        }
        
    }
    
    private func sendMessage(id: String, msg: inout ClientMessage) -> Pine<ServerMessage> {
        
        let pine = Pine<ServerMessage>()
        futures[id] = pine
        socket?.send(message: try! msg.jsonString()!)
        
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
    
}

@objc public protocol TinodeDelegate : AnyObject {
    
    func TinodeDidConnect(tinode: Tinode)
    
    func TinodeDidDisconnect(tinode: Tinode, error: Error?)
    
}
