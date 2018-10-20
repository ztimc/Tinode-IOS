//
//  MetaSetDesc.swift
//  Tinode
//
//  Created by ztimc on 2018/10/17.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation


public struct MetaSetDesc<P: Codable,R: Codable> : Codable {
    var pub: P?
    var priv: R?
    
    public init(p: P, r: R) {
        self.pub = p
        self.priv = r
    }
    
    enum CodingKeys : String, CodingKey {
        case pub = "public"
        case priv = "private"
    }
    
}
