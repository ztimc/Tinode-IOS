//
//  MessageViewController.swift
//  TinodeSample
//
//  Created by ztimc on 2018/10/31.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import UIKit
import SnapKit
import Tinode

class MessageViewController: UIViewController {

    var topicName: String?
    var chatView: ChatMessageView!
    var tinode: Tinode!
    var topic: ComTopic!
    
    var contents: [String] = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatView = ChatMessageView(frame: self.view.bounds)
        self.view.addSubview(chatView)
        self.view.backgroundColor = UIColor.green
        
        tinode = getTinode()
        topic = tinode.getTopic(name: topicName!)
        
        attachTopic()
        
        topic.onData = { data in
           print(data)
        }
    }
    
    func attachTopic() {
        let getMeta = topic.getMetaGetBuilder()
            .withGetDesc()
            .withGetSub()
            .withGetData()
            .withGetDel()
            .build()
        let setMate = MsgSetMeta<VCard,String>()
        
        topic.subscribe(set: setMate, get: getMeta).then()
    }
    
    func loadData() {
        topic.getMeta(topic.getMetaGetBuilder().withGetEarlierData(limit: 20).build()).then()
    }

}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = contents[indexPath.row]
        
        return cell
    }
    
    
}
