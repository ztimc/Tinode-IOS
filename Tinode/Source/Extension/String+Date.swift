//
//  String+Date.swift
//  Tinode
//
//  Created by ztimc on 2018/10/23.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

extension String {
    func compareDate(date: String?) -> ComparisonResult {
        if let d1 = Formatter.iso8601.date(from: self),
            let d2 = Formatter.iso8601.date(from: date ?? ""){
            return d1.compare(d2)
        }
        return .orderedSame
    }
}
