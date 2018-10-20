//
//  ValidateViewController.swift
//  TinodeSample
//
//  Created by ztimc on 2018/10/19.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation
import UIKit
import Tinode

class ValidateViewController: UIViewController {
    @IBOutlet weak var textNumber: UITextField!
    
    public var method: String?
    
    @IBAction func onConfirm(_ sender: UIButton) {
        if let number = textNumber.text {
            var cs = [Credential]()
            cs.append(Credential(meth: method!, resp: number))
            getTinode()?.loginByToken(token: getTinode()?.token! ?? "", cred: cs)
                .then(result: { (msg) -> Pine<ServerMessage>? in
                    if let code = msg.ctrl?.code {
                        if code >= 300 {
                            print("验证失败:")
                        } else {
                            print("验证成功:", msg)
                        }
                    }
                    return nil
                }, failure: { (err) -> Pine<ServerMessage>? in
                    
                    return nil
                })
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
