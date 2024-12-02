import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    let calendar = FSCalendar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "식단 기록"

        setupCalendar()
        customizeCalendarAppearance()
    }

    func setupCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.scrollDirection = .vertical // 세로 스크롤
        calendar.scope = .month // 월별 보기

        // 한국어 설정
        calendar.locale = Locale(identifier: "ko_KR") // 한국어 지역화 설정
        calendar.appearance.headerDateFormat = "yyyy년 MM월" // 헤더 형식 변경

        view.addSubview(calendar)

        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func customizeCalendarAppearance() {
        calendar.backgroundColor = UIColor.systemGroupedBackground

        // 헤더 스타일
        calendar.appearance.headerTitleColor = UIColor.systemGreen
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 18)

        // 요일 스타일
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 16)
        calendar.appearance.weekdayTextColor = UIColor.darkGray

        // 날짜 스타일
        calendar.appearance.todayColor = UIColor.systemGreen
        calendar.appearance.selectionColor = UIColor.systemBlue
        calendar.appearance.titleTodayColor = UIColor.white
        calendar.appearance.titleDefaultColor = UIColor.label
        calendar.appearance.titleSelectionColor = UIColor.white

        // 둥근 셀
        calendar.appearance.borderRadius = 0.3
    }

    // MARK: - FSCalendar Delegate Methods

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dailyRecordVC = DailyRecordViewController()
        dailyRecordVC.selectedDate = date // 선택된 날짜 전달
        navigationController?.pushViewController(dailyRecordVC, animated: true)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let eventDates: [String] = ["2024-10-08", "2024-10-15", "2024-10-22"]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return eventDates.contains(dateString) ? 1 : 0
    }
}

