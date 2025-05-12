//
//  Constants.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//
import SwiftUI

struct Constants {
    static let engTitle = "PocketMovie"
    
    static func getDevieceModelName() -> String {
        return UIDevice.current.model
    }
    
    static func getDeviceOS() -> String {
        return UIDevice.current.systemVersion
    }
    
    static func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
}
