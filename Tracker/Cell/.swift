import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleTableViewCell"
    
    private lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        return control
    }()
    
    var parentController: AddTrackerViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel()?.text = "Расписание"
        accessoryView = switchControl
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchToggled() {
        // Откроем экран выбора дней недели
        let vc = ScheduleViewController(selectedDays: parentController?.selectedDays ?? [])
        parentController?.navigationController?.pushViewController(vc, animated: true)
    }
}
