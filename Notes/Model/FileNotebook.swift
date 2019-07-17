import Foundation
import UIKit
import CocoaLumberjack

class FileNotebook {
    public private(set) var notes: [Note] = [Note]()
    
    enum FileNotebookError: Error {
        case noteWithThisUIDAlreadyExist
        case noteWithThisUIDDoesntExist
        case noteParsingError
        case noteDuplicatesFoundError
        case notesCollectionIsEmpty
        case jsonSerializationError
        case jsonDeserializationError
        case dataFormatError
        case fileDoesntExist
        case fileCreationError
        case fileWritingError
        case fileReadingError
    }
    
    public func add(_ note: Note) {
        // check already exist notes to avoid duplicates
        if let noteIndex = notes.firstIndex(where: {$0.uid == note.uid}) {
            notes[noteIndex] = note
            DDLogInfo("Note with uid [" + note.uid + "] replaced")
        } else {
            notes.append(note)
            DDLogInfo("Note with uid [" + note.uid + "] added")
        }
        /*if notes.contains(where: {$0.uid == note.uid}){
            DDLogError("Add note with uid [" + note.uid + "] failed. Already exist")
            throw FileNotebookError.noteWithThisUIDAlreadyExist
        } else {
            notes.append(note)
            DDLogInfo("Note with uid [" + note.uid + "] added")
        }*/
    }
    
    public func remove(with uid: String) throws {
        if let index = notes.firstIndex(where: {$0.uid == uid}){
            notes.remove(at: index)
            DDLogInfo("Note with uid [" + uid + "] removed")
        } else {
            DDLogError("Remove note with uid [" + uid + "] failed. Doesn't exist")
            throw FileNotebookError.noteWithThisUIDDoesntExist
        }
    }
    
    public func saveToFile() throws -> Bool {
        // get filename from configs
        var filename: String? = Bundle.main.infoDictionary?["NOTES_FILENAME"] as? String
        if filename == nil {
            // set to default if doesn't exist
            filename = "default.json"
            DDLogWarn("FileNotebook saving to file. Filename set to default")
        }
        // check notes exist
        guard notes.count > 0 else {
            DDLogError("Trying to save empty collection. Failed")
            throw FileNotebookError.notesCollectionIsEmpty
        }
        // fill collection of notes json to save
        let collectionToSave: [[String: Any]] = notes.map { $0.json }
        // serialize collection
        var dataToSave: Data
        do {
            dataToSave = try JSONSerialization.data(withJSONObject: collectionToSave, options: [])
        } catch {
            DDLogError("Notes collection serialization failed")
            throw FileNotebookError.jsonSerializationError
        }
        // get fm and full path
        let fm = FileManager.default
        let fullPath = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(filename!)
        // create file
        if !fm.fileExists(atPath: fullPath.path),
            !fm.createFile(atPath: fullPath.path, contents: nil, attributes: nil) {
            DDLogError("New file creation failed. File path: " + fullPath.path)
            throw FileNotebookError.fileCreationError
        }
        // write data to file
        do {
            try dataToSave.write(to: fullPath)
        } catch {
            DDLogError("Data writing to file failed. File path: " + fullPath.path)
            throw FileNotebookError.fileWritingError
        }
        DDLogInfo("Notes collection saved to " + fullPath.path)
        return true
    }
    
    public func loadFromFile() throws -> Bool {
        // get filename from configs
        var filename: String? = Bundle.main.infoDictionary?["NOTES_FILENAME"] as? String
        if filename == nil {
            // set to default if doesn't exist
            filename = "default.json"
            DDLogWarn("FileNotebook loading from file. Filename set to default")
        }
        // get fm and full path
        let fm = FileManager.default
        let fullPath = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(filename!)
        // check file
        if !fm.fileExists(atPath: fullPath.path) {
            DDLogError("Target file doesn't exist. File path: " + fullPath.path)
            throw FileNotebookError.fileDoesntExist
        }
        // check current collection empty and clear if not
        if !notes.isEmpty {
            notes.removeAll()
            DDLogWarn("FileNotebook notes collection have been removed before loading from file")
        }
        // load data from file
        var loadedData: Data
        do {
            loadedData = try Data(contentsOf: fullPath)
        } catch {
            DDLogError("Data reading from file failed. File path: " + fullPath.path)
            throw FileNotebookError.fileReadingError
        }
        // deserialize data
        var json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: loadedData, options: [])
        } catch {
            DDLogError("Json deserialization failed")
            throw FileNotebookError.jsonDeserializationError
        }
        // check loaded data
        guard let loadedCollection = json as? [[String: Any]]
            else {
                DDLogError("Loaded data format failed")
                throw FileNotebookError.dataFormatError
        }
        // parse data and fill notes collection
        for noteJson: [String: Any] in loadedCollection {
            if let note: Note = Note.parse(json: noteJson) {
                // try to add new note to notes collection
                /*do {
                    try add(note)
                } catch FileNotebookError.noteWithThisUIDAlreadyExist {
                    throw FileNotebookError.noteDuplicatesFoundError
                }*/
                add(note)
            }
            else {
                DDLogError("Note parsing failed")
                throw FileNotebookError.noteParsingError
            }
        }
        DDLogInfo("Notes collection loaded from " + fullPath.path)
        return true
    }
}

extension FileNotebook {
    static var allCategories: [String] {
        var categories: [String] = []
        for category in Importance.allCases {
            categories.append(category.rawValue)
        }
        return categories
    }
    
    func getNotesByCategory(_ category: Importance) -> [Note] {
        return self.notes.filter { $0.importance == category }
    }
}
