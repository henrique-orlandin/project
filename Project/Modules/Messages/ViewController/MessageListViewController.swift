//
//  MessegesListViewController.swift
//  Jam
//
//  Created by Henri on 2020-02-05.
//  Copyright © 2020 Henrique Orlandin. All rights reserved.
//

import UIKit

class MessageListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var provider: MessageListProvider! = nil
    var chat: ChatListViewModel?
    var chat_id: String?
    private var keyboardShow = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var messageSenderConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewConstraint: NSLayoutConstraint!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if provider == nil {
            self.provider = MessageListProvider()
            self.provider.delegate = self
        }
        
        tabBarController?.tabBar.isHidden = true
        if let chat = chat {
            self.provider.loadMessages(chat: chat.id)
            
            var title = chat.user?.name
            if let band = chat.band {
                title = band.name
            }
            navigationItem.title = title
        } else if let chat_id = chat_id {
            self.provider.loadChat(chat: chat_id)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInsetsForKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInsetsForKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func send(_ sender: Any) {
        if let chat = chat, let message = inputTextField.text, message != "" {
            provider.saveBand(chat: chat.id, message: message)
        }
    }
    
    @objc func adjustInsetsForKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let show = (notification.name == UIResponder.keyboardWillShowNotification) ? true : false
        if show == keyboardShow { return }
        
        var safeArea: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            safeArea = view.safeAreaInsets.bottom
        }
        
        let adjustmentHeight = keyboardFrame.height * (show ? 1 : -1)
        
        keyboardShow = show
        
        messageSenderConstraint.constant = adjustmentHeight > 0 ? adjustmentHeight - safeArea : 0
        collectionViewConstraint.constant = adjustmentHeight > 0 ? adjustmentHeight + 48 - safeArea : safeArea + 20
        
        
        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            el in
            if show {
                self.scrollToBottom()
            }
        })
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return provider.numberOfMessages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCellItem", for: indexPath)
        //get band related to table row position
        let messageViewModel = self.provider.getMessageViewModel(row: indexPath.row, section: indexPath.section)
        
        if let cell = cell as? MessageCollectionViewCell {
            if let message = messageViewModel {
                cell.cellFormat(message: message)
            }
            return cell
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let messageViewModel = self.provider.getMessageViewModel(row: indexPath.row, section: indexPath.section),
           let content = messageViewModel.content {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCellItem", for: indexPath) as! MessageCollectionViewCell
            cell.content.text = content
            let fixedWidth = cell.content.frame.size.width
            let newSize: CGSize = cell.content.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))

            return CGSize(width: view.frame.width, height: newSize.height + 15)
        }
        return CGSize(width: view.frame.width, height: 100)
    }

    
    func scrollToBottom () {
        let lastItemIndex = NSIndexPath(item: provider.numberOfMessages - 1, section: 0)
        collectionView.scrollToItem(at: lastItemIndex as IndexPath, at: .bottom, animated: true)
    }
}

extension MessageListViewController: MessageListProviderProtocol {
    func providerDidFinishLoadingChat(provider of: MessageListProvider) {
        
        if let chat = provider.getChat() {
            self.chat = ChatListViewModel(chat)
            self.provider.loadMessages(chat: chat.id)
            
            var title = chat.user?.name
            if let band = chat.band {
                title = band.name
            }
            navigationItem.title = title
        }
    }
    
    func providerDidFinishAddingMessage(provider of: MessageListProvider) {
        let indexPath = IndexPath(item: provider.numberOfMessages - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        inputTextField.text = ""
        scrollToBottom()
    }
    
    func providerDidFinishUpdatedDataset(provider of: MessageListProvider) {
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 2, height: contentSize.height), animated: true)
        provider.startListeningForChanges(chat: chat!.id)
    }
}
