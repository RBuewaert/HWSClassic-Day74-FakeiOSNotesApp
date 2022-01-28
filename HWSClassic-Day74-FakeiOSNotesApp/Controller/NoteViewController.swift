//
//  NotesViewController.swift
//  Project21M
//
//  Created by Romain Buewaert on 05/11/2021.
//

import UIKit

final class NoteViewController: UIViewController {
    // MARK: - Properties
    var folderIndex = 0
    var searchedNotes = [Note]()

    // MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let newNoteButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(addNote))
        newNoteButton.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = newNoteButton

        guard let image = UIImage(systemName: "magnifyingglass") else { return }
        searchTextField.setupImage(image: image, imageSide: .left)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchedNotes = SaveManage.folders[folderIndex].notes
        tableView.reloadData()
    }

    // MARK: - Method for navigation item button
    @objc func addNote() {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.folderIndex = folderIndex
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - TableView
extension NoteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedNotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") as? NoteTableViewCell else { return UITableViewCell() }
        let currentNote = searchedNotes[indexPath.row]

        cell.configure(note: currentNote)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            let currentNote = searchedNotes[indexPath.row]
            vc.currentNote = currentNote
            vc.folderIndex = folderIndex
            guard let index = SaveManage().searchCurrentNote(indexCurrentFolder: folderIndex, titleSearched: currentNote.title, bodySearched: currentNote.body) else { return }
            vc.nodeIndex = index

            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension NoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentNote = searchedNotes[indexPath.row]
            guard let currentIndex = SaveManage().searchCurrentNote(indexCurrentFolder: folderIndex, titleSearched: currentNote.title, bodySearched: currentNote.body) else { return }

            SaveManage.folders[folderIndex].notes.remove(at: currentIndex)
            searchedNotes.remove(at: indexPath.row)
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
extension NoteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textView: UITextField) -> Bool {
        textView.resignFirstResponder()
        filterNote(textSearched: textView.text)
        textView.text = ""
        return true
    }

    func filterNote(textSearched: String?) {
        var filterResult = [Note]()
        guard let text = textSearched?.lowercased() else {
            return
        }

        if text == "" {
            searchedNotes = SaveManage.folders[folderIndex].notes
            tableView.reloadData()
            return
        }

        for note in SaveManage.folders[folderIndex].notes {
            if note.title.lowercased().contains(text) || note.body.lowercased().contains(text) {
                filterResult.append(note)
            }
        }

        if filterResult.isEmpty {
            let ac = UIAlertController(title: "No result", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            searchedNotes = filterResult
            tableView.reloadData()
        }
    }
}
