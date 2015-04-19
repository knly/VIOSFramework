//
//  VILocalNotificationManager.swift
//  VILocalNotificationKit
//
//  Created by Nils Fischer on 06.10.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation
import UIKit
import VILogKit


private let kVILocalNotificationRepeatIntervalMultiplierKey = "kVILocalNotificationRepeatIntervalMultiplierKey"
private let kVILocalNotificationRepeatIntervalKey = "kVILocalNotificationRepeatIntervalKey"
private let kVILocalNotificationCountKey = "kVILocalNotificationCountKey"
private let kVILocalNotificationIdentifierKey = "kVILocalNotificationIdentifierKey"

private let kVILocalNotificationQueueKey = "kVILocalNotificationQueueKey"

private let maxScheduledNotifications = 64


public class VILocalNotificationManager {
    
    
    /// Currently queued local notification that are automatically being rescheduled.
    public private(set) lazy var queuedNotifications: [UILocalNotification] = {
        self.logger.log("Loading queued notification from user defaults \(self.userDefaults) for the first time.", forLevel: .Debug)
        if let queueData = self.userDefaults.dataForKey(kVILocalNotificationQueueKey) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(queueData) as? [UILocalNotification] ?? [UILocalNotification]()
        } else {
            return [UILocalNotification]()
        }
    }()

    private func saveQueuedNotifications()
    {
        logger.log("Saving queued notifications to user defaults.", forLevel: .Debug)
        let queueData: NSData = NSKeyedArchiver.archivedDataWithRootObject(queuedNotifications)
        self.userDefaults.setObject(queueData, forKey: kVILocalNotificationQueueKey) // triggers scheduled notifications update
        self.userDefaults.synchronize()
    }

    
    /// The user defaults to use. Set before any queueing or scheduling to make sure the data is consistent
    public var userDefaults: NSUserDefaults = {
        return NSUserDefaults.standardUserDefaults()
    }() {
        didSet {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: oldValue)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDefaultsDidChange:", name: NSUserDefaultsDidChangeNotification, object: userDefaults)
        }
    }


    // MARK: Reacting to changes in User Defaults
    
    @objc public func userDefaultsDidChange(notification: NSNotification)
    {
        if let queueData = self.userDefaults.dataForKey(kVILocalNotificationQueueKey) {
            if let queuedNotifications = NSKeyedUnarchiver.unarchiveObjectWithData(queueData) as? [UILocalNotification] {
                logger.log("Updating queued local notifications due to user defaults change.", forLevel: .Debug)
                self.queuedNotifications = queuedNotifications
                updateScheduledNotifications()
            }
        }
    }
    
    
    // MARK: Public Interface
    
    public func scheduleLocalNotification(notification: UILocalNotification, repeatInterval: NSCalendarUnit, repeatIntervalMultiplier: Int, count: Int)
    {
        var userInfo = notification.userInfo ?? [NSObject : AnyObject]()
        userInfo[kVILocalNotificationRepeatIntervalKey] = NSNumber(unsignedLong: repeatInterval.toRaw())
        userInfo[kVILocalNotificationRepeatIntervalMultiplierKey] = NSNumber(integer: repeatIntervalMultiplier)
        userInfo[kVILocalNotificationCountKey] = NSNumber(integer: count)
        userInfo[kVILocalNotificationIdentifierKey] = String(NSDate().hash)
        notification.repeatInterval = .allZeros
        notification.userInfo = userInfo
        
        queuedNotifications.append(notification)
        logger.log("Queued local notification to fire every \(repeatIntervalMultiplier) units of \(repeatInterval), starting \(notification.fireDate).", forLevel: .Debug)
        logger.log(notification.debugDescription, forLevel: .Verbose)

        saveQueuedNotifications()
    }
    
    public func cancelLocalNotification(notification: UILocalNotification)
    {
        if let index = find(queuedNotifications, notification) {
            let identifier = notification.userInfo![kVILocalNotificationIdentifierKey] as NSString
            for scheduledNotification in self.scheduledNotificationsForIdentifier(identifier) {
                UIApplication.sharedApplication().cancelLocalNotification(scheduledNotification)
                logger.log("Canceled local notification scheduled for \(scheduledNotification.fireDate).", forLevel: .Debug)
            }
            queuedNotifications.removeAtIndex(index)
            logger.log("Removed queued local notification.", forLevel: .Debug)
            logger.log(notification.debugDescription, forLevel: .Verbose)
            saveQueuedNotifications()
        } else {
            logger.log("Can't cancel local notification because it does not exist in queue.", forLevel: .Warning)
            logger.log(notification.debugDescription, forLevel: .Verbose)
        }
    }
    
    
    // MARK: Updating scheduled notifications
    
    public func updateScheduledNotifications()
    {
        logger.log("Updating scheduled local notifications...", forLevel: .Debug)
        var didUpdate = false
        for notification in queuedNotifications {
            logger.log("Checking queued notification \(notification)", forLevel: .Verbose)
            
            let repeatInterval = NSCalendarUnit.fromRaw((notification.userInfo![kVILocalNotificationRepeatIntervalKey] as NSNumber).unsignedLongValue)!
            let repeatIntervalMultiplier = (notification.userInfo![kVILocalNotificationRepeatIntervalMultiplierKey] as NSNumber).integerValue
            let count = (notification.userInfo![kVILocalNotificationCountKey] as NSNumber).integerValue
            let identifier = notification.userInfo![kVILocalNotificationIdentifierKey] as NSString
            
            while self.scheduledNotifications.count < maxScheduledNotifications && self.scheduledNotificationsForIdentifier(identifier).count < count {
                let newNotification = notification.copy() as UILocalNotification
                if let lastFireDate = self.scheduledNotificationsForIdentifier(identifier).last?.fireDate {
                    newNotification.fireDate = NSCalendar.currentCalendar().dateByAddingUnit(repeatInterval, value: repeatIntervalMultiplier, toDate: lastFireDate, options: NSCalendarOptions.allZeros)
                }
                UIApplication.sharedApplication().scheduleLocalNotification(newNotification)
                logger.log("Scheduled local notification for \(newNotification.fireDate).", forLevel: .Debug)
                logger.log(newNotification.debugDescription, forLevel: .Verbose)
                didUpdate = true
            }
            
        }
        if !didUpdate {
            logger.log("No local notification updates necessary.", forLevel: .Debug)
        }
        logger.log("All scheduled local notifications: \(self.scheduledNotifications)", forLevel: .Verbose)
    }
    
    
    // MARK: Accessing scheduled notifications
    
    private var scheduledNotifications: [UILocalNotification] {
        return UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]
    }
    
    private func scheduledNotificationsForIdentifier(identifier: String) -> [UILocalNotification]
    {
        return self.scheduledNotifications.filter { (element) -> Bool in
            if element.userInfo == nil || element.userInfo![kVILocalNotificationIdentifierKey] == nil {
                return false
            }
            return element.userInfo![kVILocalNotificationIdentifierKey]! as String == identifier
            } .sorted { (lhs, rhs) -> Bool in
                return lhs.fireDate!.compare(rhs.fireDate!) == NSComparisonResult.OrderedAscending
        }
    }
    
}


// MARK: - Singleton

private let _defaultManager = VILocalNotificationManager()

extension VILocalNotificationManager {

    public class func defaultManager() -> VILocalNotificationManager {
        return _defaultManager
    }

}


// MARK: - Logging

extension VILocalNotificationManager {
    
    public var logger: Logger {
        return Logger.loggerForKeyPath("VILocalNotificationKit.VILocalNotificationManager")
    }
    
}