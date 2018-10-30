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
    var sub: MsgClientSub<Pu,Pr>?
    var get: MsgClientGet?
    
    
    init(hi: MsgClientHi) {
        self.hi = hi
    }
    
    init(login: MsgClientLogin) {
        self.login = login
    }
    
    init(acc: MsgClientAcc<Pu,Pr>) {
        self.acc = acc
    }
    
    init(sub: MsgClientSub<Pu,Pr>) {
        self.sub = sub
    }
    
    init(get: MsgClientGet) {
        self.get = get
    }
}

public struct EmptyType : Codable {
    
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
   
    decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)
        
        return Formatter.iso8601.date(from: dateStr)!
    })
    
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    
    encoder.dateEncodingStrategy = .iso8601
    
    return encoder
}
