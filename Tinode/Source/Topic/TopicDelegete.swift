//
//  TopicDelegete.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public protocol TopicDelegete {

    func onSubscribe(code: Int, text: String)
    func onLeave(unsub: Bool, code: Int, text: String)
    
    func onData(data: MsgServerData?)
    func onAllMessagesReceived(count: Int)
    
    func onInfo(info: MsgServerData)
    
    func onMeta<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(meta: MsgServerMeta<DP,DR,SP,SR>)
    
    func onMetaSub<SP,SR>(sub: Subscription<SP,SR>)
    func onMetaDesc<DR,DP>(desc: Description<DR,DP>)
    func onMetaTags(tags: [String])
    func onSubsUpdated()
    func onPres(pres: MsgServerPres)
    func onOnline(online: Bool)
    func onContUpdate<SP,SR>(sub: Subscription<SP,SR>)
}
