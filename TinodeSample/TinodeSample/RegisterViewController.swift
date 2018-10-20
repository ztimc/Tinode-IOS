//
//  RegisterViewController.swift
//  TinodeSample
//
//  Created by ztimc on 2018/10/18.
//  Copyright © 2018年 sabinetek. All rights reserved.
//

import Foundation
import UIKit
import Tinode

class RegisterViewController : UIViewController {
   
    @IBOutlet weak var userText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var telText: UITextField!
    
    @IBAction func onRegister(_ sender: UIButton) {
        if let user = userText.text,
            let password = passwordText.text,
            let name = nameText.text,
            let tel = telText.text {
            
            let card = VCard(name: name, avatar: nil)
            
            getTinode()?.createAccountBasic(uname: user,
                                            password: password,
                                            login: true,
                                            tags: nil,
                                            desc: MetaSetDesc<VCard,String?>.init(p: card, r: ""),
                                            cred: Credential.append(creds: [Credential](), c: Credential(meth: "tel", val: tel)))
                .then(result: { [weak self]  (msg) -> Pine<ServerMessage>? in
                    guard let weakSelf = self else { return nil }
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let controller = sb.instantiateViewController(withIdentifier: "ValidateViewController") as! ValidateViewController
                    
                    let methods = msg.ctrl?.params?.getArrayStringValue(key: "cred")
                    
                    for method in methods! {
                        controller.method = method
                    }
                    DispatchQueue.main.sync {
                        weakSelf.navigationController?.pushViewController(controller, animated: true)
                    }
                    return nil
                }, failure: { (TOError) -> Pine<ServerMessage>? in
                    return nil
                })
            
        }
    }
}
