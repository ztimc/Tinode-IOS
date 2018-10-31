//
//  ChatMessageView.swift
//  TinodeSample
//
//  Created by ztimc on 2018/10/31.
//  Copyright © 2018 sabinetek. All rights reserved.
//

import UIKit
import SnapKit

class ChatMessageView: UIView {
    
    
    lazy var inputField: UITextField = {
        return UITextField()
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("发送", for: UIControl.State.normal)
        return button
    }()
    
    lazy var contentView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(inputField)
        addSubview(sendButton)
        addSubview(contentView)
        self.setupConstraints()
    }
    
    func setupConstraints() {
        
        sendButton.snp.makeConstraints{ make in
            make.right.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(10)
            make.size.equalTo(CGSize(width: 100, height: 50))
        }
        
        inputField.snp.makeConstraints{ make in
            make.right.equalTo(sendButton.snp.left).offset(20)
            make.bottom.equalTo(self).offset(10)
            make.left.equalTo(self).offset(10)
            make.height.equalTo(sendButton)
        }
        
        contentView.snp.makeConstraints{ make in
            make.bottom.equalTo(inputField)
            make.size.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

