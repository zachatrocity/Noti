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
    private let thread: ThreadPreview
    private let device: Device

    fileprivate let smsService: SmsService
    fileprivate var messages = [Message]() {
        didSet {
            tableView.reloadData()
        }
    }

    init(thread: ThreadPreview, smsService: SmsService, parentVc: NSViewController?) {
        self.smsService = smsService
        self.parentVc = parentVc
        self.thread = thread
        self.device = smsService.device
        super.init(nibName: nil, bundle: nil)!
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(NSNib.init(nibNamed: "MessageTableCellView", bundle: nil), forIdentifier: "MessageCell")

        smsService.fetchThreadMessages(threadId: self.thread.id, callback: { [weak self] messages in
            self?.messages = messages.reversed()
        })
    }

    // TODO definitely needs to be refactored.
    @IBAction func tappedSend(sender: NSButton) {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let message = self.textField.stringValue
        self.thread.recipients.forEach { (recipient) in
            self.smsService.ephemeralService.sendSms(
                message: message,
                device: self.device,
                sourceUserId: appDelegate.pushManager!.userInfo!["iden"].stringValue,
                conversationId: recipient.number)
        }
    }

    @IBAction func tappedBack(sender: NSButton) {
        self.view.window?.contentViewController = self.parentVc
        self.parentVc = nil
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
