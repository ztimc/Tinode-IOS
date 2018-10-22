//
//  TinodeOption.swift
//  tinode
//
//  Created by ztimc on 2018/10/11.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

protocol ClientOption : CustomStringConvertible, Equatable {
    func getTinodeOptionValue() -> Any
}

public enum TinodeOption : ClientOption {
    
    /// AppKey
    case apikey(String)
    
    /// AppName from server make
    case appName(String)
    
    case storage(Storage)
    
    /// if Passed `true`, the websocket will use tls
    case tls(Bool)
    
    /// Used to pass in a custom logger
    case logger(SocketLogger)
    
    /// If passed `true`, the client will log debug information, This should be turned off in production code.
    case log(Bool)
    
    /// If Passed `false`, the client will not reconnect when it loses connection. Use full if want full control
    /// over when reconnects happen.
    case reconnects(Bool)
    
    func getTinodeOptionValue() -> Any {
        let value: Any
        
        switch self {
        case let .apikey(appkey):
            value = appkey
        case let .appName(appname):
            value = appname
        case let .tls(tls):
            value = tls
        case let .logger(logger):
            value = logger
        case let .log(log):
            value = log
        case let .reconnects(reconnects):
            value = reconnects
        case let .storage(storage):
            value = storage
        }
        
        return value
    }
    
    public var description: String {
        let description: String
        switch self {
        case .apikey:
            description = "apikey"
        case .appName:
            description = "appname"
        case .tls:
            description = "tls"
        case .logger:
            description = "logger"
        case .log:
            description = "log"
        case .reconnects:
            description = "reconnects"
        case .storage:
            description = "storage"
        }
        
        return description
    }
    
    public static func ==(lhs: TinodeOption, rhs: TinodeOption) -> Bool {
        return lhs.description == rhs.description
    }
    
}
