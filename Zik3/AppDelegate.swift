//
//  AppDelegate.swift
//  Zik3
//
//  Created by Nicolas Thomas on 03/05/2018.
//  Copyright © 2018 Nicolas Thomas. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let deviceState = DeviceState()
    var service: BTCommunicationServiceInterface?
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    let iconOff = NSImage(named: NSImage.Name(rawValue: "disc"))
    let iconOn = NSImage(named: NSImage.Name(rawValue: "conn"))
    
    var lastBatteryLevel: Int? = 0;
    
    @objc
    func toggleNoiseCancellation(sender: AnyObject) {
        let _ = service?.toggleAsyncNoiseCancellation(!self.deviceState.noiseCancellationEnabled)
    }
    
    @objc
    func toggleMaxNoiseCancellation(sender: AnyObject){
        if (self.deviceState.noiseControlLevelState == NoiseControlState.cancellingMax){
            let _ = service?.setNoiseControlLevel(NoiseControlState.cancellingNormal)
        }
        else {
            let _ =  service?.setNoiseControlLevel(NoiseControlState.cancellingMax)
        }
    }
    
    @objc
    func toggleEqualizer(sender: AnyObject) {
        let _ = service?.toggleAsyncEqualizerStatus(!self.deviceState.equalizerEnabled)
    }
    
    @objc
    func quit(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    @objc
    func doMenu() {
        let menu = NSMenu(title: "Contextual menu")

        if self.deviceState.name == "" {
            iconOff?.isTemplate = true
            statusItem.button?.image = iconOff
            
            menu.addItem(withTitle: "Zik not connected", action: nil, keyEquivalent: "")
        }else{
            iconOn?.isTemplate = true
            statusItem.button?.image = iconOn
            
            menu.addItem(withTitle: self.deviceState.name, action: nil, keyEquivalent: "")
        }
        
        let batteryLevelString = self.deviceState.batteryLevel
        
        var title = "Battery level: " + batteryLevelString + "%"
        var menuItem = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        menuItem.indentationLevel = 1
        
        let batterylevel: Int? = Int(batteryLevelString)
        if batterylevel != nil {
            if (batterylevel! == 20 || batterylevel! == 10) && (batterylevel! < lastBatteryLevel!)  {
                // Give a notification
                showNotification(title: "Parrot Zik", body: "Battery is low. " + batteryLevelString + "% still remaining. Please recharge")
            }
            lastBatteryLevel = batterylevel
        }
        
        title = "Power Source: " + ((self.deviceState.batteryStatus == "charging" || self.deviceState.batteryLevel == "100") ? "Power Adapter" : "Battery")
        menuItem = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        menuItem.indentationLevel = 1
        
        menuItem = menu.addItem(withTitle: "Noise cancellation", action: #selector(self.toggleNoiseCancellation), keyEquivalent: "")
        menuItem.indentationLevel = 1
        menuItem.state = self.deviceState.noiseCancellationEnabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        
        menuItem = menu.addItem(withTitle: "Max Noise Cancelling", action: #selector(self.toggleMaxNoiseCancellation), keyEquivalent: "")
        menuItem.indentationLevel = 1
        if (self.deviceState.noiseControlLevelState == NoiseControlState.cancellingMax){
            menuItem.state = NSControl.StateValue.on
        }
        else{
            menuItem.state = NSControl.StateValue.off
        }
        menuItem = menu.addItem(withTitle: "Equalizer", action: #selector(self.toggleEqualizer), keyEquivalent: "")
        menuItem.indentationLevel = 1
        menuItem.state = self.deviceState.equalizerEnabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        menuItem = menu.addItem(withTitle: "Quit", action: #selector(self.quit), keyEquivalent: "")
        menuItem.indentationLevel = 1
        statusItem.menu = menu
        
    
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.service = BTCommunicationService(api: ParrotZik2Api(),
                                              zikResponseHandler: ZikResponseHandler(deviceState: deviceState))
        let _ = BTConnectionService(service: self.service!)
        
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(self.doMenu),
                             userInfo: nil,
                             repeats: true)
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func showNotification(title: String, body: String) -> Void {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName

        NSUserNotificationCenter.default.delegate = self as? NSUserNotificationCenterDelegate
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    

    
}
