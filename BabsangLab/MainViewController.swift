import UIKit

class MainViewController: UIViewController {

    let nutritionView = UIView()
    let calorieLabel = UILabel()
    var recordCollectionView: UICollectionView!
    let analysisView = UIView()
    let floatingPlusButton = UIButton(type: .system)
    let progressCircle = CAShapeLayer()
    var totalCalories: CGFloat = 1800
    var consumedCalories: CGFloat = 1600

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCustomNavigationBar()
        setupNutritionView()
        setupRecordView()
        setupAnalysisView()
        setupFloatingButtons()
        updateCalorieProgress()
    }
    
    func setupCustomNavigationBar() {
            let navigationBarView = UIView()
            navigationBarView.translatesAutoresizingMaskIntoConstraints = false
            navigationBarView.backgroundColor = .white
            navigationBarView.layer.shadowColor = UIColor.black.cgColor
            navigationBarView.layer.shadowOpacity = 0.1
            navigationBarView.layer.shadowOffset = CGSize(width: 0, height: 2)
            navigationBarView.layer.shadowRadius = 4

            let titleLabel = UILabel()
            titleLabel.text = "오늘 식단"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.textColor = .black
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            navigationBarView.addSubview(titleLabel)
            view.addSubview(navigationBarView)

            NSLayoutConstraint.activate([
                navigationBarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
                navigationBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigationBarView.heightAnchor.constraint(equalToConstant: 60),

                titleLabel.centerXAnchor.constraint(equalTo: navigationBarView.centerXAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: navigationBarView.bottomAnchor, constant: -10)
            ])
        }

   
    

    func setupNutritionView() {
        nutritionView.translatesAutoresizingMaskIntoConstraints = false
        nutritionView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        nutritionView.layer.cornerRadius = 10

        // Progress Circle
        let progressView = UIView()
        progressView.translatesAutoresizingMaskIntoConstraints = false

        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: 50, y: 50),
            radius: 40,
            startAngle: -.pi / 2,
            endAngle: .pi / 2 * 3,
            clockwise: true
        )
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = UIColor.green.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = 10
        progressCircle.strokeEnd = 0.0 // 초기값
        progressView.layer.addSublayer(progressCircle)

        // 중앙 칼로리 Label
        let centerLabel = UILabel()
        centerLabel.text = "\(Int(consumedCalories))\n/\(Int(totalCalories)) kcal"
        centerLabel.numberOfLines = 2
        centerLabel.textAlignment = .center
        centerLabel.font = UIFont.boldSystemFont(ofSize: 10)
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(centerLabel)

        NSLayoutConstraint.activate([
            centerLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor)
        ])

        // Nutrition Stack
        let nutritionStack = UIStackView()
        nutritionStack.axis = .horizontal
        nutritionStack.distribution = .fillEqually
        nutritionStack.spacing = 20
        nutritionStack.translatesAutoresizingMaskIntoConstraints = false

        let nutritionLabels = ["탄수화물", "단백질", "지방"]
        let nutritionValues = ["120g / 300g", "20g / 60g", "20g / 50g"]

        for (index, label) in nutritionLabels.enumerated() {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 0

            let titleLabel = UILabel()
            titleLabel.text = label
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            titleLabel.textAlignment = .center

            let valueLabel = UILabel()
            valueLabel.text = nutritionValues[index]
            valueLabel.font = UIFont.boldSystemFont(ofSize: 10)
            valueLabel.textAlignment = .center

            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(valueLabel)
            nutritionStack.addArrangedSubview(stack)
        }

        view.addSubview(nutritionView)
        nutritionView.addSubview(progressView)
        nutritionView.addSubview(nutritionStack)

        NSLayoutConstraint.activate([
            nutritionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            nutritionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nutritionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nutritionView.heightAnchor.constraint(equalToConstant: 140),

            progressView.leadingAnchor.constraint(equalTo: nutritionView.leadingAnchor, constant: 16),
            progressView.centerYAnchor.constraint(equalTo: nutritionView.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 100),
            progressView.heightAnchor.constraint(equalToConstant: 100),

            nutritionStack.topAnchor.constraint(equalTo: nutritionView.topAnchor, constant: 28),
            nutritionStack.trailingAnchor.constraint(equalTo: nutritionView.trailingAnchor, constant: -16),
            nutritionStack.leadingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: 8),
            nutritionStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    func setupRecordView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 120)

        recordCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        recordCollectionView.translatesAutoresizingMaskIntoConstraints = false
        recordCollectionView.backgroundColor = .clear
        recordCollectionView.register(RecordCell.self, forCellWithReuseIdentifier: "RecordCell")
        recordCollectionView.dataSource = self
        recordCollectionView.delegate = self

        view.addSubview(recordCollectionView)

        NSLayoutConstraint.activate([
            recordCollectionView.topAnchor.constraint(equalTo: nutritionView.bottomAnchor, constant: 36),
            recordCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recordCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recordCollectionView.heightAnchor.constraint(equalToConstant: 220),
        ])
    }

    func setupAnalysisView() {
        analysisView.translatesAutoresizingMaskIntoConstraints = false
        analysisView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        analysisView.layer.cornerRadius = 10

        let analysisLabel = UILabel()
        analysisLabel.text = """
        섭취 권장 영양소\n단백질\n
        다음 식사 추천
        추천 식재료: 닭가슴살
        추천 메뉴: 닭가슴살 스테이크
        """
        analysisLabel.font = UIFont.systemFont(ofSize: 14)
        analysisLabel.numberOfLines = 0
        analysisLabel.translatesAutoresizingMaskIntoConstraints = false

        analysisView.addSubview(analysisLabel)
        view.addSubview(analysisView)

        NSLayoutConstraint.activate([
            analysisView.topAnchor.constraint(equalTo: recordCollectionView.bottomAnchor, constant: 16),
            analysisView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            analysisView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            analysisView.heightAnchor.constraint(equalToConstant: 140),

            analysisLabel.topAnchor.constraint(equalTo: analysisView.topAnchor, constant: 16),
            analysisLabel.leadingAnchor.constraint(equalTo: analysisView.leadingAnchor, constant: 16),
            analysisLabel.trailingAnchor.constraint(equalTo: analysisView.trailingAnchor, constant: -16),
        ])
    }

    func setupFloatingButtons() {
        floatingPlusButton.setTitle("+", for: .normal)
        floatingPlusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 34)
        floatingPlusButton.backgroundColor = .systemGreen
        floatingPlusButton.tintColor = .white
        floatingPlusButton.layer.cornerRadius = 30
        floatingPlusButton.translatesAutoresizingMaskIntoConstraints = false

        floatingPlusButton.titleLabel?.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            floatingPlusButton.titleLabel!.leadingAnchor.constraint(equalTo: floatingPlusButton.leadingAnchor, constant: 19.5),
            floatingPlusButton.titleLabel!.topAnchor.constraint(equalTo: floatingPlusButton.topAnchor, constant: -3),
        ])

        floatingPlusButton.addTarget(self, action: #selector(showAddOptions), for: .touchUpInside)
        view.addSubview(floatingPlusButton)

        NSLayoutConstraint.activate([
            floatingPlusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            floatingPlusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -26),
            floatingPlusButton.widthAnchor.constraint(equalToConstant: 60),
            floatingPlusButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }


    func updateCalorieProgress() {
        let progress = consumedCalories / totalCalories
        progressCircle.strokeEnd = progress // 섭취 비율에 따른 업데이트
        progressCircle.strokeColor = UIColor.green.cgColor
    }

    @objc func showAddOptions() {
        let alertController = UIAlertController(title: "음식 추가하기", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "사진으로 추가하기", style: .default))
        alertController.addAction(UIAlertAction(title: "앨범으로 추가하기", style: .default))
        alertController.addAction(UIAlertAction(title: "검색으로 추가하기", style: .default))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alertController, animated: true)
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordCell", for: indexPath) as! RecordCell
        cell.configure(name: "음식 \(indexPath.row)", mealTime: "아침", calories: "test kcal")
        return cell
    }
}

class RecordCell: UICollectionViewCell {
    private let nameLabel = UILabel()
    private let mealTimeLabel = UILabel()
    private let calorieLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)

        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        mealTimeLabel.font = UIFont.systemFont(ofSize: 14)
        calorieLabel.font = UIFont.systemFont(ofSize: 14)

        let stackView = UIStackView(arrangedSubviews: [nameLabel, mealTimeLabel, calorieLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, mealTime: String, calories: String) {
        nameLabel.text = name
        mealTimeLabel.text = mealTime
        calorieLabel.text = calories
    }
}

#Preview {
    MainViewController()
}

