//
//  MeTopic.swift
//  Tinode
//
//  Created by ztimc on 2018/10/23.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

class MeTopic<DP: Codable>: Topic<DP, Dictionary<String,String>, DP, Dictionary<String,String>> {
    
    override init(tinode: Tinode, name: String, delegate: TopicDelegete) {
        super.init(tinode: tinode, name: name, delegate: delegate)
    }
    
    override init(tinode: Tinode, name: String, desc: Description<DP, Dictionary<String,String>>) {
        super.init(tinode: tinode, name: name, desc: desc)
    }
    
    
}
