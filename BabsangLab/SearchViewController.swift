import UIKit

class SearchViewController: UIViewController {

    // UI 요소
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let selectedFoodsView = UIStackView()
    let saveButton = UIButton()

    // 데이터
    var foodDatabase = ["김치찌개", "된장찌개", "불고기", "삼겹살", "비빔밥", "잡채"]
    var filteredFoods: [String] = []
    var selectedFoods: [String: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupSearchBar()
        setupTableView()
        setupSelectedFoodsView()
        setupSaveButton()
        setupGestureToDismissKeyboard()

        filteredFoods = foodDatabase
    }

    // MARK: - UI 설정

    func setupSearchBar() {
        searchBar.placeholder = "음식을 검색하세요"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300) // 테이블 뷰 높이 조정
        ])
    }

    func setupSelectedFoodsView() {
        selectedFoodsView.axis = .vertical
        selectedFoodsView.spacing = 8
        selectedFoodsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectedFoodsView)

        NSLayoutConstraint.activate([
            selectedFoodsView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            selectedFoodsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedFoodsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectedFoodsView.heightAnchor.constraint(lessThanOrEqualToConstant: 200) // 선택된 음식 뷰 높이 제한
        ])
    }

    func setupSaveButton() {
        saveButton.setTitle("식단 기록하기", for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: selectedFoodsView.bottomAnchor, constant: 16),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setupGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - 음식 선택 및 하단 뷰 추가

    func addFoodToSelectedView(food: String) {
        guard selectedFoods[food] == nil else { return } // 중복 추가 방지

        selectedFoods[food] = 1

        let foodView = createFoodView(for: food)
        selectedFoodsView.addArrangedSubview(foodView)
    }

    func createFoodView(for food: String) -> UIView {
        let containerView = UIView()
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let label = UILabel()
        label.text = food
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false

        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.value = 1
        stepper.tag = selectedFoodsView.arrangedSubviews.count
        stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
        stepper.translatesAutoresizingMaskIntoConstraints = false

        let countLabel = UILabel()
        countLabel.text = "1인분"
        countLabel.font = .systemFont(ofSize: 16)
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(label)
        containerView.addSubview(stepper)
        containerView.addSubview(countLabel)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            stepper.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stepper.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            countLabel.trailingAnchor.constraint(equalTo: stepper.leadingAnchor, constant: -8),
            countLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        return containerView
    }

    @objc func stepperValueChanged(_ sender: UIStepper) {
        let index = sender.tag
        if let foodView = selectedFoodsView.arrangedSubviews[index] as? UIView,
           let countLabel = foodView.subviews.compactMap({ $0 as? UILabel }).last,
           let food = foodView.subviews.compactMap({ $0 as? UILabel }).first?.text {
            countLabel.text = "\(Int(sender.value))인분"
            selectedFoods[food] = Int(sender.value)
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredFoods = foodDatabase.filter { $0.contains(searchText) }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredFoods[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFood = filteredFoods[indexPath.row]
        addFoodToSelectedView(food: selectedFood)
    }
}
