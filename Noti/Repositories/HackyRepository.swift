//
//  HackyRepository.swift
//  Noti
//
//  Created by Brian Clymer on 11/10/16.
//  Copyright © 2016 Oberon. All rights reserved.
//

import Foundation

class HackyRepository {

    var token: String = ""
    var devices = [Device]()
    // the key is a device id
    var threads = [String: ThreadPreview]()
    // the key is a thread id
    var messages = [String: Message]()

}
