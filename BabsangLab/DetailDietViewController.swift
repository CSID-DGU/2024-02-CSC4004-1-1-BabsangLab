import UIKit

class DetailDietViewController: UIViewController {

    var selectedDate: Date?
    let nutritionLabel = UILabel()
    let dietRecordView = UIStackView()
    let analysisLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = formatDateToString(date: selectedDate ?? Date())

        setupNutritionLabel()
        setupDietRecordView()
        setupAnalysisLabel()

        fetchDietData(for: selectedDate ?? Date())
    }

    func setupNutritionLabel() {
        nutritionLabel.text = "영양 정보: 120g 탄수화물, 20g 단백질, 20g 지방" // 예시 데이터
        nutritionLabel.font = UIFont.systemFont(ofSize: 16)
        nutritionLabel.textAlignment = .center
        nutritionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nutritionLabel)

        NSLayoutConstraint.activate([
            nutritionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nutritionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nutritionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    func setupDietRecordView() {
        dietRecordView.axis = .horizontal
        dietRecordView.spacing = 8
        dietRecordView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dietRecordView)

        NSLayoutConstraint.activate([
            dietRecordView.topAnchor.constraint(equalTo: nutritionLabel.bottomAnchor, constant: 16),
            dietRecordView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dietRecordView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dietRecordView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    func setupAnalysisLabel() {
        analysisLabel.text = "식단 분석: 칼로리 섭취 부족" // 예시 데이터
        analysisLabel.font = UIFont.systemFont(ofSize: 16)
        analysisLabel.numberOfLines = 0
        analysisLabel.textAlignment = .center
        analysisLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(analysisLabel)

        NSLayoutConstraint.activate([
            analysisLabel.topAnchor.constraint(equalTo: dietRecordView.bottomAnchor, constant: 16),
            analysisLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            analysisLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    func fetchDietData(for date: Date) {
        // 서버와 연동하여 선택한 날짜의 식단 정보를 가져오는 로직
        // 예시 데이터 추가
        let exampleDiets = ["그린 샐러드", "김치찌개 외"]
        for diet in exampleDiets {
            let label = UILabel()
            label.text = diet
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .center
            dietRecordView.addArrangedSubview(label)
        }
    }

    func formatDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
