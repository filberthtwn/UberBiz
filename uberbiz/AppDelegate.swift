//
//  AppDelegate.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 04/01/21.
//

import UIKit
import IQKeyboardManagerSwift
import SVProgressHUD
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window:UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// Configure Firebase
        FirebaseApp.configure()
        
        // Register for push notification
        UIApplication.shared.registerForRemoteNotifications()
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        var rootViewContoller:UIViewController = OnBoardingViewController()
        
        if let user = UserDefaultHelper.shared.getUser(){
            if user.id != nil{
                rootViewContoller = UINavigationController(rootViewController: TabBarViewController())
            }
        }else{
            if UserDefaultHelper.shared.getIsOnBoardLoaded(){
                rootViewContoller = LoginViewController()
            }
        }
        
        self.window!.rootViewController = rootViewContoller
        self.window!.makeKeyAndVisible()
        
        // MARK: Setup IQKeyboardManagerSwift
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.disabledToolbarClasses = [ChatViewController.self, ProductDescriptionViewController.self]
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [ChatViewController.self, ProductDescriptionViewController.self]
        
        // MARK: Setup SVProgressHUD
        SVProgressHUD.setDefaultMaskType(.black)

        return true
    }
    
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//       guard let identifierForVendor = UIDevice.current.identifierForVendor else {
//           return
//       }
//
//       let deviceIdentifier = identifierForVendor.uuidString
//       let subscription = QBMSubscription()
//       subscription.notificationChannel = .APNS
//       subscription.deviceUDID = deviceIdentifier
//       subscription.deviceToken = deviceToken
//
//       QBRequest.createSubscription(subscription, successBlock: { (response, objects) in
//            print("Subscribe to quickblox successfully")
//       }, errorBlock: { (response) in
//           debugPrint("[AppDelegate] createSubscription error: \(String(describing: response.error))")
//       })
//   }
    
    private func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register for remote notifications: \(error)")
    }
}

