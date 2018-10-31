//
//  MessageViewController.swift
//  TinodeSample
//
//  Created by ztimc on 2018/10/31.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import UIKit
import SnapKit

class MessageViewController: UIViewController {

    var topicName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let chatView = ChatMessageView(frame: self.view.bounds)
        self.view.addSubview(chatView)
        self.view.backgroundColor = UIColor.red
    }

}
