//
//  MultiManApp.swift
//  MultiMan
//
//  Created by Gareth Carless on 14/04/2023.
//

import SwiftUI

@main
struct MultiManApp: App {
    var deviceOrientation = UIInterfaceOrientationMask.landscape
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return deviceOrientation
    }
}
