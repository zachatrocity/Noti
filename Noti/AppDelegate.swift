//
//  AppDelegate.swift
//  Noti
//
//  Created by Jari on 22/06/16.
//  Copyright © 2016 Jari Zwarts. All rights reserved.
//

import Cocoa
import Starscream

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private(set) var pushManager: PushManager?
    private var iwc: NSWindowController?
    
    func loadPushManager() {
        let token = UserDefaults.standard.string(forKey: "token")
        
        if(token != nil) {
            pushManager = PushManager(token: token!)
        } else {
            print("WARN: PushManager not initialized because of missing token. Displaying Intro")
            
            if(pushManager != nil) {
                pushManager!.disconnect()
            }
            
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            iwc = storyboard.instantiateController(withIdentifier: "IntroWindowController") as? NSWindowController
            NSApplication.shared().activate(ignoringOtherApps: true)
            iwc!.showWindow(self)
            iwc!.window?.makeKeyAndOrderFront(self)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadPushManager()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

