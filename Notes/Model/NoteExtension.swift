import Foundation
import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var hexValue = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexValue = hexValue.replacingOccurrences(of: "#", with: "")
        
        var rgba: Int = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexValue.count
        
        guard Scanner(string: hexValue).scanInt(&rgba) else { return nil }
        
        if length == 8 {
            r = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgba & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgba & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            guard !r.isNaN, !g.isNaN, !b.isNaN, !a.isNaN else { return (0, 0, 0, 0) }
            return (r, g, b, a)
        }
        return (0, 0, 0, 0)
    }
    
    var hue: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a){
            guard !h.isNaN, !s.isNaN, !b.isNaN, !a.isNaN else { return (0, 0, 0, 0) }
            return (h, s, b, a)
        }
        return (0, 0, 0, 0)
    }
    
    var rgbaHexString: String {
        return String(format: "#%02x%02x%02x%02x", Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255), Int(rgba.alpha * 255))
    }
}

extension Note {
    static func parse(json: [String: Any]) -> Note? {
        // check must have params
        guard let uid = json["uid"] as? String,
            let title = json["title"] as? String,
            let content = json["content"] as? String
            else{
                return nil
        }
        // other params
        var color: UIColor = .white
        var importance: Importance = .common
        var selfDestructionDate: Date? = nil
        // check colors
        if let colorStr = json["color"] as? String,
            let unwrappedColor = UIColor(hex: colorStr) {
            color = unwrappedColor
        }
        // check importance
        if let importanceStr = json["importance"] as? String,
            let unwrappedImportance = Importance(rawValue: importanceStr){
            importance = unwrappedImportance
        }
        // check date
        if let timeIntervalStr = json["selfDestructionDate"] as? String,
            let timeInterval = Double(timeIntervalStr){
            selfDestructionDate = Date(timeIntervalSince1970: timeInterval)
        }
        
        return Note(uid: uid, title: title, content: content, color: color, importance: importance, selfDestructionDate: selfDestructionDate)
    }
    
    var json: [String: Any] {
        // fill must have params
        var result: [String: Any] = [
        "uid": self.uid,
        "title": self.title,
        "content": self.content
        ]
        // fill color if needed
        if color != .white {
            result["color"] = self.color.rgbaHexString
        }
        // fill importance if needed
        if importance != .common {
            result["importance"] = self.importance.rawValue
        }
        // fill date if exist
        if let date = self.selfDestructionDate {
            result["selfDestructionDate"] = "\(date.timeIntervalSince1970)"
        }
        return result
    }
}
