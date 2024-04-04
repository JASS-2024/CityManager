//
//  CityManagerApp.swift
//  CityManager
//
//  Created by Julian Kraus on 26.03.24.
//

import SwiftUI
import UserNotifications
import UIKit
import Foundation

@main
struct CityManagerApp: App {
//    we need a UIAppDelegate  for registering for remote notifications, as well as a UNNotif delegate to handle incoming notifications.
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//we can assume the doc folder always exists, force unwrapping is safe.
let tokenURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "token")

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("[!] didFinishLaunchingWithOptions")
        
        let center = UNUserNotificationCenter.current()
//        we need to let the notification center (UNNC) know we're the delegate, so the UNNC calls our methods defined below for notifications.
        center.delegate = self
        center.getNotificationSettings(completionHandler: { settings in
            if settings.authorizationStatus == .authorized  {
                print("permission granted")
            }
        })
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: {granted ,error in
            if let error{
                print("Error wtf \(error)")
            }
            guard granted else {fatalError()}
            DispatchQueue.main.async{
                UIApplication.shared.registerForRemoteNotifications()
            }
        })
        
        return true
    }
//    Unused for now.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("[DID RECEIVE]")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("SUCCESS REGISTERING for remote nots with token "+(String(data: deviceToken, encoding: .utf8) ?? "non utf8"))
        try! deviceToken.write(to: tokenURL)
        weHaveAToken(token: deviceToken)
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("FAILED REGISTERING for remote nots! \(error)")
    }
    //    This is called when a notification is received while the app is in the foreground (running on-screen. In our case, body of the notification is the message coming from Apollo.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        print("RECEIVED NOTIFICATION")
        let body = notification.request.content.body
        print("BODY: "+body)
//        DataSourceClass.shared.
        StateData.shared.addNewMessageThreadSafe(.init(content: body, isCurrentUser: false), doExtraLogic: true)
        return .badge
    }
}


func weHaveAToken(token: Data){
    print("We have a token!")
    let deviceTokenString = tokenToHex(tkn: token)
    print(deviceTokenString)
    StateData.shared.apnsToken = deviceTokenString
    Task{
        await StateData.shared.sendTokenToServerIfPossible()
    }
}


func tokenToHex(tkn: Data)->String{
    return tkn.map { String(format: "%02x", $0) }.joined()
}
