//
//  String+Base64.swift
//  Tinode
//
//  Created by ztimc on 2018/10/13.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
