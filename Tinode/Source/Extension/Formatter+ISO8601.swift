//
//  Formatter+ISO8601.swift
//  Tinode
//
//  Created by ztimc on 2018/10/20.
//  Copyright © 2018年 sabinetek. All rights reserved.
//
import Foundation

extension Formatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
}
