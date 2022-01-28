//
//  DetailViewController.swift
//  Project21M
//
//  Created by Romain Buewaert on 05/11/2021.
//

import UIKit

final class DetailViewController: UIViewController {
    // MARK: - Properties
    var currentNote: Note?
    var folderIndex = 0
    var nodeIndex = 0

    // MARK: - Outlet
    @IBOutlet weak var textView: UITextView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let shareButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(shareNote))
        shareButton.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = shareButton

        configureTextView()

        if currentNote == nil {
            textView.text = ""
        } else {
            guard let currentNote = currentNote else {
                return
            }
            textView.text = "\(currentNote.title)\n\(currentNote.body)"

            let splitText = textView.text.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)

            let attributedString = NSMutableAttributedString(string: textView.text)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 30), range: NSRange(location: 0, length: splitText[0].count))
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18), range: NSRange(location: splitText[0].count + 1, length: splitText[1].count))

            textView.attributedText = attributedString
        }

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    // MARK: - Method
    func configureTextView() {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(
                title: "Done", style: .done, target: self, action: #selector(dismissMyKeyboard))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        self.textView.inputAccessoryView = toolbar
    }

    @objc func shareNote() {
        guard let note = textView.text else {
            return
        }
        let vc = UIActivityViewController(activityItems: [note], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}

// MARK: - Keyboard
extension DetailViewController {
    @objc private func dismissMyKeyboard() {
        if textView.text != "" && textView.text != nil {
            guard let currentText = textView.text else { return }

            let date = Date.now

            if currentNote == nil {
                if textView.text.contains("\n") {
                    let splitedNote = currentText.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)

                    let note = Note(title: "\(splitedNote[0])", body: "\(splitedNote[1])", date: date)

                    SaveManage().saveNewNote(indexCurrentFolder: folderIndex, note: note)
                } else {
                    let note = Note(title: "\(currentText)", body: "", date: date)
                    SaveManage().saveNewNote(indexCurrentFolder: folderIndex, note: note)
                }
            } else {
                if textView.text.contains("\n") {
                    let splitedNote = currentText.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)

                    let note = Note(title: "\(splitedNote[0])", body: "\(splitedNote[1])", date: date)
                    SaveManage.folders[folderIndex].notes[nodeIndex] = note
                    SaveManage().saveFolders(completionHandler: nil)
                } else {
                    let note = Note(title: "\(currentText)", body: "", date: date)
                    SaveManage.folders[folderIndex].notes[nodeIndex] = note
                    SaveManage().saveFolders(completionHandler: nil)
                }
            }
        }
        view.endEditing(true)
    }
}

// MARK: - TextView
extension DetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.contains("\n") {
            let splitText = textView.text.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)

            if splitText.count > 1 && splitText[1].count > 0 {
                let attributedString = NSMutableAttributedString(string: textView.text)
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 30), range: NSRange(location: 0, length: splitText[0].count))
                attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18), range: NSRange(location: splitText[0].count + 1, length: splitText[1].count))

                textView.attributedText = attributedString
            }
        }
    }
}

// MARK: - Notification and AutoScrolling for textView
extension DetailViewController {
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        textView.scrollIndicatorInsets = textView.contentInset

        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}
