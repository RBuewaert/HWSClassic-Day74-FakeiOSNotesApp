//
//  FolderViewController.swift
//  Project21M
//
//  Created by Romain Buewaert on 05/11/2021.
//

import UIKit

final class FolderViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let folderButton = UIBarButtonItem(image: UIImage(systemName: "folder.fill.badge.plus"), style: .plain, target: self, action: #selector(addFolder))
        folderButton.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = folderButton

        guard let image = UIImage(systemName: "magnifyingglass") else { return }
        searchTextField.setupImage(image: image, imageSide: .left)

        SaveManage().load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SaveManage.searchedFolder = SaveManage.folders
        tableView.reloadData()
    }

    // MARK: - Method for navigation item button
    @objc func addFolder() {
        let ac = UIAlertController(title: "New Folder", message: "Enter folder name.", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self, weak ac] _ in
            guard let name = ac?.textFields?[0].text else { return }

            for folder in SaveManage.folders {
                if folder.name == name {
                    let acError = UIAlertController(title: "Name already use", message: "Please enter another name", preferredStyle: .alert)
                    acError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(acError, animated: true, completion: nil)
                    return
                }
            }

            let folder = Folder(name: name, notes: [Note]())
            SaveManage.folders.append(folder)
            SaveManage.searchedFolder = SaveManage.folders
            SaveManage().saveFolders { [weak self] succes in
                if succes {
                    self?.tableView.reloadData()
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}

// MARK: - TableView
extension FolderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SaveManage.searchedFolder.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell") as? FolderTableViewCell else { return UITableViewCell() }
        let currentFolder = SaveManage.searchedFolder[indexPath.row]
        cell.configure(folder: currentFolder)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Note") as? NoteViewController {
            let currentFolder = SaveManage.searchedFolder[indexPath.row]
            guard let index = SaveManage().searchCurrentFolder(nameSearched: currentFolder.name) else { return }
            vc.folderIndex = index

            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension FolderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentFolder = SaveManage.searchedFolder[indexPath.row]
            guard let searchedindex = SaveManage().searchCurrentFolder(nameSearched: currentFolder.name) else { return }

            SaveManage.folders.remove(at: searchedindex)
            SaveManage.searchedFolder.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .automatic)
            SaveManage().saveFolders { [weak self] succes in
                if succes {
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - TextField
extension FolderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textView: UITextField) -> Bool {
        textView.resignFirstResponder()
        filterFolder(textSearched: textView.text)
        textView.text = ""
        return true
    }

    func filterFolder(textSearched: String?) {
        var filterResult = [Folder]()
        guard let text = textSearched?.lowercased() else {
            return
        }

        if text == "" {
            SaveManage.searchedFolder = SaveManage.folders
            tableView.reloadData()
            return
        }

        for folder in SaveManage.folders {
            if folder.name.lowercased().contains(text) {
                filterResult.append(folder)
            }
        }

        if filterResult.isEmpty {
            let ac = UIAlertController(title: "No result", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            SaveManage.searchedFolder = filterResult
            tableView.reloadData()
        }
    }
}
