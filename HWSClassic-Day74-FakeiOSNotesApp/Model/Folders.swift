//
//  Folders.swift
//  Project21M
//
//  Created by Romain Buewaert on 05/11/2021.
//

import Foundation

struct Folders: Codable {
    var folders: [Folder]
}

struct Folder: Codable {
    var name: String
    var notes: [Note]
}

struct Note: Codable {
    var title: String
    var body: String
    var date: Date
}
