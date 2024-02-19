//
//  AppDelegate.swift
//  ToDo
//
//  Created by Nadeesha Chandrapala on 15/02/2024.
//

import UIKit
import CoreData
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("\(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
        
        do {
            _ = try Realm()
        } catch {
            print("error initialising new Realm: \(error)")
        }
        return true
    }

}

