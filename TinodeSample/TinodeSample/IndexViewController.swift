//
//  IndexViewController.swift
//  TinodeSample
//
//  Created by ztimc on 2018/10/27.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import UIKit
import Tinode

class IndexViewController: UITabBarController {

    var tinode: Tinode!
    var meTopic: MeTopic!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tinode = getTinode()
        meTopic = MeTopic(tinode: tinode)
        topicAttach()
        
        let chatVC = ChatViewController()
        chatVC.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 0)
        
        let contactsVC = ContactsController()
        contactsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        let tabBarList = [chatVC, contactsVC].map { (vc) -> UIViewController in
            return UINavigationController(rootViewController: vc)
        }
        
        viewControllers = tabBarList
    }
    
    
    public func topicAttach() {
        let getMeta = meTopic.getMetaGetBuilder()
            .withGetDesc()
            .withGetSub()
            .build()
        let setMeta = MsgSetMeta<VCard,String>()
        
        meTopic!.subscribe(set: setMeta,
                           get: getMeta)
            .then(result: { (msg) -> Pine<ServerMessage>? in
                print(msg)
                return nil
            }, failure: { (error) -> Pine<ServerMessage>? in
                print(error)
                return nil
            })
 
    }

}

