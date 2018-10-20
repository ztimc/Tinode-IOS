//
//  ClientMessage.swift
//  Tinode
//
//  Created by ztimc on 2018/10/12.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

struct ClientMessage<Pu: Codable, Pr: Codable> : Codable{
    var hi: MsgClientHi?
    var login: MsgClientLogin?
    var acc: MsgClientAcc<Pu,Pr>?
    
    
    init(hi: MsgClientHi) {
        self.hi = hi
    }
    
    init(login: MsgClientLogin) {
        self.login = login
    }
    
    init(acc: MsgClientAcc<Pu,Pr>) {
        self.acc = acc
    }
}

struct EmptyType : Codable {
    
}

extension ClientMessage {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ClientMessage.self, from: data)
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
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}


func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
