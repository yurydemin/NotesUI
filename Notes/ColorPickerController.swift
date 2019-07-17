//
//  ColorPickerController.swift
//  Notes
//
//  Created by dyy-mac on 14/07/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class ColorPickerController: UIViewController {

    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var selectedColorHexLabel: UILabel!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBAction func brightnessSliderChanged(_ sender: UISlider) {
        selectedColorBrightness = sender.value
    }
    @IBOutlet weak var colorPaletteView: ColorPaletteView!
    @IBOutlet weak var cursorImage: UIImageView!
    
    // output color value
    var selectedColor: UIColor = .white
    // color brightness from slider
    var selectedColorBrightness: Float {
        get {
            return brightnessSlider.value
        }
        set {
            brightnessSlider.value = newValue
            updateUI()
        }
    }
    // color from palette
    private var pickedFromPaletteColor: UIColor = .white {
        didSet {
            updateUI()
        }
    }
    // done btn tapped
    var doneBtnHandler: ((_ color: UIColor) -> Void)?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneBtnHandler?(selectedColor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.colorPaletteView.colorPaletteTappedHandler = { [weak self] (_ point: CGPoint, _ color: UIColor) in
            self?.colorPaletteViewTapped(point, color)
        }
        // set cursor to default
        pickedFromPaletteColor = selectedColor
        selectedColorBrightness = Float(pickedFromPaletteColor.hue.brightness)
        cursorImage.center = colorPaletteView.getPointForColor(color: pickedFromPaletteColor)
        // update view with default values at first time
        updateUI()
    }
    
    // update ui after picking new color or change brightness
    private func updateUI() {
        // accept current brightness value to new color
        selectedColor = UIColor(hue: pickedFromPaletteColor.hue.hue, saturation: pickedFromPaletteColor.hue.saturation, brightness: CGFloat(selectedColorBrightness), alpha: pickedFromPaletteColor.hue.alpha)
        selectedColorView.backgroundColor = selectedColor
        selectedColorHexLabel.text = selectedColor.rgbaHexString
    }
    
    private func colorPaletteViewTapped(_ point: CGPoint, _ color: UIColor) {
        //print("GOT TAP AT POINT: \(point.x),\(point.y) with color: \(color.rgbaHexString)")
        cursorImage.center = point
        pickedFromPaletteColor = color
        selectedColorBrightness = Float(pickedFromPaletteColor.hue.brightness)
    }
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
