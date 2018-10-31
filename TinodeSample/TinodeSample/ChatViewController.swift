//
//  ChatViewController.swift
//  TinodeSample
//
//  Created by ztimc on 2018/10/27.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import UIKit
import SnapKit
import Tinode

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var chatView: UITableView!
    var tinode: Tinode!
    var topics: [ComTopic] = [ComTopic]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tinode = getTinode()
        
        chatView = UITableView()
        chatView.delegate = self
        chatView.dataSource = self
        self.view.addSubview(chatView)
        
        chatView.snp.makeConstraints { (make) in
            make.size.equalTo(self.view)
        }
        
        let topic = tinode.getMeTopic()
        topic?.onSubsUpdated = {
            self.topics = self.tinode.getFilteredTopics(type: .user, date: nil)
            DispatchQueue.main.async {
                self.chatView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let messageController = MessageViewController()
        self.navigationController?.pushViewController(messageController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = topics[indexPath.row].getPub()?.getStringValue(key: "fn")
        
        return cell
    }

}
