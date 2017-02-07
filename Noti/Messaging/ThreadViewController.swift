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
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var imageView: NSImageView!

    private var parentVc: NSViewController?
    private let thread: ThreadPreview
    private let device: Device
    
    public let sentColor = CGColor.init(red: 0.24, green: 0.47, blue: 0.85, alpha: 1.0)
    public let receivedColor = CGColor.init(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)


    fileprivate let smsService: SmsService
    fileprivate var messages = [Message]() {
        didSet {
            tableView.reloadData()
            tableView.scrollRowToVisible(messages.count - 1)
        }
    }

    init(thread: ThreadPreview, smsService: SmsService, parentVc: NSViewController?) {
        self.smsService = smsService
        self.parentVc = parentVc
        self.thread = thread
        self.device = smsService.device
        
        
        super.init(nibName: nil, bundle: nil)!

        NotificationCenter.default.addObserver(forName: Notification.Name("HackyRepository"), object: nil, queue: nil, using: { [weak self] _ in
            if let messages = SharedAppDelegate.cache.messages[thread.id] {
                self?.messages = messages.reversed()
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

        tableView.register(NSNib.init(nibNamed: "MessageTableCellView", bundle: nil), forIdentifier: "MessageCell")
        
        if let checkedUrl = URL(string: (thread.recipients.first?.imageUrl ?? "https://placeholdit.imgix.net/~text?txtsize=5&txt=32%C3%9732&w=32&h=32")) {
            downloadImage(url: checkedUrl)
        }
        
        
        tableView.intercellSpacing = NSSize(width: 15.0, height: 10.0)
        tableView.gridColor = NSColor.clear
        
        self.titleField.stringValue = thread.recipients.first?.name ?? "Unknown"
        self.textField.layer?.cornerRadius = 15.0
        
        
        smsService.fetchThreadMessages(threadId: self.thread.id, callback: { [weak self] messages in
            self?.messages = messages.reversed()
        })
    }

    @IBAction func tappedSend(sender: NSButton) {
        let message = self.textField.stringValue
        self.thread.recipients.forEach { (recipient) in
            self.smsService.ephemeralService.sendSms(
                message: message,
                device: self.device,
                sourceUserId: SharedAppDelegate.pushManager!.user!.iden, // TODO definitely needs to be refactored.
                conversationId: recipient.number)
        }
    }

    @IBAction func tappedBack(sender: NSButton) {
        self.view.window?.contentViewController = self.parentVc
        self.parentVc = nil
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { () -> Void in
                let img = NSImage(data: data)
                let radius = ((img?.size.width)! / CGFloat(2))
                
                self.imageView.image = RoundedImage.create(Int(radius), source: img!)
                
            }
        }
    }

}

extension ThreadViewController: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "MessageCell", owner: nil) as! MessageTableCellView
        let receivedMsg = messages[row].direction == "incoming"
        
        cell.wantsLayer = true
        cell.layer?.cornerRadius = 7.0
        cell.layer?.masksToBounds = false
        cell.label.stringValue = messages[row].body
        cell.label.alignment = receivedMsg ? NSTextAlignment.left : NSTextAlignment.right
        cell.layer?.backgroundColor = receivedMsg ? self.receivedColor : self.sentColor
        cell.label.textColor = receivedMsg ? NSColor.black : NSColor.white
        
        cell.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        //check for image urls and add to cell
        if (messages[row].imageUrls.count > 0){
            for urlStr in messages[row].imageUrls {
                let url = URL(string: urlStr)
                downloadImageAttachment(url: url!, cell: cell)
            }
        }
        
        return cell
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let mockCell = NSTextField()
        mockCell.font = NSFont.systemFont(ofSize: 13)
        mockCell.stringValue = messages[row].body
        let size = mockCell.sizeThatFits(NSSize(width: tableView.frame.width - 16, height: CGFloat.greatestFiniteMagnitude))
        return size.height + 16 // 8 padding on both sides
    }
    
    func downloadImageAttachment(url: URL, cell: MessageTableCellView) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { () -> Void in
                let imageView = NSImageView.init(frame: NSRect(x: 5, y: 5, width: 128, height: 128))
                imageView.image = NSImage(data: data)
                
                cell.addSubview(imageView)
                
            }
        }
    }

    
}
