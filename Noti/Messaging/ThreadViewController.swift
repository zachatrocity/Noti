//
//  ThreadViewController.swift
//  Noti
//
//  Created by Brian Clymer on 11/10/16.
//  Copyright © 2016 Oberon. All rights reserved.
//

import Cocoa

class ThreadViewController: NSViewController {

    @IBOutlet fileprivate var tableView: NSTableView!
    @IBOutlet fileprivate var textField: NSTextField!
    @IBOutlet fileprivate var button: NSButton!

    private var parentVc: NSViewController?
    private let threadId: String

    fileprivate let smsService: SmsService
    fileprivate var messages = [Message]() {
        didSet {
            tableView.reloadData()
        }
    }

    init(threadId: String, smsService: SmsService, parentVc: NSViewController?) {
        self.smsService = smsService
        self.parentVc = parentVc
        self.threadId = threadId
        super.init(nibName: nil, bundle: nil)!
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func dismissViewController(_ viewController: NSViewController) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(NSNib.init(nibNamed: "MessageTableCellView", bundle: nil), forIdentifier: "MessageCell")

        smsService.fetchThreadMessages(threadId: self.threadId, callback: { [weak self] messages in
            self?.messages = messages.reversed()
        })
    }

    @IBAction func tappedSend(sender: NSButton) {
        print("I would send \(self.textField.stringValue) if I knew how.")
    }

    @IBAction func tappedBack(sender: NSButton) {
        self.view.window?.contentViewController = self.parentVc
        self.parentVc = nil
        // TODO check that this VC deallocs
    }

}

extension ThreadViewController: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "MessageCell", owner: nil) as! MessageTableCellView
        cell.label.stringValue = messages[row].body
        return cell
    }
    
}
