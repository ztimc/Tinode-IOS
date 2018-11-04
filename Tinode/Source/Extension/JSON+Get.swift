//
//  JSON+Get.swift
//  Tinode
//
//  Created by ztimc on 2018/10/23.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation

extension JSON {
    
    public func getStringValue(key: String) -> String?{
        switch self {
        case .dictionary(let dict):
            switch dict[key] {
            case .string(let val)?:
                
                return val
            default:
                break;
            }
            break
        default:
            break;
        }
        return nil
    }
    
    public func getIntValue(key: String) -> Int?{
        switch self {
        case .dictionary(let dict):
            switch dict[key] {
            case .int(let val)?:
                return val
            default:
                break;
            }
            break
        default:
            break;
        }
        return nil
    }
    
    public func getArrayStringValue(key: String) -> [String] {
        var arr: [String] = [String]()
        switch self {
        case .dictionary(let dict):
            switch dict[key] {
            case .array(let values)?:
                for value in values {
                    switch value {
                    case .string(let v):
                        arr.append(v)
                        break;
                    default:
                        break;
                    }
                }
                break;
            default:
                break;
            }
            break
        default:
            break;
        }
        return arr
    }
    
    public func getDictionary(key: String) -> Dictionary<String, String>{
        var dict: Dictionary<String, String> = Dictionary()
    
        switch self {
        case .dictionary(let d1):
            switch d1[key] {
            case .dictionary(let d2)?:
                for (k, v) in d2 {
                    switch v {
                    case .string(let value):
                        dict[k] = value
                        break;
                    default:
                        break;
                    }
                }
                break;
            default:
                break;
            }
            break
        default:
            break;
        }
        
        return dict
    }
}
