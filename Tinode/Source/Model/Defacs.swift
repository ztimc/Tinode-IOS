//
//  Defacs.swift
//  Tinode
//
//  Created by ztimc on 2018/10/17.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

struct Defacs : Codable {
    var auth: AcsHelper?
    var anon: AcsHelper?
    
    init(auth: String, anon: String) {
        
    }
}
