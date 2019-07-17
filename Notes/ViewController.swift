//
//  ViewController.swift
//  Notes
//
//  Created by dyy-mac on 26/06/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleInputField: UITextField!
    @IBOutlet weak var contentInputField: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerSwitcher: UISwitch!
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var whiteBoxView: ColorBoxView!
    @IBOutlet weak var redBoxView: ColorBoxView!
    @IBOutlet weak var greenBoxView: ColorBoxView!
    @IBOutlet weak var paletteBoxView: ColorBoxView!
    
    @IBAction func dateSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.datePicker.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.datePickerHeight.constant = 216
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.datePickerHeight.constant = 0
            })
            self.datePicker.isHidden = true
        }
    }
    
    var onEditingFlag: Bool = false
    var noteToEdit: Note? = nil
    var noteEdittingCompleteHandler: ((Note?) -> Void)?
    var noteSelectedColor: UIColor = .white
    
    func initParamsFromNote(_ note: Note?) {
        guard let note = note else {
            return
        }
        titleInputField.text = note.title
        contentInputField.text = note.content
        noteSelectedColor = note.color
        var selectedBoxTag: Int = -1
        for colorBox in [whiteBoxView, redBoxView, greenBoxView] {
            if colorBox?.selectedColor == noteSelectedColor,
                let colorBoxTag = colorBox?.tag {
                selectedBoxTag = colorBoxTag
                break
            }
        }
        if selectedBoxTag == -1 {
            paletteBoxView.isPaletteBox = false
            paletteBoxView.selectedColor = noteSelectedColor
            selectedBoxTag = paletteBoxView.tag
        }
        ChangeColorBoxesStates(selectedBoxTag)
        
        if let existingDate = note.selfDestructionDate {
            datePicker.date = existingDate
            datePickerSwitcher.isOn = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard !onEditingFlag,
                let note = noteToEdit else {
            return
        }
        // collect data for note
        let uid = note.uid
        let title = titleInputField.text!
        let content = contentInputField.text!
        let importance = note.importance
        let color = noteSelectedColor
        var date: Date?
        if datePickerSwitcher.isOn {
            date = datePicker.date
        } else {
            date = nil
        }
        // send note to handler
        noteEdittingCompleteHandler?(Note(uid: uid, title: title, content: content, color: color, importance: importance, selfDestructionDate: date))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init from incomming note
        initParamsFromNote(noteToEdit)
        // add empty space tap checker to hide keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HideKeyboard))
        view.addGestureRecognizer(tap)
        
        // auto scroll when keyboard appear / disappear
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardAppearanceEvent), name: UIWindow.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardAppearanceEvent), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        
        // add one tap recognizer to boxes
        for colorBox in [whiteBoxView, redBoxView, greenBoxView, paletteBoxView] {
            let oneTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ColorBoxOneTapHandler))
            oneTapRecognizer.numberOfTapsRequired = 1
            colorBox?.addGestureRecognizer(oneTapRecognizer)
        }
        // add long tap recognizer to 4 box
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PaletteBoxLongTapHandler))
        paletteBoxView.addGestureRecognizer(longPressRecognizer)
    }
    
    // color boxes handlers
    @objc func ColorBoxOneTapHandler(recognizer: UITapGestureRecognizer) {
        guard let tappedBox = recognizer.view as? ColorBoxView else { return }
        // check already selected color box
        guard !tappedBox.isSelectedBox, !tappedBox.isPaletteBox else {
            return
        }
        ChangeColorBoxesStates(tappedBox.tag)
    }
    @objc func PaletteBoxLongTapHandler(recognizer: UILongPressGestureRecognizer) {
        guard (recognizer.view as? ColorBoxView) != nil else { return }
        guard recognizer.state == .began else { return }
        HideKeyboard() // if keyboard opened - close it
        onEditingFlag = true // block completion handler
        performSegue(withIdentifier: "ShowColorPicker", sender: nil)
    }
    
    // handle color picker segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ColorPickerController, segue.identifier == "ShowColorPicker" {
            controller.selectedColor = noteSelectedColor
            controller.doneBtnHandler = { [weak self] (_ color: UIColor) in
                self?.colorSelectionDoneTapped(color)
            }
        }
    }
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        
    }
    
    // color picker handlers
    func colorSelectionDoneTapped(_ selectedColor: UIColor) {
        // update palette color box
        paletteBoxView.isPaletteBox = false
        paletteBoxView.selectedColor = selectedColor
        ChangeColorBoxesStates(paletteBoxView.tag)
        // unblock complition handler
        onEditingFlag = false
    }
    
    // redraw selection symbol and change boxes states
    private func ChangeColorBoxesStates(_ tag: Int) {
        // reset flags
        for colorBox in [whiteBoxView, redBoxView, greenBoxView, paletteBoxView] {
            if let colorBox = colorBox {
                if colorBox.tag == tag {
                    colorBox.isSelectedBox = true
                    noteSelectedColor = colorBox.selectedColor
                } else {
                    colorBox.isSelectedBox = false
                }
            }
        }
    }
    
    // keyboard handlers
    @objc func HideKeyboard() {
        view.endEditing(true)
    }
    @objc func KeyboardAppearanceEvent(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIWindow.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIWindow.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    // redraw graphics after orientation changed
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        for colorBox in [whiteBoxView, redBoxView, greenBoxView, paletteBoxView] {
            colorBox?.setNeedsDisplay()
        }
    }
}

