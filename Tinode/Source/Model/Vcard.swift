//
//  Vcard.swift
//  Tinode
//
//  Created by ztimc on 2018/10/18.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct VCard : Codable {
    var fn: String?
    var name: String?
    var org: String?
    var title: String?
    var tel: [Contact]?
    var email: [Contact]?
    var impp: [Contact]?
    var photo: Photo?
    
    public init(name: String?, avatar: [UInt8]?) {
        self.fn = name
        self.photo = Photo(data: avatar)
    }
}

struct Contact : Codable {
    let type: String
    let uri: String
}

struct Photo : Codable {
    var type: String?
    var data: [UInt8]?
    
    init(data: [UInt8]?) {
        self.data = data
    }
}
