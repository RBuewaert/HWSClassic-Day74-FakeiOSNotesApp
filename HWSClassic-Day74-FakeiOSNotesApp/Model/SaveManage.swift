//
//  SaveManage.swift
//  Project21M
//
//  Created by Romain Buewaert on 05/11/2021.
//

import Foundation

final class SaveManage {
    // MARK: - Properties
    static var folders = [Folder]()
    static var searchedFolder = [Folder]()

    // MARK: - Methods
    func load() {
        let defaults = UserDefaults.standard
        if let savedFolders = defaults.object(forKey: "folders") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                SaveManage.folders = try jsonDecoder.decode([Folder].self, from: savedFolders)
                SaveManage.searchedFolder = SaveManage.folders
                print("folders:", SaveManage.folders)
            } catch {
                print("Failed to load people.")
            }
        } else {
            let firstFolder = Folder(name: "Notes", notes: [Note]())
            SaveManage.folders.append(firstFolder)
            SaveManage.searchedFolder.append(firstFolder)
        }
    }

    func saveFolders(completionHandler: ((Bool) -> ())?) {
        let jsonEncoder = JSONEncoder()

        if let savedData = try? jsonEncoder.encode(SaveManage.folders) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "folders")
            guard let completionHandler = completionHandler else {
                return
            }
            completionHandler(true)
            print("OK")
        } else {
            guard let completionHandler = completionHandler else {
                return
            }
            completionHandler(false)
            print("Failed to saved folders.")
        }
    }

    func saveNewNote(indexCurrentFolder currentIndex: Int, note: Note) {
        SaveManage.folders[currentIndex].notes.append(note)

        saveFolders(completionHandler: nil)
    }

    func searchCurrentFolder(nameSearched: String) -> Int? {
        for (index, folder) in SaveManage.folders.enumerated() {
            if folder.name == nameSearched {
                return index
            }
        }
        return nil
    }

    func searchCurrentNote(indexCurrentFolder currentIndex: Int, titleSearched: String, bodySearched: String) -> Int? {
        for (index, note) in SaveManage.folders[currentIndex].notes.enumerated() {
            if note.title == titleSearched && note.body == bodySearched {
                return index
            }
        }
        return nil
    }
}
