//
//  PromisedReply.swift
//  Tinode
//
//  Created by ztimc on 2018/10/14.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

/// This `Mine` is callback util
public class Pine<T> {
    
    public private(set) var state = State.WAITING
    
    private var onSuccess: ((T) -> Void)?
    private var onFailure: ((TOError) -> Void)?
    
    
    public func then(result: @escaping ((T) -> Void), failure: @escaping ((TOError) -> Void)) {
        onSuccess = result
        onFailure = failure
        state     = .WAITING
    }
    
    public func then(result: @escaping ((T) -> Void)) {
        onSuccess = result
        state     = .WAITING
    }
    
    public func then(failure: @escaping ((TOError) -> Void)) {
        onFailure = failure
        state     = .WAITING
    }
    
    public func then() {
        state     = .WAITING
    }
    
    public func reject(error: TOError) {
        if state == .WAITING {
            state = .REJECTED
            onFailure?(error)
        }
    }
    
    public func resolve(result: T) {
        if state == .WAITING{
            self.state  = .RESOLVED
            onSuccess?(result)
        }
    }
    
    public enum State {
        case WAITING
        case RESOLVED
        case REJECTED
    }
}
