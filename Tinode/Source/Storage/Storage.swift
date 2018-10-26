//
//  Storage.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public protocol Storage {
    
    func getMyUid() -> String
    
    func setMyUid(uid: String)

    func updateDeviceToken(token: String)
    
    func getDeviceToken() -> String
    
    func logout()
    
    // Server time minus local time
    func setTimeAdjustment(adjustment: Int64)
    
    func iSSReady() -> Bool
    
    // Fetch all topics
    func topicGetAll<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(tinode: Tinode) -> [Topic<DP,DR,SP,SR>]
    // Add new topic
    @discardableResult
    func topicAdd<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>) -> Int64
    
    /** Incoming change to topic description: the already mutated topic in memory is synchronized to DB */
    @discardableResult
    func topicUpdate<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>) -> Bool
    
    /** Delete topic */
    @discardableResult
    func topicDelete<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>) -> Bool
    
    /** Get seq IDs of the stored messages as a Range */
    func getCachedMessageSSRange<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>) -> TRange
    /** Local user reported messages as read */
    func setRead<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, read: Int) -> Bool
    /** Local user reported messages as received */
    func setRecv<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>,recv: Int) -> Bool
    
    /** Add subscription in a generic topic. The subscription is received from the server. */
    @discardableResult
    func subAdd<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, sub: Subscription<SP,SR>) -> Int64
    /** Update subscription in a generic topic */
    func subUpdate<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, sub: Subscription<SP,SR>)
    /** Add a new subscriber to topic. The new subscriber is being added locally. */
    func subNew<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>,sub: Subscription<SP,SR>) -> Int64
    /** Delete existing subscription */
    @discardableResult
    func subDelete<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>,sub: Subscription<SP,SR>) -> Bool
    
    /** Get a list o topic subscriptions from DB. */
    func getSubscriptions<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>) -> [Subscription<SP,SR>]
    
    /** Read user description */
    func userGet<P: Codable,R: Codable>(uid: String) -> User<P,R>
    /** Insert new user */
    @discardableResult
    func userAdd<P: Codable,R: Codable>(user: User<P,R>) -> Int64
    /** Update existing user */
    @discardableResult
    func userUpdate<P: Codable,R: Codable>(user: User<P,R>) -> Bool
    
    /**
     * Message received from the server.
     */
    func msgReceived<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, sub: Subscription<SP,SR>, msg: ServerMessage) -> Int64
    
    /**
     * Save message to DB as queued or synced.
     *
     * @param topic topic which sent the message
     * @param data message data to save
     * @return database ID of the message suitable for use in
     *  {@link #msgDelivered(Topic topic, long id, Date timestamp, int seq)}
     */
    func msgSend<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, data: Drafty)
    
    /**
     * Save message to database as a SDRaft. SDRaft will not be sent to server until it status changes.
     *
     * @param topic topic which sent the message
     * @param data message data to save
     * @return database ID of the message suitable for use in
     *  {@link #msgDelivered(Topic topic, long id, Date timestamp, int seq)}
     */
    func msgSDRaft<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, data: Drafty)
    
    /**
     * Update message SDRaft content without
     *
     * @param topic topic which sent the message
     * @param dbMessageId database ID of the message.
     * @param data updated content of the message. Must not be null.
     * @return true on success, false otherwise
     */
    func msgSDRaftUpdate<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, dbMessageId: UInt64, data: Drafty) -> Bool
    
    /**
     * Message is ready to be sent to the server.
     *
     * @param topic topic which sent the message
     * @param dbMessageId database ID of the message.
     * @param data updated content of the message. If null only status is updated.
     * @return true on success, false otherwise
     */
    func msgReady<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, dbMessageId:Int64, data: Drafty) -> Bool
    
    /**
     * Delete message by database id.
     */
    func msgDiscard<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, dbMessageId: Int64) -> Bool
    
    /**
     * Message delivered to the server and received a real seq ID.
     *
     * @param topic topic which sent the message.
     * @param dbMessageId database ID of the message.
     * @param timestamp server timestamp.
     * @param seq server-issued message seqId.
     * @return true on success, false otherwise     *
     */
    func msgDelivered<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, dbMessageId: Int64, timestamp: Date, seq: Int) -> Bool
    /** Mark messages for deletion by range */
    func msgMarkToDelete<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, fromId: Int, toId: Int, markAsHard: Bool) -> Bool
    /** Mark messages for deletion by seq ID list */
    func msgMarkToDelete<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, list: [Int], markAsHard: Bool) -> Bool
    /** Delete messages */
    @discardableResult
    func msgDelete<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, delId: Int, fromId: Int, toId: Int) -> Bool
    /** Delete messages */
    func msgDelete<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, delId: Int, list: [Int]) -> Bool
    /** Set recv value for a given subscriber */
    func msgRecvByRemote<SP: Codable, SR: Codable>(sub: Subscription<SP,SR>, recv: Int) -> Bool
    /** Set read value for a given subscriber */
    func msgReadByRemote<SP: Codable, SR: Codable>(sub: Subscription<SP,SR>, read: Int) -> Bool
    
    func getMessageById<T: Message, DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, messageId: String) ->T
    
    func getQueuedMessages<T: Message, DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>) ->T
    
    func getQueuedMessageDeletes<DP: Codable, DR: Codable, SP: Codable, SR: Codable>(topic: Topic<DP,DR,SP,SR>, hard: Bool) -> [Int]
    
}

public protocol Message {
    /** Get current message payload */
    func getContent() -> Any
    /** Get current message unique ID (database ID) */
    func getId() -> Int64
    
    /** Get Tinode seq Id of the message (different from database ID */
    func getSeqId() -> Int
    
    func isSDRaft() -> Bool
    func iSSReady() -> Bool
    func isDeleted() -> Bool
    func isDeleted(hard: Bool) -> Bool
    func isSynced() -> Bool
}

public struct TRange {
    var max: Int
    var min: Int
    
    init(max: Int, min: Int) {
        self.max = max
        self.min = min
    }
}
