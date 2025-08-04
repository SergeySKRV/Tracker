import Foundation
import UIKit

// MARK: - TrackerFormViewModelProtocol
protocol TrackerFormViewModelProtocol {
    var trackerTitle: String { get set }
    var selectedEmoji: String? { get set }
    var selectedColor: UIColor? { get set }
    var selectedCategoryId: UUID? { get set }
    var selectedCategoryTitle: String? { get set }
    var selectedDays: Set<Weekday> { get set }
    var options: [String] { get }
    
    func updateSaveButtonState() -> Bool
}

// MARK: - TrackerFormViewModel
class TrackerFormViewModel: TrackerFormViewModelProtocol {
    // MARK: - Properties
    var trackerTitle: String = ""
    var selectedEmoji: String?
    var selectedColor: UIColor?
    var selectedCategoryId: UUID?
    var selectedCategoryTitle: String?
    var selectedDays: Set<Weekday> = []
    
    var options: [String] { [] }
    
    // MARK: - Public Methods
    func updateSaveButtonState() -> Bool {
        return !trackerTitle.isEmpty &&
               selectedEmoji != nil &&
               selectedColor != nil &&
               selectedCategoryId != nil
    }
}
