//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu

class ChatListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var provider: ChatListProvider! = nil
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = ChatListProvider()
        self.provider.delegate = self
        self.provider.loadChats()
        
        self.view.showSpinner(onView: self.view)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    //return the number of rows for this table
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.provider.numberOfChats
    }
    
    //executed for each cell on the table
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatCellItem", for: indexPath)
        //get band related to table row position
        let chatViewModel = self.provider.getChatViewModel(row: indexPath.row, section: indexPath.section)
        
        if let cell = cell as? ChatCollectionViewCell {
            if let chat = chatViewModel {
                cell.cellFormat(chat: chat)
            }
            return cell
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMessagesSegue" {
            if let viewController = segue.destination as? MessageListViewController,
               let cell = sender as? UICollectionViewCell,
               let indexPath = collectionView.indexPath(for: cell) {
                let item = self.provider.getChatViewModel(row: indexPath.row, section: indexPath.section)
                viewController.chat = item
            }
        }
    }
    
}

extension ChatListViewController: ChatListProviderProtocol {
    func providerDidFinishUpdatedDataset(provider of: ChatListProvider) {
        self.view.removeSpinner()
        self.collectionView.reloadData()
    }
}
