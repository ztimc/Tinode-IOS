//
//  ServerMessage.swift
//  Tinode
//
//  Created by ztimc on 2018/10/13.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation


public struct ServerMessage: Decodable{
    public var ctrl: MsgServerCtrl?
    public var data: MsgServerData?
    public var pres: MsgServerPres?
    public var info: MsgServerInfo?
    
    
}

extension ServerMessage {
    
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ServerMessage.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
}
