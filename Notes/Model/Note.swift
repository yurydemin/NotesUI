import Foundation
import UIKit

// Note statuses
enum Importance: String, CaseIterable{
    case important
    case common
    case unimportant
}

// Note protocol
protocol NoteProtocol{
    var uid: String { get }
    var title: String { get }
    var content: String { get }
    var color: UIColor { get }
    var importance: Importance { get }
    var selfDestructionDate: Date? { get }
}

// Note
struct Note: NoteProtocol{
    let uid: String
    let title: String
    let content: String
    let color: UIColor
    let importance: Importance
    let selfDestructionDate: Date?
    
    init(uid: String = UUID().uuidString, title: String, content: String, color: UIColor = UIColor.white, importance: Importance, selfDestructionDate: Date? = nil){
        self.uid = uid
        self.title = title
        self.content = content
        self.color = color
        self.importance = importance
        self.selfDestructionDate = selfDestructionDate
    }
}
