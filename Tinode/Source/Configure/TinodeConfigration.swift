//
//  TinodeConfigration.swift
//  tinode
//
//  Created by ztimc on 2018/10/11.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public struct TinodeConfigration : ExpressibleByArrayLiteral, Collection, MutableCollection {
    
    // MARK: Typealiases
    
    /// Type of element stored.
    public typealias Element = TinodeOption
    
    /// Index type.
    public typealias Index = Array<TinodeOption>.Index
    
    /// Iterator type.
    public typealias Iterator = Array<TinodeOption>.Iterator
    
    /// SubSequence type.
    public typealias SubSequence =  Array<TinodeOption>.SubSequence
    
    // MARK: Properties
    
    private var backingArray = [TinodeOption]()
    
    public var startIndex: Index {
        return backingArray.startIndex
    }
    
    public var endIndex: Index {
        return backingArray.endIndex
    }
    
    public var isEmpty: Bool {
        return backingArray.isEmpty
    }
    
    public var count: Int {
        return backingArray.count
    }
    
    public var first: TinodeOption? {
        return backingArray.first
    }
    
    public subscript(position: Index) -> Element {
        get {
            return backingArray[position]
        }
        
        set {
            backingArray[position] = newValue
        }
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        get {
            return backingArray[bounds]
        }
        
        set {
            backingArray[bounds] = newValue
        }
    }
    
    
    // MARK: Initializers
    
    /// Creates a new `TinodeConfigration` from an array literal.
    ///
    /// - parameter arrayLiteral: The elements.
    public init(arrayLiteral elements: Element...) {
        backingArray = elements
    }
    
    // MARK: Methods
    
    /// Creates an iterator for this collection.
    ///
    /// - returns: An iterator over this collection.
    public func makeIterator() -> Iterator {
        return backingArray.makeIterator()
    }
    
    /// - returns: The index after index.
    public func index(after i: Index) -> Index {
        return backingArray.index(after: i)
    }
    
    /// Special method that inserts `element` into the collection, replacing any other instances of `element`.
    ///
    /// - parameter element: The element to insert.
    /// - parameter replacing: Whether to replace any occurrences of element to the new item. Default is `true`.
    public mutating func insert(_ element: Element, replacing replace: Bool = true) {
        for i in 0..<backingArray.count where backingArray[i] == element {
            guard replace else { return }
            
            backingArray[i] = element
            
            return
        }
        
        backingArray.append(element)
    }
    
}

/// Declares that a type can set configs from a `SocketIOClientConfiguration`.
public protocol ConfigSettable {
    // MARK: Methods
    
    /// Called when an `ConfigSettable` should set/update its configs from a given configuration.
    ///
    /// - parameter config: The `TinodeConfigration` that should be used to set/update configs.
    mutating func setConfigs(_ config: TinodeConfigration)
}
