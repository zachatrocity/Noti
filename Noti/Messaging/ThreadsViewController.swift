//
//  ThreadsViewController.swift
//  Noti
//
//  Created by Brian Clymer on 10/22/16.
//  Copyright © 2016 Oberon. All rights reserved.
//

import Cocoa

class ThreadsViewController: NSViewController {

    @IBOutlet private var collectionView: NSCollectionView!

    private let smsService: SmsService
    fileprivate var threads = [ThreadPreview]() {
        didSet {
            collectionView.reloadData()
        }
    }

    init(smsService: SmsService) {
        self.smsService = smsService
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(ThreadCollectionViewItem.self, forItemWithIdentifier: "Thread")

        smsService.fetchThreads { [weak self] threads in
            self?.threads = threads
        }
    }
    
}

extension ThreadsViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return threads.count
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {

    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "Thread", for: indexPath) as! ThreadCollectionViewItem
        item.label.stringValue = threads[indexPath.item].recipients.first?.name ?? "Unknown"
        return item
    }
    
}
