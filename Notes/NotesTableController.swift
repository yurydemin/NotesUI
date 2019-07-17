//
//  NotesTableController.swift
//  Notes
//
//  Created by dyy-mac on 13/07/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class NotesTableController: UIViewController {
    @IBOutlet weak var notesTableView: UITableView!
    let reuseIdentifier = "NoteCell"
    
    let notebook: FileNotebook = FileNotebook()
    let categories = FileNotebook.allCategories
    var noteToEdit: Note? = nil
    
    @IBAction func editBtnTapped(_ sender: UIBarButtonItem) {
        notesTableView.isEditing = !notesTableView.isEditing
    }
    
    @IBAction func addNoteBtnTapped(_ sender: UIBarButtonItem) {
        // create new empty note
        noteToEdit = Note(title: "New note title", content: "New note content", importance: .common)
        // start editor
        performSegue(withIdentifier: "ShowAddNoteStoryboard", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ViewController {
            // select note to add / change and handle result
            controller.noteToEdit = self.noteToEdit
            // check identifier to choose title and closure
            if segue.identifier == "ShowAddNoteStoryboard" {
                controller.title = "Add new note"
                controller.noteEdittingCompleteHandler = { [weak self] (_ note:Note?) -> Void in
                    self?.addNewNoteToTableView(note)
                }
            } else if segue.identifier == "ShowEditNoteStoryboard" {
                controller.title = "Edit note"
                controller.noteEdittingCompleteHandler = { [weak self] (_ note:Note?) -> Void in
                    self?.updateNoteInTableView(note)
                }
            }
        }
    }
    
    func addNewNoteToTableView(_ note: Note?) -> Void {
        guard let noteToAdd = note else {
            print("Nil note returned")
            return
        }
        self.notebook.add(noteToAdd)
        if let targetSectionIndex = self.categories.firstIndex(where: {$0 == noteToAdd.importance.rawValue}),
            let targetRowIndex = self.notebook.getNotesByCategory(noteToAdd.importance).firstIndex(where: {$0.uid == noteToAdd.uid}) {
            let indexPaths = [IndexPath(row: targetRowIndex, section: targetSectionIndex)]
            self.notesTableView.insertRows(at: indexPaths, with: .fade)
        } else {
            self.notesTableView.reloadData()
        }
    }
    
    func updateNoteInTableView(_ note: Note?) -> Void {
        guard let noteToAdd = note else {
            print("Nil note returned")
            return
        }
        self.notebook.add(noteToAdd)
        if let targetSectionIndex = self.categories.firstIndex(where: {$0 == noteToAdd.importance.rawValue}),
            let targetRowIndex = self.notebook.getNotesByCategory(noteToAdd.importance).firstIndex(where: {$0.uid == noteToAdd.uid}) {
            let indexPaths = [IndexPath(row: targetRowIndex, section: targetSectionIndex)]
            self.notesTableView.reloadRows(at: indexPaths, with: .fade)
        } else {
            self.notesTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.notesTableView.isEditing = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        notesTableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        notebook.add(Note(uid: "111", title: "First important note", content: "This note is very important", color: .red, importance: .important, selfDestructionDate: nil))
        notebook.add(Note(uid: "211", title: "Common note 1", content: "This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important This note is important", color: .green, importance: .common, selfDestructionDate: nil))
        notebook.add(Note(uid: "311", title: "Unimportant note 1", content: "This note is not so important", color: .white, importance: .unimportant, selfDestructionDate: nil))
        notebook.add(Note(uid: "312", title: "Unimportant note 2", content: "This note is not so important", color: .blue, importance: .unimportant, selfDestructionDate: nil))
    }
}


extension NotesTableController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let targetCategory = Importance(rawValue: categories[section]) else {
            return 0
        }
        return notebook.getNotesByCategory(targetCategory).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NoteTableViewCell
        guard let targetCategory = Importance(rawValue: categories[indexPath.section]) else {
            return cell
        }
        let note = notebook.getNotesByCategory(targetCategory)[indexPath.row]
        cell.noteCellUID = note.uid
        cell.titleLabel.text = note.title
        cell.subtitleLabel.text = note.content
        cell.colorView.layer.borderWidth = 1
        cell.colorView.layer.borderColor = UIColor.black.cgColor
        cell.colorView.backgroundColor = note.color
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let targetCategory = Importance(rawValue: categories[indexPath.section]) else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        // get note to edit
        noteToEdit = notebook.getNotesByCategory(targetCategory)[indexPath.row]
        // start editor
        performSegue(withIdentifier: "ShowEditNoteStoryboard", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            do {
                try self.notebook.remove(with: (tableView.cellForRow(at: indexPath) as! NoteTableViewCell).noteCellUID)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Target cell doesn't exist")
            }
        }
        return [delete]
    }
}
