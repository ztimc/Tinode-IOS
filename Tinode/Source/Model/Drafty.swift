//
//  Drafty.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct Drafty: Codable {
    public var txt: String?
    public var fmt: [Style]?
    public var ent: [Entity]?
    
    init(txt: String) {
        self.txt = txt
    }
}

public struct Style: Codable {
    
    public var at: Int?
    public var len: Int?
    public var tp: String?
    public var key: Int?
    public var data: Dictionary<String,String>?
}

public struct Entity: Codable {
    public var tp: String?
    public var data: Dictionary<String,String>?
}
