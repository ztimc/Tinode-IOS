//
//  Credential.swift
//  Tinode
//
//  Created by ztimc on 2018/10/14.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct Credential: Codable {
    var meth: String?
    var val: String?
    var resp: String?
    
    public init(meth: String, val: String) {
        self.meth = meth
        self.val = val
    }
    
    public init(meth: String, resp: String) {
    self.meth = meth
        self.resp = resp
    }
    
    
    public static func append(creds: [Credential]?, c: Credential) -> [Credential] {
        var cds = creds
        if cds == nil {
            cds = []
        }
        cds?.append(c)
        return cds!
    }
}

