//
//  AppDelegate.swift
//  Notes
//
//  Created by dyy-mac on 26/06/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import CocoaLumberjack

// test leaks
/*class myclassA {
    var b: myclassB?
}
class myclassB {
    var a: myclassA?
}*/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    public let fLogger: DDFileLogger = DDFileLogger()
    
    private func setupLogger() {
        DDLog.add(DDTTYLogger.sharedInstance)
        
        fLogger.rollingFrequency = TimeInterval(60*60*24)
        fLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fLogger, with: .info)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // init logger
        setupLogger()
        
        // test logger with FileNotebook
        /*let fn: FileNotebook = FileNotebook()
        let n = Note(uid: "123", title: "title", content: "content", importance: .common)
        try? fn.add(n)
        try? fn.saveToFile()
        try? fn.loadFromFile()*/
        
        // test thread checker
        //let myarray = [1, 2]
        //print(myarray[2])
        
        // test leaks
        /*var a: myclassA? = myclassA()
        var b: myclassB? = myclassB()
        
        a?.b = b
        b?.a = a
        
        a = nil
        b = nil
        
        for num in 1..<10 {
            let num_sin = sin(Double(1 / num))
            NSLog("%f", num_sin)
        }*/
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

