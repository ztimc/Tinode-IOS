//
//  UIViewController+Tinode.swift
//  TinodeSample
//
//  Created by ztimc on 2018/10/18.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation
import Tinode

extension UIViewController {
    func getTinode() -> Tinode?{
        let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        return app.tinode
    }
}
