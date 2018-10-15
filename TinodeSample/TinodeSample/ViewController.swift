//
//  ViewController.swift
//  TinodeSample
//
//  Created by ztimc on 2018/10/11.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import UIKit
import Tinode

class ViewController: UIViewController , TinodeDelegate {
    
    var tinode: Tinode?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTinode()
    }
    
    func initTinode() {
        var config = [] as TinodeConfigration
        config = [.log(true), .apikey("AQEAAAABAAD_rAp4DJh05a1HAwFT3A6K"), .tls(false),.appName("icn"), .reconnects(false)]
        
        tinode = Tinode(config: config)
        tinode?.connect(host: "47.104.30.12:6060")
        
        tinode?.delegete = self
    }
    
    func TinodeDidConnect(tinode: Tinode) {
        tinode.login(userName: "bob", password: "123").then(result: { msg in
            print("登陆成功")
        }) { error in
            print(error.err ?? "登陆失败")
        }
    }
    
    func TinodeDidDisconnect(tinode: Tinode, error: Error?) {
        
    }

}

