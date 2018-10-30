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
    func topicGetAll(tinode: Tinode) -> [Topic]
    // Add new topic
    @discardableResult
    func topicAdd(topic: Topic) -> Int64
    
    /** Incoming change to topic description: the already mutated topic in memory is synchronized to DB */
    @discardableResult
    func topicUpdate(topic: Topic) -> Bool
    
    /** Delete topic */
    @discardableResult
    func topicDelete(topic: Topic) -> Bool
    
    /** Get seq IDs of the stored messages as a Range */
    func getCachedMessageSSRange(topic: Topic) -> TRange
    /** Local user reported messages as read */
    func setRead(topic: Topic, read: Int) -> Bool
    /** Local user reported messages as received */
    func setRecv(topic: Topic,recv: Int) -> Bool
    
    /** Add subscription in a generic topic. The subscription is received from the server. */
    @discardableResult
    func subAdd(topic: Topic, sub: Subscription) -> Int64
    /** Update subscription in a generic topic */
    func subUpdate(topic: Topic, sub: Subscription)
    /** Add a new subscriber to topic. The new subscriber is being added locally. */
    func subNew(topic: Topic,sub: Subscription) -> Int64
    /** Delete existing subscription */
    @discardableResult
    func subDelete(topic: Topic,sub: Subscription) -> Bool
    
    /** Get a list o topic subscriptions from DB. */
    func getSubscriptions(topic: Topic) -> [Subscription]
    
    /** Read user description */
    func userGet(uid: String) -> User
    /** Insert new user */
    @discardableResult
    func userAdd(user: User) -> Int64
    /** Update existing user */
    @discardableResult
    func userUpdate(user: User) -> Bool
    
    /**
     * Message received from the server.
     */
    func msgReceived(topic: Topic, sub: Subscription, msg: ServerMessage) -> Int64
    
    /**
     * Save message to DB as queued or synced.
     *
     * @param topic topic which sent the message
     * @param data message data to save
     * @return database ID of the message suitable for use in
     *  {@link #msgDelivered(Topic topic, long id, Date timestamp, int seq)}
     */
    func msgSend(topic: Topic, data: Drafty)
    
    /**
     * Save message to database as a SDRaft. SDRaft will not be sent to server until it status changes.
     *
     * @param topic topic which sent the message
     * @param data message data to save
     * @return database ID of the message suitable for use in
     *  {@link #msgDelivered(Topic topic, long id, Date timestamp, int seq)}
     */
    func msgSDRaft(topic: Topic, data: Drafty)
    
    /**
     * Update message SDRaft content without
     *
     * @param topic topic which sent the message
     * @param dbMessageId database ID of the message.
     * @param data updated content of the message. Must not be null.
     * @return true on success, false otherwise
     */
    func msgSDRaftUpdate(topic: Topic, dbMessageId: UInt64, data: Drafty) -> Bool
    
    /**
     * Message is ready to be sent to the server.
     *
     * @param topic topic which sent the message
     * @param dbMessageId database ID of the message.
     * @param data updated content of the message. If null only status is updated.
     * @return true on success, false otherwise
     */
    func msgReady(topic: Topic, dbMessageId:Int64, data: Drafty) -> Bool
    
    /**
     * Delete message by database id.
     */
    func msgDiscard(topic: Topic, dbMessageId: Int64) -> Bool
    
    /**
     * Message delivered to the server and received a real seq ID.
     *
     * @param topic topic which sent the message.
     * @param dbMessageId database ID of the message.
     * @param timestamp server timestamp.
     * @param seq server-issued message seqId.
     * @return true on success, false otherwise     *
     */
    func msgDelivered(topic: Topic, dbMessageId: Int64, timestamp: Date, seq: Int) -> Bool
    /** Mark messages for deletion by range */
    func msgMarkToDelete(topic: Topic, fromId: Int, toId: Int, markAsHard: Bool) -> Bool
    /** Mark messages for deletion by seq ID list */
    func msgMarkToDelete(topic: Topic, list: [Int], markAsHard: Bool) -> Bool
    /** Delete messages */
    @discardableResult
    func msgDelete(topic: Topic, delId: Int, fromId: Int, toId: Int) -> Bool
    /** Delete messages */
    func msgDelete(topic: Topic, delId: Int, list: [Int]) -> Bool
    /** Set recv value for a given subscriber */
    @discardableResult
    func msgRecvByRemote(sub: Subscription, recv: Int) -> Bool
    /** Set read value for a given subscriber */
    @discardableResult
    func msgReadByRemote(sub: Subscription, read: Int) -> Bool
    
    func getMessageById<T: Message>(topic: Topic, messageId: String) ->T
    
    func getQueuedMessages<T: Message>(topic: Topic) ->T
    
    func getQueuedMessageDeletes(topic: Topic, hard: Bool) -> [Int]
    
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
