//
//  SystemUtils.swift
//  Tinode
//
//  Created by ztimc on 2018/10/13.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation


class SystemUtils {
    
    static func getCurrentLanguage() -> String {
        return Locale.preferredLanguages[0] as String
    }
    
    static func getSystemVersion() -> String {
        return String(UIDevice.current.systemVersion)
    }
}
