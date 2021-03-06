//
//  ViewController.swift
//  TinodeSample
//
//  Created by ztimc on 2018/10/11.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import UIKit
import Tinode

class ViewController: UIViewController {
    
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var tinode: Tinode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tinode = getTinode()
    }

    @IBAction func onLoginClick(_ sender: UIButton) {
        if let user = userNameText.text, let pwd = passwordText.text {
            tinode?.login(userName: user, password: pwd)
                .then(result: {  (msg) in
                    DispatchQueue.main.async {
                        let indexVC = IndexViewController()
                        let transtition = CATransition()
                        transtition.duration = 0.5
                        transtition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                        UIApplication.shared.keyWindow?.layer.add(transtition, forKey: "animation")
                        UIApplication.shared.keyWindow?.rootViewController = indexVC
                    }
                    return nil
            }) { error in
                    print(error.err ?? "登陆失败")
                    return nil
                }
        }
    }
    
}

