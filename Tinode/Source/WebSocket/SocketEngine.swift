//
//  SocketEngine.swift
//  tinode
//
//  Created by ztimc on 2018/10/11.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation
import Starscream

public class SocketEngine : NSObject, ConfigSettable {
    
    static let API_VERSION = "0"
    
    // MARK: Properties
    private let engineQueue = DispatchQueue(label: "com.sabinetek.engineHandleQueue")
    
    private let host: String
    
    private var ws: WebSocket?
    
    private var apiKey:    String?
    private var reconnect: Bool?
    private var tls:       Bool = false
   
    weak public var delegate: TinodeSocketDelegate?
    
    public var onConnect: (() -> Void)?
    public var onDisconnect: ((Error?) -> Void)?
    public var onText: ((String) -> Void)?
    public var onData: ((Data) -> Void)?
    public var onPong: ((Data?) -> Void)?
   
    // MARK: Initializers

    public init(host: String, config: TinodeConfigration) {
        self.host = host
        super.init()
        
        setConfigs(config)
    }
    
    // MARK: Method
    
    public func connect(reConnect: Bool) {
        let url = URL(string: (tls ? "https://" : "http://") + host + "/v" + SocketEngine.API_VERSION + "/channels")!
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        request.addValue(apiKey!, forHTTPHeaderField: "X-Tinode-APIKey")
        
        ws = WebSocket(request: request)
        
        ws?.callbackQueue = engineQueue
        ws?.onConnect     = {[weak self] in
            guard let this = self else { return }
            this.delegate?.SocketDidConnect(socket: this)
            this.onConnect?()
        }
        ws?.onDisconnect = {[weak self] error in
            guard let this = self else { return }
            this.delegate?.SocketDidDisconnect(socket: this, error: error)
            this.onDisconnect?(error)
        }
        ws?.onText       = {[weak self] text in
            guard let this = self else { return }
            this.delegate?.SocketDidReceiveMessage(socket: this, text: text)
            this.onText?(text)
        }
        ws?.onData       = {[weak self] data in
            guard let this = self else { return }
            this.delegate?.SocketDidReceiveData(socket: this, data: data)
            this.onData?(data)
        }
        ws?.connect()
        
    }
    
    public func isConnect() -> Bool {
        return ws?.isConnected ?? false
    }
    
    public func send(message: String) {
        ws?.write(string: message)
    }
    
    public func disConnect() {
        ws?.disconnect()
    }
    
    
    /// Called when the engine should set/update its config from a geven configuration
    ///
    /// - Parameter config: The `TinodeConfigration` that should be used to set/update configs
    public func setConfigs(_ config: TinodeConfigration) {
        for option in config {
            switch option {
            case let .apikey(key):
                apiKey = key
            case let .reconnects(reconnects):
                reconnect = reconnects
            case let .tls(s):
                tls = s
            default:
                continue
            }
        }
    }
}
