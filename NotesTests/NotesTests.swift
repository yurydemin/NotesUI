//
//  NotesTests.swift
//  NotesTests
//
//  Created by dyy-mac on 26/06/2019.
//  Copyright © 2019 test. All rights reserved.
//

import XCTest
@testable import Notes

class NotesTests: XCTestCase {
    // Note json parse test
    func testNoteJsonParse() {
        let testInputs: [[String: Any]] = [[:], ["uid": "123"], ["uid": "123", "content": "mycontent"]]
        for input: [String: Any] in testInputs {
            let n: Note? = Note.parse(json: input)
            XCTAssertNil(n)
        }
        let n: Note? = Note.parse(json: ["uid": "123", "content": "mycontent", "title": "mytitle"])
        XCTAssertNotNil(n)
    }
    
    // FileNotebook duplicates test
    func testFileNotebookDuplicatesAdd() {
        let fn: FileNotebook = FileNotebook()
        let n = Note(uid: "123", title: "title", content: "content", importance: .common)
        XCTAssertNoThrow(try fn.add(n))
        XCTAssertThrowsError(try fn.add(n))
    }
    
    // FileNotebook add + remove test
    func testFileNotebookAddRemove() {
        let fn: FileNotebook = FileNotebook()
        let n = Note(uid: "123", title: "title", content: "content", importance: .common)
        XCTAssertNoThrow(try fn.add(n))
        XCTAssertNoThrow(try fn.remove(with: n.uid))
        XCTAssertThrowsError(try fn.remove(with: n.uid))
    }
    
    // FileNotebook save load file test
    func testFileNotebookSaveLoadFile() {
        let fn: FileNotebook = FileNotebook()
        let n = Note(uid: "123", title: "title", content: "content", importance: .common)
        XCTAssertNoThrow(try fn.add(n))
        //XCTAssertThrowsError(try fn.loadFromFile())
        XCTAssertNoThrow(try fn.saveToFile())
        XCTAssertNoThrow(try fn.loadFromFile())
    }
}
