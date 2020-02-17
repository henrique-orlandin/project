//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu

class ChatListViewController: UITableViewController {
    
    var provider: ChatListProvider! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = ChatListProvider()
        self.provider.delegate = self
        self.provider.loadChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    //return the number of rows for this table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.provider.numberOfChats
    }
    
    //executed for each cell on the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCellItem", for: indexPath)
        //get band related to table row position
        let chatViewModel = self.provider.getChatViewModel(row: indexPath.row, section: indexPath.section)
        
        if let cell = cell as? ChatTableViewCell {
            if let chat = chatViewModel {
                cell.cellFormat(chat: chat)
            }
            return cell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMessagesSegue" {
            if let viewController = segue.destination as? MessageListViewController {
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    let item = self.provider.getChatViewModel(row: indexPath.row, section: indexPath.section)
                    viewController.chat = item
                }
            }
        }
    }
    
}

extension ChatListViewController: ChatListProviderProtocol {
    func providerDidFinishUpdatedDataset(provider of: ChatListProvider) {
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
}
