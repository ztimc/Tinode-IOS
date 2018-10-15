//
//  SocketDelegate.swift
//  tinode
//
//  Created by ztimc on 2018/10/11.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

@objc public protocol TinodeSocketDelegate : AnyObject {
    
    func SocketDidConnect(socket: SocketEngine)
    
    func SocketDidDisconnect(socket: SocketEngine, error: Error?)
    
    func SocketDidReceiveMessage(socket: SocketEngine, text: String)
    
    func SocketDidReceiveData(socket: SocketEngine, data: Data)
}
