//
//  Acs.swift
//  Tinode
//
//  Created by ztimc on 2018/10/22.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct Acs : Codable{
    var given: String?
    var want:  String?
    var mode:  String?
    
    init() {
    }
    
    init(acs: Acs) {
        given =  acs.given
        want  =  acs.want
        mode  =  acs.mode
    }
    
    init(am: Dictionary<String,String>) {
        given =  am["given"]!
        want  =  am["want"]!
        mode  =  am["mode"]!
    }

    public mutating func merge(am: Acs?) -> Bool {
        var changed = 0
        
        if am != nil {
            if am?.given != nil {
                if given!.merge(am?.given) {
                    changed += 1
                }
            }
            
            if am?.want != nil {
                if want!.merge(am?.want) {
                    changed += 1
                }
            }
            if am?.mode != nil {
                if mode!.merge(am?.mode) {
                    changed += 1
                }
            } else {
                if let ah = String.and(want, a2: given) {
                    if ah != mode {
                        changed += 1
                        mode = ah
                    }
                }
            }
            
        }
        
        return changed > 0
    }
    
    public mutating func merge(dict : Dictionary<String,String>?) -> Bool {
        var changed = 0
        
        if let am = dict {
            if let gi = am["given"] {
                if given!.merge(gi) {
                    changed += 1
                }
            }
            
            if let wt = am["want"] {
                if want!.merge(wt) {
                    changed += 1
                }
            }
            
            if let mo = am["mode"] {
                if mode!.merge(mo) {
                    changed += 1
                }
            } else {
                if let ah = String.and(want, a2: given) {
                    if ah != mode {
                        changed += 1
                        mode = ah
                    }
                }
            }
        }
        
        return changed > 0
    }
    
    @discardableResult
    public mutating func update(ac: AccessChange?) -> Bool {
        var change = 0
        if let ace = ac {
            if ace.given != nil {
                if given != nil {
                    if given!.update(ace.given!) {
                        change += 1
                    }
                } else {
                    given =  ace.given
                    if let _ =  given?.isDefined() {
                        change += 1
                    }
                }
            }
            
            if ace.want != nil {
                if want != nil {
                    if want!.update(ace.want!) {
                        change += 1
                    }
                } else {
                    want = ace.want
                    if let _ =  want?.isDefined() {
                        change += 1
                    }
                }
            }
            
            if let ah = String.and(want, a2: given) {
                if ah != mode {
                    change += 1
                    mode = ah
                }
            }
        }
        return change > 0
    }
    
    public func equals(am: Acs) -> Bool {
        if  let a1m = am.mode,
            let a1w = am.want,
            let a1g = am.given,
            let a2m = mode,
            let a2w = want,
            let a2g = given {
            return a1m == a2m && a1w == a2w  && a1g == a2g
        }
        return false;
    }
    
    public func isReader() -> Bool {
        return mode!.isReader()
    }
    
    public func isWriter() -> Bool {
        return mode!.isWriter()
    }
    
    public func isMuted() -> Bool {
        return mode!.isMuted()
    }
    
    public func isAdmin() -> Bool {
        return mode!.isAdmin()
    }
    
    public func isDeleter() -> Bool {
        return mode!.isDeleter()
    }
    
    public func isOwner() -> Bool {
        return mode!.isOwner()
    }
    
    public func isJoiner() -> Bool {
        return mode!.isJoiner()
    }
    
    public func isModeDefined() -> Bool {
        return mode!.isDefined()
    }
    
    public func isGivenDefined() -> Bool {
        return given!.isDefined()
    }
    
    public func isWantDefined() -> Bool {
        return want!.isDefined()
    }
    
    public func isInvalid() -> Bool {
        return mode!.isInvalid()
    }
    
    
}
