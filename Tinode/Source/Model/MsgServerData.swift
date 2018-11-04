//
//  MsgServerData.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct MsgServerData: Decodable {
    
    public var id: String?
    public var topic: String?
    public var from: String?
    public var ts: String?
    public var seq: Int?
    public var content: Content?
    
}

public enum Content: Codable {
   
    case string(String)
    case text(Drafty)
    
    public init(from decoder: Decoder) throws {
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        
        if let drafty = try? decoder.singleValueContainer().decode(Drafty.self) {
            self = .text(drafty)
            return
        }
        
        throw QuantumError.missingValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case.text(let text):
            try container.encode(text)
        }
        
    }
    
    enum QuantumError: Error {
        case missingValue
    }
    
}
