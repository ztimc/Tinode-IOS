//
//  MsgClientAcc.swift
//  Tinode
//
//  Created by ztimc on 2018/10/17.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

struct MsgClientAcc<Pu: Codable, Pr: Codable> : Codable {
    var id: String?
    var user: String?
    var scheme: String?
    var secret: String?
    var login: Bool?
    var tags: [String]?
    var cred: [Credential]?
    var desc: MetaSetDesc<Pu,Pr>
    
    init(id: String?,
         uid: String?,
         scheme: String?,
         secret: String?,
         doLogin: Bool,
         desc: MetaSetDesc<Pu,Pr>) {
        self.id = id
        self.user = uid == nil ? "new" : uid
        self.scheme = scheme
        self.login = doLogin
        self.desc = desc
        self.secret = secret
    }
    
    mutating func addTag(tag: String) {
        if self.tags == nil {
            self.tags = [String]()
        }
        self.tags?.append(tag)
    }
    
    mutating func addCred(cred: Credential) {
        if self.cred == nil {
            self.cred = [Credential]()
        }
        self.cred?.append(cred)
    }
    
}
