import UIKit

// MARK: - Models

struct SingleRecordRequest: Codable {
    let name: String
    let foodName: String
    let date: String
    let mealtime: String
    let intake_amount: Int
}

struct AnalysisDto: Codable {
    let foodName: String
    let calories: Double
    let fat: Double
    let protein: Double
    let carbs: Double
    let allergy: String?
    let medical_issue: String?
}


// MARK: - SearchViewController

class SearchViewController: UIViewController {

    // UI 요소
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let selectedFoodsScrollView = UIScrollView()
    let selectedFoodsStackView = UIStackView()
    let saveButton = UIButton()

    // 데이터
    let foodDatabase = [ "가지볶음", "간장게장", "갈비구이", "갈비찜", "갈비탕", "갈치구이", "갈치조림", "감자전", "감자조림", "감자채볶음", "감자탕", "갓김치", "건새우볶음", "경단", "계란국", "계란말이", "계란찜", "계란후라이", "고등어구이", "고등어조림", "고사리나물", "고추장진미채볶음", "고추튀김", "곰탕_설렁탕", "곱창구이", "곱창전골", "과메기", "김밥", "김치볶음밥", "김치전", "김치찌개", "김치찜", "깍두기", "깻잎장아찌", "꼬막찜", "꽁치조림", "꽈리고추무침", "꿀떡", "나박김치", "누룽지", "닭갈비", "닭계장", "닭볶음탕", "더덕구이", "도라지무침", "도토리묵", "동그랑땡", "동태찌개", "된장찌개", "두부김치", "두부조림", "땅콩조림", "떡갈비", "떡국_만두국", "떡꼬치", "떡볶이", "라면", "라볶이", "막국수", "만두", "매운탕", "멍게", "메추리알장조림", "멸치볶음", "무국", "무생채", "물냉면", "물회", "미역국", "미역줄기볶음", "배추김치", "백김치", "보쌈", "부추김치", "북엇국", "불고기", "비빔냉면", "비빔밥", "산낙지", "삼겹살", "삼계탕", "새우볶음밥", "새우튀김", "생선전", "소세지볶음", "송편", "수육", "수정과", "수제비", "숙주나물", "순대", "순두부찌개", "시금치나물", "시래기국", "식혜", "알밥", "애호박볶음", "약과", "약식", "양념게장", "양념치킨", "어묵볶음", "연근조림", "열무국수", "열무김치", "오이소박이", "오징어채볶음", "오징어튀김", "우엉조림", "유부초밥", "육개장", "육회", "잔치국수", "잡곡밥", "잡채", "장어구이", "장조림", "전복죽", "젓갈", "제육볶음", "조개구이", "조기구이", "족발", "쭈꾸미볶음", "주먹밥", "짜장면", "짬뽕", "쫄면", "찜닭", "총각김치", "추어탕", "칼국수", "코다리조림", "콩국수", "콩나물국", "콩나물무침", "콩자반", "파김치", "파전", "편육", "피자", "한과", "해물찜", "호박전", "호박죽", "홍어무침", "황태구이", "회무침", "후라이드치킨", "훈제오리" ]

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
        selectedFoodsScrollView.translatesAutoresizingMaskIntoConstraints = false
        selectedFoodsScrollView.showsVerticalScrollIndicator = true
        view.addSubview(selectedFoodsScrollView)

        NSLayoutConstraint.activate([
            selectedFoodsScrollView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            selectedFoodsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedFoodsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectedFoodsScrollView.heightAnchor.constraint(equalToConstant: 200) // 선택된 음식 뷰 높이 제한
        ])

        selectedFoodsStackView.axis = .vertical
        selectedFoodsStackView.spacing = 8
        selectedFoodsStackView.translatesAutoresizingMaskIntoConstraints = false
        selectedFoodsScrollView.addSubview(selectedFoodsStackView)

