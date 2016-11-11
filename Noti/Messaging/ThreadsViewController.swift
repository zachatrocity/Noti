//
//  ThreadsViewController.swift
//  Noti
//
//  Created by Brian Clymer on 10/22/16.
//  Copyright © 2016 Oberon. All rights reserved.
//

import Cocoa

class ThreadsViewController: NSViewController {

    @IBOutlet fileprivate var tableView: NSTableView!

    private let parentVc: NSViewController?

    fileprivate let smsService: SmsService
    
    fileprivate var threadVc: ThreadViewController?
    fileprivate var threads = [ThreadPreview]() {
        didSet {
            tableView.reloadData()
        }
    }

    init(smsService: SmsService, parentVc: NSViewController?) {
        self.smsService = smsService
        self.parentVc = parentVc
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(NSNib.init(nibNamed: "ThreadTableCellView", bundle: nil), forIdentifier: "ThreadCell")

        smsService.fetchThreads { [weak self] threads in
            self?.threads = threads
        }
    }

    @IBAction func tappedBack(sender: Any?) {
        self.view.window?.contentViewController = self.parentVc
    }
    
}

extension ThreadsViewController: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return threads.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "ThreadCell", owner: nil) as! ThreadTableCellView
        cell.label.stringValue = threads[row].recipients.first?.name ?? "Unknown"
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let threadId = threads[tableView.selectedRow].id
        let threadVc = ThreadViewController(threadId: threadId, smsService: self.smsService, parentVc: self)
        self.view.window?.contentViewController = threadVc
        self.threadVc = threadVc
    }
}
