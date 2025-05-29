//
//  APIConfig.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation

enum APIConfig {
    static var kobisAPIKey: String {
        #if DEBUG
        if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
            return ProcessInfo.processInfo.environment["KOBIS_API_KEY"] ?? ""
        } else {
            return Bundle.main.infoDictionary?["KOBIS_API_KEY"] as? String ?? ""
        }
        #else
        if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
            return ProcessInfo.processInfo.environment["KOBIS_API_KEY"] ?? ""
        } else {
            return Bundle.main.infoDictionary?["KOBIS_API_KEY"] as? String ?? ""
        }
        #endif
    }
    
    static var kmdbAPIKey: String {
        #if DEBUG
        if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
            return ProcessInfo.processInfo.environment["KMDB_API_KEY"] ?? ""
        } else {
            return Bundle.main.infoDictionary?["KMDB_API_KEY"] as? String ?? ""
        }
        #else
        if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
            return ProcessInfo.processInfo.environment["KMDB_API_KEY"] ?? ""
        } else {
            return Bundle.main.infoDictionary?["KMDB_API_KEY"] as? String ?? ""
        }
        #endif
    }
    
    static var tmdbAPIKey: String {
        #if DEBUG
        if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
            return ProcessInfo.processInfo.environment["TMDB_API_KEY"] ?? ""
        } else {
            return Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String ?? ""
        }
        #else
        if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
            return ProcessInfo.processInfo.environment["TMDB_API_KEY"] ?? ""
        } else {
            return Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String ?? ""
        }
        #endif
    }
}
