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
    
    fileprivate weak var threadVc: ThreadViewController?
    
    fileprivate var threads = [ThreadPreview]() {
        didSet {
            tableView.reloadData()
        }
    }

    init(smsService: SmsService, parentVc: NSViewController?) {
        self.smsService = smsService
        self.parentVc = parentVc
        super.init(nibName: nil, bundle: nil)!

        NotificationCenter.default.addObserver(forName: Notification.Name("HackyRepository"), object: nil, queue: nil, using: { [weak self] _ in
            if let threads = SharedAppDelegate.cache.threads[smsService.device.id] {
                self?.threads = threads
            }
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.window?.title = self.smsService.device.name
        

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
        cell.threadName.stringValue = threads[row].recipients.first?.name ?? "Unknown"
        cell.threadPreview.stringValue = threads[row].latest.body
        
        if let checkedUrl = URL(string: (threads[row].recipients.first?.imageUrl)! != "" ? (threads[row].recipients.first?.imageUrl)! : "https://placeholdit.imgix.net/~text?txt=&w=100&h=100") {
            downloadImage(url: checkedUrl, cell: cell)
        }
        
        
        return cell
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 58
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let thread = threads[tableView.selectedRow]
        let threadVc = ThreadViewController(thread: thread, smsService: self.smsService, parentVc: self)
        self.view.window?.contentViewController = threadVc
        self.threadVc = threadVc
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL, cell: ThreadTableCellView) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                if let img = NSImage(data: data){
                    let radius = ((img.size.width) / CGFloat(2))
                    
                    cell.threadAvatar?.image = RoundedImage.create(Int(radius), source: img)
                }
            }
        }
    }
}
