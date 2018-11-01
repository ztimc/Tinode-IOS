//
//  PromisedReply.swift
//  Tinode
//
//  Created by ztimc on 2018/10/14.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

/// This `Pine` is callback util
public class Pine<T> {
    
    public private(set) var state = State.WAITING
    
    
    private var onSuccess: ((T) -> Pine<T>?)?
    private var onFailure: ((TOError) -> Pine<T>?)?
    
    private var nextPine: Pine<T>?
    
    private var result: T?
    private var err: TOError?
    
    public init() {
        state = .WAITING
    }
    
    public init(_ result: T) {
        state = .RESOLVED
        self.result = result
    }
    
    public init(_ err: TOError) {
        state = .REJECTED
        self.err = err
    }
    
    @discardableResult public func then(result: ((T) -> Pine<T>?)?, failure: ((TOError) -> Pine<T>?)?) -> Pine<T> {
        
        if nextPine != nil {
            return Pine<T>(TOError(err: "Multiple calls to thenApply are not supported", code: -1, reson: "error"))
        }
        
        onSuccess = result
        onFailure = failure
        nextPine = Pine()
        
        switch state {
        case .WAITING:
            break
        case .RESOLVED:
            callOnSuccess(result: self.result!)
            break
        case .REJECTED:
            callOnFailure(error: self.err!)
            break
        }
        
        return nextPine!
    }
    
    @discardableResult public func then(result: @escaping ((T) -> Pine<T>?)) -> Pine<T> {
        return self.then(result: result, failure: nil)
    }
    
    @discardableResult public func then(failure: @escaping ((TOError) -> Pine<T>?)) -> Pine<T>{
        return self.then(result: nil, failure: failure)
    }
    
    @discardableResult public func then() -> Pine<T> {
        return  self.then(result: nil, failure: nil)
    }
    
    func reject(error: TOError) {
        if state == .WAITING {
            state = .REJECTED
            callOnFailure(error: error)
        }
    }
    
    func resolve(result: T) {
        if state == .WAITING{
            self.state  = .RESOLVED
            self.result = result
            callOnSuccess(result: result)
        }
    }
    
    private func callOnSuccess(result: T) {
        let ret = onSuccess?(result)
        handleSuccess(ret: ret)
    }
    
    private func callOnFailure(error: TOError){
        handleFailure(error: error)
    }
    
    private func handleSuccess(ret: Pine<T>?) {
        if nextPine == nil {
            return
        }
        
        if ret == nil {
            return
        }
        
        switch ret!.state {
        case .REJECTED:
            nextPine!.reject(error: ret!.err!)
            break
        case .RESOLVED:
            nextPine!.resolve(result: ret!.result!)
            break
        default:
            ret?.insertNextPine(next: nextPine)
            break
        }
    }
    
    private func insertNextPine(next: Pine<T>?) {
        next?.insertNextPine(next: nextPine)
        nextPine = next
    }
    
    private func handleFailure(error: TOError) {
        if let f = onFailure {
            handleSuccess(ret: f(error))
        } else {
            nextPine?.reject(error: error)
        }
    }
    
    public enum State {
        case WAITING
        case RESOLVED
        case REJECTED
    }
}
