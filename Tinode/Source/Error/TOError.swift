//
//  TOError.swift
//  Tinode
//
//  Created by ztimc on 2018/10/14.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

public class TOError: Error {
    public var reson: String?
    public var code: Int?
    public var err: String?
    
    public init(err: String?, code: Int?, reson: String?) {
        self.err  = err
        self.code = code
        self.reson = reson
    }
    
    init(err: String?) {
        self.err = err
    }
    
}
