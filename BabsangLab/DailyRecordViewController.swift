import UIKit

class DailyRecordViewController: UIViewController {
    
    var selectedDate: Date? // 전달받은 날짜
    let nutritionView = UIView()
    let recordCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let analysisView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupNutritionView()
        setupRecordCollectionView()
        setupAnalysisView()
        
        fetchRecords(for: selectedDate)
    }
    
    func setupNavigationBar() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd"
        title = dateFormatter.string(from: selectedDate ?? Date())
    }
    
    func setupNutritionView() {
        nutritionView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        nutritionView.layer.cornerRadius = 10
        nutritionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nutritionView)
        
        NSLayoutConstraint.activate([
            nutritionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nutritionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nutritionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nutritionView.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        let nutritionLabel = UILabel()
        nutritionLabel.text = "칼로리: 1,000 / 1,800 kcal\n탄수화물: 120g / 300g\n단백질: 20g / 60g\n지방: 20g / 50g"
        nutritionLabel.numberOfLines = 0
        nutritionLabel.font = .systemFont(ofSize: 14)
        nutritionLabel.translatesAutoresizingMaskIntoConstraints = false
        nutritionView.addSubview(nutritionLabel)
        
        NSLayoutConstraint.activate([
            nutritionLabel.leadingAnchor.constraint(equalTo: nutritionView.leadingAnchor, constant: 16),
            nutritionLabel.topAnchor.constraint(equalTo: nutritionView.topAnchor, constant: 16),
            nutritionLabel.trailingAnchor.constraint(equalTo: nutritionView.trailingAnchor, constant: -16),
        ])
    }
    
    func setupRecordCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        recordCollectionView.setCollectionViewLayout(layout, animated: false)
        recordCollectionView.backgroundColor = .clear
        recordCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "recordCell")
        recordCollectionView.translatesAutoresizingMaskIntoConstraints = false
        recordCollectionView.dataSource = self
        recordCollectionView.delegate = self
        view.addSubview(recordCollectionView)
        
        NSLayoutConstraint.activate([
            recordCollectionView.topAnchor.constraint(equalTo: nutritionView.bottomAnchor, constant: 16),
            recordCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recordCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recordCollectionView.heightAnchor.constraint(equalToConstant: 120),
        ])
    }
    
    func setupAnalysisView() {
        analysisView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        analysisView.layer.cornerRadius = 10
        analysisView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(analysisView)
        
        NSLayoutConstraint.activate([
            analysisView.topAnchor.constraint(equalTo: recordCollectionView.bottomAnchor, constant: 16),
            analysisView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            analysisView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            analysisView.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        let analysisLabel = UILabel()
        analysisLabel.text = "칼로리 섭취 부족\n탄수화물 섭취 부족\n단백질 섭취 부족\n지방 섭취 부족"
        analysisLabel.numberOfLines = 0
        analysisLabel.font = .systemFont(ofSize: 14)
        analysisLabel.translatesAutoresizingMaskIntoConstraints = false
        analysisView.addSubview(analysisLabel)
        
        NSLayoutConstraint.activate([
            analysisLabel.leadingAnchor.constraint(equalTo: analysisView.leadingAnchor, constant: 16),
            analysisLabel.topAnchor.constraint(equalTo: analysisView.topAnchor, constant: 16),
            analysisLabel.trailingAnchor.constraint(equalTo: analysisView.trailingAnchor, constant: -16),
        ])
    }
    
    func fetchRecords(for date: Date?) {
        // 서버에서 데이터를 가져오는 로직
        // 예시: ["김치찌개", "불고기"]
        recordCollectionView.reloadData()
    }
}

extension DailyRecordViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2 // 서버에서 가져온 데이터 개수
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recordCell", for: indexPath)
        cell.backgroundColor = .lightGray
        return cell
    }
}