        NSLayoutConstraint.activate([
            selectedFoodsStackView.topAnchor.constraint(equalTo: selectedFoodsScrollView.topAnchor),
            selectedFoodsStackView.leadingAnchor.constraint(equalTo: selectedFoodsScrollView.leadingAnchor),
            selectedFoodsStackView.trailingAnchor.constraint(equalTo: selectedFoodsScrollView.trailingAnchor),
            selectedFoodsStackView.bottomAnchor.constraint(equalTo: selectedFoodsScrollView.bottomAnchor),
            selectedFoodsStackView.widthAnchor.constraint(equalTo: selectedFoodsScrollView.widthAnchor)
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
            saveButton.topAnchor.constraint(equalTo: selectedFoodsScrollView.bottomAnchor, constant: 16),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
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
        selectedFoodsStackView.addArrangedSubview(foodView)
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
        stepper.tag = selectedFoodsStackView.arrangedSubviews.count
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
        if index < selectedFoodsStackView.arrangedSubviews.count {
            if let foodView = selectedFoodsStackView.arrangedSubviews[index] as? UIView,
               let countLabel = foodView.subviews.compactMap({ $0 as? UILabel }).last,
               let food = foodView.subviews.compactMap({ $0 as? UILabel }).first?.text {
                countLabel.text = "\(Int(sender.value))인분"
                selectedFoods[food] = Int(sender.value)
            }
        }
    }

    // MARK: - Save Button Action

    @objc func saveButtonTapped() {
        guard !selectedFoods.isEmpty else {
            showAlert(title: "선택된 음식이 없습니다.", message: "추가할 음식을 선택해주세요.")
            return
        }

        guard let userName = UserInfoManager.shared.name else {
            showAlert(title: "사용자 정보가 없습니다.", message: "사용자 정보를 확인해주세요.")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = dateFormatter.string(from: Date())

        // mealtime을 현재 시간에 따라 결정
        let mealtime = getCurrentMealtime()

        // 음식 개수에 따라 다른 API로 전송
        if selectedFoods.count == 1, let food = selectedFoods.keys.first, let intakeAmount = selectedFoods[food] {
            // 단일 음식 기록
            let singleRecordRequest = SingleRecordRequest(
                name: userName,
                foodName: food,
                date: todayDateString,
                mealtime: mealtime,
                intake_amount: intakeAmount
            )
            sendSingleRecordToServer(request: singleRecordRequest)
        } else {
            // 다중 음식 기록
            var records: [SingleRecordRequest] = []
            for (foodName, intakeAmount) in selectedFoods {
                let record = SingleRecordRequest(
                    name: userName,
                    foodName: foodName,
                    date: todayDateString,
                    mealtime: mealtime,
                    intake_amount: intakeAmount
                )
                records.append(record)
            }

            sendMultipleRecordsToServer(records: records)
        }
    }

    // MARK: - Networking

    /// 단일 음식 기록을 서버로 전송하는 함수
    func sendSingleRecordToServer(request: SingleRecordRequest) {
        guard let url = URL(string: "http://34.64.172.57:8080/analysis/record") else {
            showAlert(title: "URL 오류", message: "유효한 URL을 생성할 수 없습니다.")
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(request)
            urlRequest.httpBody = jsonData

            // 요청 데이터 로그 출력
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Single Record Request JSON: \(jsonString)")
            }
        } catch {
            showAlert(title: "인코딩 오류", message: "요청 데이터를 인코딩하는 중 오류가 발생했습니다.")
            print("❌ JSON 인코딩 오류: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // 에러 처리
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "네트워크 오류", message: error.localizedDescription)
                }
                print("❌ 네트워크 오류: \(error.localizedDescription)")
                return
            }

            // 응답 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 단일 음식 식단 기록 응답 수신: 상태 코드 \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "서버 오류", message: "서버 응답 상태 코드: \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            // 데이터 존재 여부 확인
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(title: "데이터 오류", message: "서버로부터 데이터가 수신되지 않았습니다.")
                }
                print("❌ 데이터 오류: 서버로부터 데이터가 수신되지 않았습니다.")
                return
            }

            // 응답 데이터 로그 출력
            if let responseString = String(data: data, encoding: .utf8) {
                print("Single Record Response JSON: \(responseString)")
            }

            // JSON 파싱
            do {
                let decoder = JSONDecoder()
                let responseDto = try decoder.decode(ResponseDto<AnalysisDto>.self, from: data)

                if responseDto.success, let analysis = responseDto.responseDto {
                    DispatchQueue.main.async {
                        self.showAlert(title: "성공", message: "식단이 성공적으로 기록되었습니다.", completion: {
                            // 메인 화면으로 돌아가기
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                        self.clearSelectedFoods()
                    }
                } else {
                    let errorMessage = responseDto.error ?? "알 수 없는 오류가 발생했습니다."
                    DispatchQueue.main.async {
                        self.showAlert(title: "오류", message: errorMessage)
                    }
                    print("❌ 서버 오류: \(errorMessage)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "파싱 오류", message: "서버 응답 데이터를 파싱하는 중 오류가 발생했습니다.")
                }
                print("❌ JSON 파싱 오류: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    /// 다중 음식 기록을 서버로 전송하는 함수
    func sendMultipleRecordsToServer(records: [SingleRecordRequest]) {
        guard let url = URL(string: "http://34.64.172.57:8080/analysis/foods/record") else {
            showAlert(title: "URL 오류", message: "유효한 URL을 생성할 수 없습니다.")
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(records)
            urlRequest.httpBody = jsonData

            // 요청 데이터 로그 출력
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 다중 음식 식단 기록 요청 JSON: \(jsonString)")
            }
        } catch {
            showAlert(title: "인코딩 오류", message: "요청 데이터를 인코딩하는 중 오류가 발생했습니다.")
            print("❌ JSON 인코딩 오류: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // 에러 처리
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "네트워크 오류", message: error.localizedDescription)
                }
                print("❌ 네트워크 오류: \(error.localizedDescription)")
                return
            }

            // 응답 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 다중 음식 식단 기록 응답 수신: 상태 코드 \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "서버 오류", message: "서버 응답 상태 코드: \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            // 데이터 존재 여부 확인
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(title: "데이터 오류", message: "서버로부터 데이터가 수신되지 않았습니다.")
                }
                print("❌ 데이터 오류: 서버로부터 데이터가 수신되지 않았습니다.")
                return
            }

            // 응답 데이터 로그 출력
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 다중 음식 식단 기록 응답 JSON: \(responseString)")
            }

            // JSON 파싱
            do {
                let decoder = JSONDecoder()
                let responseDto = try decoder.decode(ResponseDto<[AnalysisDto]>.self, from: data)

                if responseDto.success, let analysisList = responseDto.responseDto {
                    DispatchQueue.main.async {
                        self.showAlert(title: "성공", message: "식단이 성공적으로 기록되었습니다.", completion: {
                            // 메인 화면으로 돌아가기
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                        self.clearSelectedFoods()
                    }
                } else {
                    let errorMessage = responseDto.error ?? "알 수 없는 오류가 발생했습니다."
                    DispatchQueue.main.async {
                        self.showAlert(title: "오류", message: errorMessage)
                    }
                    print("❌ 서버 오류: \(errorMessage)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "파싱 오류", message: "서버 응답 데이터를 파싱하는 중 오류가 발생했습니다.")
                }
                print("❌ JSON 파싱 오류: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    // MARK: - Helper Methods

    func clearSelectedFoods() {
        selectedFoods.removeAll()
        selectedFoodsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    /// showAlert 함수에 completion 핸들러 추가
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completion?()
        }))
        present(alertController, animated: true)
    }

    /// 현재 시간에 따른 식사 시간 결정 함수
    func getCurrentMealtime() -> String {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let totalMinutes = hour * 60 + minute

        if totalMinutes >= 1 && totalMinutes < 11 * 60 {
            return "breakfast"
        } else if totalMinutes >= 11 * 60 && totalMinutes < 17 * 60 {
            return "lunch"
        } else {
            return "dinner"
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFoods = foodDatabase
        } else {
            filteredFoods = foodDatabase.filter { $0.contains(searchText) }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 기본 셀을 사용합니다. 커스텀 셀을 원하면 별도로 구현할 수 있습니다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredFoods[indexPath.row]
        return cell
    }

    // 음식 선택 시 selectedFoodsView에 추가
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFood = filteredFoods[indexPath.row]
        addFoodToSelectedView(food: selectedFood)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

