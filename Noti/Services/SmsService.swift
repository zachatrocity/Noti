//
//  SmsService.swift
//  Noti
//
//  Created by Brian Clymer on 10/22/16.
//  Copyright © 2016 Oberon. All rights reserved.
//

import Foundation
import Alamofire

class SmsService {

    private let token: String
    private let deviceId: String

    init(token: String, deviceId: String = "ujE5MF7z1Uasjz5ho2YKDA") {
        self.token = token
        self.deviceId = deviceId
    }

    func fetchThreads() {
        let headers = [
            "Access-Token": token
        ]
        Alamofire.request("https://api.pushbullet.com/v2/permanents/\(deviceId)_threads", method: .get, headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }
    }

}
