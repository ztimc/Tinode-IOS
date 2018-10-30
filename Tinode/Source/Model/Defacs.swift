//
//  Defacs.swift
//  Tinode
//
//  Created by ztimc on 2018/10/17.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

struct Defacs : Codable {
    
    var auth: String
    var anon: String
    
    public mutating func merge(defacs: Defacs) -> Bool {
        /*
        var changed = 0
        if defacs.auth != nil {
            if auth == nil {
                auth = defacs.auth
                changed += 1
            } else {
                if (auth!.merge(ah: defacs.auth)) {
                    changed += 1
                }
            }
        }
        
        if defacs.anon != nil {
            if anon == nil {
                anon = defacs.anon
                changed += 1
            } else {
                if (anon!.merge(ah: defacs.anon)) {
                    changed += 1
                }
            }
        }
 
        
        return changed > 0
 */
        return false
    }
}
