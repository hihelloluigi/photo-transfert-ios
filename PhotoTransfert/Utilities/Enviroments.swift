//
//  Enviroments.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//

import Foundation

import Foundation

public enum Environments {
    
    // MARK: - Keys
    
    enum Keys {
        enum Plist {
            static let clietID = "CLIENT_ID"
        }
        
        enum Project {
            static let appBuild = "CFBundleVersion"
            static let appVersion = "CFBundleShortVersionString"
        }
    }
    
    // MARK: - Plist
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found.")
        }
        return dict
    }()
    
    // MARK: - Plist values
    
    static let version = infoDictionary[Keys.Project.appVersion] as? String ?? "Version: N/D"
    static let build = infoDictionary[Keys.Project.appBuild] as? String ?? "Build: N/D"

    static let clientID: String = {
        guard let clientIdString = infoDictionary[Keys.Plist.clietID] as? String else {
            fatalError("Client ID Key not set in plist for environment.")
        }
                
        return clientIdString
    }()
}
