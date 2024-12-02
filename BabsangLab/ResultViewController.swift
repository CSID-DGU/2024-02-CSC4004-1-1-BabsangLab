import UIKit


class ResultViewController: UIViewController {
    var selectedImage: UIImage?
    var selectedFoodType: FoodType = .unknown
    
    // 기존 UI 요소
    let foodTypeLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // 추가된 UI 요소
    let servingSizeLabel = UILabel()
    let servingSizeStepper = UIStepper()
    let saveButton = UIButton()
    let tableView = UITableView()
    
    // 추가된 UI 요소: "원하시는 음식이 아니라면?" 라벨
    let notDesiredFoodLabel = UILabel()
    
    // 데이터 저장을 위한 변수
    var singleFoodName: String?
    var singleFoodNutrition: [String: Double] = [:]
    var singleFoodServingSize: Int = 1
    
    var multipleFoodNames: [String] = []
    var multipleFoodNutritions: [[String: Any]] = []
    var multipleFoodServingSizes: [Int] = []
    
    // 서버 URL 설정
    let singlePredictURL = "https://foodclassificationproject.du.r.appspot.com/predict"
    let multiPredictURL = "https://foodclassificationproject.du.r.appspot.com/multi_predict"
    
    // 영양소 정보 API URL
    let nutritionAPIBaseURL = "http://34.64.172.57:8080/analysis"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupResultUI()
        
        guard let image = selectedImage else {
            foodTypeLabel.text = "이미지가 없습니다."
            return
        }
        
        switch selectedFoodType {
        case .singleFood:
            predictFood(image: image, url: singlePredictURL, forMultipleFoods: false)
        case .multiFood:
            predictFood(image: image, url: multiPredictURL, forMultipleFoods: true)
        case .unknown:
            foodTypeLabel.text = "음식 종류를 선택하지 않았습니다."
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
       
        saveButton.updateGradientFrame()
    }
    
    func setupResultUI() {
        // 이미지 뷰 설정
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // 이미지 비율 유지
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.addShadow(opacity: 0.2, offset: CGSize(width: 0, height: 3), radius: 5)
        view.addSubview(imageView)
        
        if let image = selectedImage {
            imageView.image = image
        }
        
        // 음식 타입 라벨 설정
        foodTypeLabel.styleLabel(fontSize: 18, weight: .bold, textColor: .darkGray, alignment: .center, numberOfLines: 0)
        view.addSubview(foodTypeLabel)
        
        // 활동 인디케이터 설정
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemBlue
        view.addSubview(activityIndicator)
        
        // 인분 수 라벨 설정
        servingSizeLabel.styleLabel(fontSize: 16, weight: .medium, textColor: .darkGray, alignment: .center)
        servingSizeLabel.isHidden = true // 초기에는 숨김
        view.addSubview(servingSizeLabel)
        
        // 스테퍼 설정
        servingSizeStepper.translatesAutoresizingMaskIntoConstraints = false
        servingSizeStepper.minimumValue = 1
        servingSizeStepper.value = 1
        servingSizeStepper.isHidden = true // 초기에는 숨김
        servingSizeStepper.addTarget(self, action: #selector(servingSizeChanged(_:)), for: .valueChanged)
        view.addSubview(servingSizeStepper)
        
        // 저장 버튼 설정
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("식단 기록하기", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18) // 글꼴을 굵게 하고 크기 조정
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true // 그라데이션과 cornerRadius가 올바르게 적용되도록 설정
        saveButton.isHidden = true // 초기에는 숨김
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        
        // 그라데이션 적용 (버튼의 프레임이 설정된 후에 적용)
        saveButton.applyGradient(colors: [UIColor.systemGreen, UIColor.systemBlue], cornerRadius: 10)
        
        // 다중 음식일 경우 테이블 뷰 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true // 초기에는 숨김
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MultiFoodCell.self, forCellReuseIdentifier: "MultiFoodCell")
        tableView.layer.cornerRadius = 10
        tableView.addShadow(opacity: 0.2, offset: CGSize(width: 0, height: 3), radius: 5)
        view.addSubview(tableView)
        
        // "원하시는 음식이 아니라면?" 라벨 설정
        notDesiredFoodLabel.styleLabel(fontSize: 16, weight: .medium, textColor: .systemBlue, alignment: .center, numberOfLines: 0)
        
       
        let attributedString = NSMutableAttributedString(string: "원하시는 음식이 아니신가요?")
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        notDesiredFoodLabel.attributedText = attributedString
        notDesiredFoodLabel.isUserInteractionEnabled = true // 터치 가능하도록 설정
        view.addSubview(notDesiredFoodLabel)
        
        // 탭 제스처 인식기 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(notDesiredFoodTapped))
        notDesiredFoodLabel.addGestureRecognizer(tapGesture)
        
        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            // 이미지 뷰 제약조건
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // 이미지의 비율 유지 (가로:세로 = 이미지의 실제 비율)
            imageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.4),
            
            // 음식 타입 라벨 제약조건
            foodTypeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            foodTypeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            foodTypeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 활동 인디케이터 제약조건
            activityIndicator.topAnchor.constraint(equalTo: notDesiredFoodLabel.bottomAnchor, constant: 20),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 인분 수 라벨 제약조건 (단일 음식)
            servingSizeLabel.topAnchor.constraint(equalTo: foodTypeLabel.bottomAnchor, constant: 20),
            servingSizeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 스테퍼 제약조건 (단일 음식)
            servingSizeStepper.topAnchor.constraint(equalTo: servingSizeLabel.bottomAnchor, constant: 10),
            servingSizeStepper.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 저장 버튼 제약조건
            saveButton.topAnchor.constraint(equalTo: servingSizeStepper.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 220), // 버튼 너비 약간 확대
            saveButton.heightAnchor.constraint(equalToConstant: 60),  // 버튼 높이 약간 확대
            
            // 다중 음식일 때의 테이블 뷰 배치
            tableView.topAnchor.constraint(equalTo: foodTypeLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20),
            
            // "원하시는 음식이 아니라면?" 라벨 위치 조정 (버튼 아래로 이동)
            notDesiredFoodLabel.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10),
            notDesiredFoodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            notDesiredFoodLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            notDesiredFoodLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc func servingSizeChanged(_ sender: UIStepper) {
        singleFoodServingSize = Int(sender.value)
        servingSizeLabel.text = "인분: \(singleFoodServingSize)"
    }
    
    @objc func saveButtonTapped() {
        if selectedFoodType == .singleFood {
            // 단일 음식 식단 기록하기 요청
            if let foodName = singleFoodName {
                recordSingleFood(foodName: foodName, servingSize: singleFoodServingSize)
            }
        } else if selectedFoodType == .multiFood {
            // 다중 음식 식단 기록하기 요청
            recordMultipleFoods()
        }
    }
    
    // MARK: - "원하시는 음식이 아니라면?" 라벨 탭 핸들러
    
    @objc func notDesiredFoodTapped() {
        let alert = UIAlertController(title: "음식 추가", message: "직접 음식을 추가하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "네", style: .default, handler: { _ in
            self.navigateToSearchViewController()
        }))
        alert.addAction(UIAlertAction(title: "아니요", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func navigateToSearchViewController() {
        guard let navigationController = self.navigationController else { return }
        
        // 메인 화면으로 팝 (루트 뷰 컨트롤러로 이동)
        navigationController.popToRootViewController(animated: false)
        
        // SearchViewController 인스턴스 생성
        let searchVC = SearchViewController()
        searchVC.modalPresentationStyle = .fullScreen
        
        // SearchViewController로 푸시
        navigationController.pushViewController(searchVC, animated: true)
    }
    
    func predictFood(image: UIImage, url: String, forMultipleFoods: Bool) {
        guard let requestURL = URL(string: url) else {
            foodTypeLabel.text = "예측 서버 URL이 잘못되었습니다."
            return
        }
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.foodTypeLabel.text = "예측 중입니다..."
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 이미지를 JPEG 데이터로 변환
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            DispatchQueue.main.async {
                self.foodTypeLabel.text = "이미지 데이터를 처리할 수 없습니다."
                self.activityIndicator.stopAnimating()
            }
            return
        }
        
        // Multipart/form-data 형식으로 요청 바디 구성
        var body = Data()
        let filename = "image.jpg"
        let mimeType = "image/jpeg"
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        // 요청 정보 로그 출력
        print("📤 서버로 예측 요청을 전송합니다: \(requestURL.absoluteString)")
        
        // URLSession을 사용하여 요청 전송
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // 응답 정보 로그 출력
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 서버 응답 상태 코드: \(httpResponse.statusCode)")
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.foodTypeLabel.text = "예측 중 오류 발생: \(error.localizedDescription)"
                }
                print("❌ 예측 요청 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.foodTypeLabel.text = "서버 응답 데이터가 없습니다."
                }
                print("❌ 서버 응답 데이터가 없습니다.")
                return
            }
            
            // 응답 데이터 로그 출력
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 서버 응답 데이터: \(responseString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.handlePredictionResponse(json: json, forMultipleFoods: forMultipleFoods)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.foodTypeLabel.text = "JSON 파싱 오류"
                    }
                    print("❌ JSON 파싱 오류: 데이터 형식이 맞지 않습니다.")
                }
            } catch {
                DispatchQueue.main.async {
                    self.foodTypeLabel.text = "JSON 파싱 오류: \(error.localizedDescription)"
                }
                print("❌ JSON 파싱 오류: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func handlePredictionResponse(json: [String: Any], forMultipleFoods: Bool) {
        if forMultipleFoods {
            // 다중 음식 예측 처리 로직
            if let predictions = json["cropped_predictions"] as? [[String: String]] {
                let foodNamesRaw = predictions.compactMap { prediction -> String? in
                    guard let foodNameRaw = prediction["class"] else { return nil }
                    return foodNameRaw.precomposedStringWithCanonicalMapping
                }
                
                let uniqueFoodNames = Array(Set(foodNamesRaw)) // 중복 제거
                foodTypeLabel.text = "다중 음식 예측 결과: \(uniqueFoodNames.joined(separator: ", "))"
                
                // 예측된 음식명 리스트로 영양소 정보 요청
                requestNutritionInfoForMultipleFoods(foodNames: uniqueFoodNames)
            } else {
                foodTypeLabel.text = "다중 음식 예측 결과를 처리할 수 없습니다."
                print("❌ 다중 음식 예측 결과를 파싱할 수 없습니다.")
            }
        } else {
            // 단일 음식 예측 처리 로직
            if let topPrediction = json["prediction"] as? [String: Any],
               let foodNameRaw = topPrediction["class"] as? String,
               let confidenceStr = topPrediction["confidence"] as? String {
                
                // % 기호 제거
                let confidenceValueStr = confidenceStr.replacingOccurrences(of: "%", with: "")
                if let confidence = Double(confidenceValueStr) {
                    
                    // Unicode 정규화
                    let foodName = foodNameRaw.precomposedStringWithCanonicalMapping
                    
                    print("✅ 예측 결과: \(foodName), 정확도: \(confidence)%")
                    
                    if confidence >= 80.0 {
                        // 80% 이상일 때 바로 영양소 정보 요청
                        requestNutritionInfo(for: foodName)
                    } else if let top3 = json["top_3"] as? [[String: String]] {
                        // 80% 미만일 때 상위 3개 중 선택
                        let optionsRaw = top3.compactMap { $0["class"] }
                        let options = optionsRaw.map { $0.precomposedStringWithCanonicalMapping }
                        showTop3Selection(options: options)
                    } else {
                        foodTypeLabel.text = "예측 결과를 처리할 수 없습니다."
                        print("❌ top_3를 파싱할 수 없습니다.")
                    }
                } else {
                    foodTypeLabel.text = "예측 결과를 처리할 수 없습니다."
                    print("❌ confidence 값을 숫자로 변환할 수 없습니다.")
                }
            } else if let top3 = json["top_3"] as? [[String: String]] {
                // prediction이 null이고, top_3가 존재할 때
                let optionsRaw = top3.compactMap { $0["class"] }
                let options = optionsRaw.map { $0.precomposedStringWithCanonicalMapping }
                showTop3Selection(options: options)
            } else {
                foodTypeLabel.text = "예측 결과를 처리할 수 없습니다."
                print("❌ 예측 결과를 파싱할 수 없습니다.")
            }
        }
    }
    
    func showTop3Selection(options: [String]) {
        let alert = UIAlertController(title: "예측 결과", message: "결과 중 하나를 선택하세요.", preferredStyle: .actionSheet)
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { _ in
                self.foodTypeLabel.text = "선택한 음식: \(option)"
                print("🔹 사용자가 선택한 음식: \(option)")
                self.requestNutritionInfo(for: option)
            }))
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func requestNutritionInfo(for foodName: String) {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.foodTypeLabel.text = "\(foodName)의 영양 정보를 불러오는 중입니다..."
        }
        
        // 한글 음식명을 URL 인코딩
        guard let encodedFoodName = foodName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(nutritionAPIBaseURL)?foodName=\(encodedFoodName)") else {
            DispatchQueue.main.async {
                self.foodTypeLabel.text = "영양소 정보 API URL이 잘못되었습니다."
                self.activityIndicator.stopAnimating()
            }
            print("❌ 영양소 정보 API URL이 잘못되었습니다.")
            return
        }
        
        // 영양소 정보 요청 로그 출력
        print("📤 영양소 정보를 요청합니다: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // 응답 정보 로그 출력
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 영양소 정보 응답 수신: 상태 코드 \(httpResponse.statusCode)")
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.foodTypeLabel.text = "영양 정보 요청 중 오류 발생: \(error.localizedDescription)"
                }
                print("❌ 영양 정보 요청 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.foodTypeLabel.text = "영양 정보 응답 데이터가 없습니다."
                }
                print("❌ 영양 정보 응답 데이터가 없습니다.")
                return
            }
            
            // 응답 데이터 로그 출력
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 영양소 정보 응답 데이터: \(responseString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let responseDto = json["responseDto"] as? [String: Any],
                   let calories = responseDto["calories"] as? Double,
                   let fat = responseDto["fat"] as? Double,
                   let protein = responseDto["protein"] as? Double,
                   let carbs = responseDto["carbs"] as? Double {
                    
                    let allergy = responseDto["allergy"] as? String ?? "정보 없음"
                    
                    DispatchQueue.main.async {
                        self.displayNutritionInfo(foodName: foodName, calories: calories, fat: fat, protein: protein, carbs: carbs, allergy: allergy)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.foodTypeLabel.text = "영양 정보 데이터를 처리할 수 없습니다."
                    }
                    print("❌ 영양 정보 데이터를 처리할 수 없습니다.")
                }
            } catch {
                DispatchQueue.main.async {
                    self.foodTypeLabel.text = "JSON 파싱 오류: \(error.localizedDescription)"
                }
                print("❌ JSON 파싱 오류: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func requestNutritionInfoForMultipleFoods(foodNames: [String]) {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.foodTypeLabel.text = "다중 음식의 영양 정보를 불러오는 중입니다..."
        }
        
        let foodNamesString = foodNames.joined(separator: ",")
        
        // 한글 음식명을 URL 인코딩
        guard let encodedFoodNames = foodNamesString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(nutritionAPIBaseURL)/foods?foodNames=\(encodedFoodNames)") else {
            DispatchQueue.main.async {
                self.foodTypeLabel.text = "영양소 정보 API URL이 잘못되었습니다."
                self.activityIndicator.stopAnimating()
            }
            print("❌ 영양소 정보 API URL이 잘못되었습니다.")
            return
        }
        
        // 영양소 정보 요청 로그 출력
        print("📤 다중 음식 영양소 정보를 요청합니다: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // 응답 정보 로그 출력
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 다중 음식 영양소 정보 응답 수신: 상태 코드 \(httpResponse.statusCode)")
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.foodTypeLabel.text = "영양 정보 요청 중 오류 발생: \(error.localizedDescription)"
                }
                print("❌ 영양 정보 요청 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.foodTypeLabel.text = "영양 정보 응답 데이터가 없습니다."
                }
                print("❌ 영양 정보 응답 데이터가 없습니다.")
                return
            }
            
            // 응답 데이터 로그 출력
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 다중 음식 영양소 정보 응답 데이터: \(responseString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let responseDto = json["responseDto"] as? [[String: Any]] {
                    
                    // 각 음식의 영양소 정보를 저장
                    self.multipleFoodServingSizes = Array(repeating: 1, count: responseDto.count)
                    self.multipleFoodNames = []
                    self.multipleFoodNutritions = []
                    
                    for (index, analysisDto) in responseDto.enumerated() {
                        let foodName = foodNames[index]
                        var nutritionData: [String: Any] = [:]
                        if let calories = analysisDto["calories"] as? Double {
                            nutritionData["calories"] = calories
                        }
                        if let fat = analysisDto["fat"] as? Double {
                            nutritionData["fat"] = fat
                        }
                        if let protein = analysisDto["protein"] as? Double {
                            nutritionData["protein"] = protein
                        }
                        if let carbs = analysisDto["carbs"] as? Double {
                            nutritionData["carbs"] = carbs
                        }
                        if let allergy = analysisDto["allergy"] as? String {
                            nutritionData["allergy"] = allergy
                        } else {
                            nutritionData["allergy"] = "정보 없음"
                        }
                        self.multipleFoodNames.append(foodName)
                        self.multipleFoodNutritions.append(nutritionData)
                    }
                    
                    DispatchQueue.main.async {
                        self.displayNutritionInfoForMultipleFoods()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.foodTypeLabel.text = "영양 정보 데이터를 처리할 수 없습니다."
                    }
                    print("❌ 영양 정보 데이터를 처리할 수 없습니다.")
                }
            } catch {
                DispatchQueue.main.async {
                    self.foodTypeLabel.text = "JSON 파싱 오류: \(error.localizedDescription)"
                }
                print("❌ JSON 파싱 오류: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // 다중 음식의 영양소 정보를 표시하는 함수
    func displayNutritionInfoForMultipleFoods() {
        DispatchQueue.main.async {
            // 테이블 뷰와 저장 버튼을 표시
            self.tableView.isHidden = false
            self.saveButton.isHidden = false
            self.tableView.reloadData()
            self.foodTypeLabel.text = "다중 음식의 영양 정보가 준비되었습니다."
            print("✅ 다중 음식 영양 정보 표시 완료")
        }
    }
    
    func displayNutritionInfo(foodName: String, calories: Double, fat: Double, protein: Double, carbs: Double, allergy: String) {
        let nutritionInfo = """
        음식명: \(foodName)
        칼로리: \(calories) kcal
        지방: \(fat) g
        단백질: \(protein) g
        탄수화물: \(carbs) g
        알레르기 유발 성분: \(allergy)
        """
        DispatchQueue.main.async {
            self.foodTypeLabel.text = nutritionInfo
        }
        print("✅ 영양 정보 표시 완료")
        
        // 단일 음식 데이터 저장
        singleFoodName = foodName
        singleFoodNutrition = [
            "calories": calories,
            "fat": fat,
            "protein": protein,
            "carbs": carbs
        ]
        
        // 인분 수 조절 UI와 저장 버튼 표시
        DispatchQueue.main.async {
            self.servingSizeLabel.isHidden = false
            self.servingSizeStepper.isHidden = false
            self.saveButton.isHidden = false
        }
    }
    
    // 식단 기록하기 요청 함수 (단일 음식)
    func recordSingleFood(foodName: String, servingSize: Int) {
        let urlString = "http://34.64.172.57:8080/analysis/record"
        guard let url = URL(string: urlString) else {
            print("❌ 식단 기록 API URL이 잘못되었습니다.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 현재 날짜와 시간
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: Date())
        
        // 현재 시간에 따른 식사 시간 결정
        let mealtime = getCurrentMealtime()
        
        // 사용자 이름 가져오기 (회원가입 시 저장된 이름 사용)
        let userName = getUserName()
        
        let parameters: [String: Any] = [
            "name": userName,
            "foodName": foodName,
            "date": currentDate,
            "mealtime": mealtime,
            "intake_amount": servingSize // 배열이 아닌 정수로 전송
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
            
            // 요청 로그 출력
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 식단 기록 요청: \(jsonString)")
            }
        } catch {
            print("❌ JSON 직렬화 오류: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 식단 기록 요청 오류: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "오류", message: "식단 기록 중 오류가 발생했습니다: \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 식단 기록 응답 수신: 상태 코드 \(httpResponse.statusCode)")
            }
            
            // 응답 데이터 처리 (필요에 따라 추가)
            
            DispatchQueue.main.async {
                // 성공 메시지 표시
                self.showAlert(title: "성공", message: "식단이 성공적으로 기록되었습니다.") {
                    // 메인 화면으로 돌아가기
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }.resume()
    }

    // 식단 기록하기 요청 함수 (다중 음식)
    func recordMultipleFoods() {
        let urlString = "http://34.64.172.57:8080/analysis/foods/record"
        guard let url = URL(string: urlString) else {
            print("❌ 식단 기록 API URL이 잘못되었습니다.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 현재 날짜와 시간
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: Date())
        
        // 현재 시간에 따른 식사 시간 결정
        let mealtime = getCurrentMealtime()
        
        // 사용자 이름 가져오기 (회원가입 시 저장된 이름 사용)
        let userName = getUserName()
        
        // 각 음식 항목을 개별 FoodRecord 객체로 변환하여 배열에 담기
        var foodRecords: [FoodRecord] = []
        for (index, foodName) in multipleFoodNames.enumerated() {
            let servingSize = multipleFoodServingSizes.indices.contains(index) ? multipleFoodServingSizes[index] : 1
            let record = FoodRecord(
                name: userName,
                intake_amount: servingSize,
                date: currentDate,
                mealtime: mealtime,
                foodName: foodName
            )
            foodRecords.append(record)
        }
        
        // JSON 직렬화
        do {
            let jsonData = try JSONEncoder().encode(foodRecords)
            request.httpBody = jsonData
            
            // 요청 로그 출력
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 다중 음식 식단 기록 요청 JSON: \(jsonString)")
            }
        } catch {
            print("❌ JSON 직렬화 오류: \(error.localizedDescription)")
            return
        }
        
        // URLSession을 사용하여 요청 전송
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 식단 기록 요청 오류: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "오류", message: "식단 기록 중 오류가 발생했습니다: \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 다중 음식 식단 기록 응답 수신: 상태 코드 \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "오류", message: "서버 응답 오류: \(httpResponse.statusCode)")
                    }
                    return
                }
            }
            
            // 응답 데이터 처리 (필요에 따라 추가)
            
            DispatchQueue.main.async {
                // 성공 메시지 표시
                self.showAlert(title: "성공", message: "식단이 성공적으로 기록되었습니다.") {
                    // 메인 화면으로 돌아가기
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }.resume()
    }
    
    // 현재 시간에 따른 식사 시간 결정 함수
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
    
    func getUserName() -> String {
        if let userName = UserInfoManager.shared.name {
            return userName
        } else {
            return "UnknownUser"
        }
    }
    
    // MARK: - Helper Methods
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completion?()
        }))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    // 다중 음식일 때의 테이블 뷰 셀 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return multipleFoodNames.count
    }
    
    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MultiFoodCell", for: indexPath) as? MultiFoodCell else {
            return UITableViewCell()
        }
        
        let foodName = multipleFoodNames[indexPath.row]
        let nutritionData = multipleFoodNutritions[indexPath.row]
        let servingSize = multipleFoodServingSizes[indexPath.row]
        
        cell.configure(foodName: foodName, nutritionData: nutritionData, servingSize: servingSize)
        cell.stepper.tag = indexPath.row
        cell.stepper.addTarget(self, action: #selector(multiFoodServingSizeChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    @objc func multiFoodServingSizeChanged(_ sender: UIStepper) {
        let index = sender.tag
        let newValue = Int(sender.value)
        multipleFoodServingSizes[index] = newValue
        
        // 셀의 레이블 업데이트
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? MultiFoodCell {
            cell.servingSizeLabel.text = "인분: \(newValue)"
        }
    }
}

// MARK: - MultiFoodCell

// 다중 음식 셀 클래스
class MultiFoodCell: UITableViewCell {
    let foodNameLabel = UILabel()
    let nutritionLabel = UILabel()
    let servingSizeLabel = UILabel()
    let stepper = UIStepper()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 스타일 설정
        foodNameLabel.styleLabel(fontSize: 16, weight: .bold, textColor: .black, alignment: .left)
        nutritionLabel.styleLabel(fontSize: 14, weight: .regular, textColor: .darkGray, alignment: .left, numberOfLines: 0)
        servingSizeLabel.styleLabel(fontSize: 16, weight: .medium, textColor: .black, alignment: .left)
        
        // 스테퍼 설정
        stepper.minimumValue = 1
        stepper.value = 1
        stepper.translatesAutoresizingMaskIntoConstraints = false
        
        // 서브뷰 추가
        contentView.addSubview(foodNameLabel)
        contentView.addSubview(nutritionLabel)
        contentView.addSubview(servingSizeLabel)
        contentView.addSubview(stepper)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            // 음식명 레이블
            foodNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            foodNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            foodNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // 영양소 레이블
            nutritionLabel.topAnchor.constraint(equalTo: foodNameLabel.bottomAnchor, constant: 5),
            nutritionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nutritionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // 인분 수 레이블
            servingSizeLabel.topAnchor.constraint(equalTo: nutritionLabel.bottomAnchor, constant: 5),
            servingSizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            // 스테퍼
            stepper.centerYAnchor.constraint(equalTo: servingSizeLabel.centerYAnchor),
            stepper.leadingAnchor.constraint(equalTo: servingSizeLabel.trailingAnchor, constant: 10),
            stepper.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),
            stepper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        // 셀 스타일링
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        self.addShadow(color: .black, opacity: 0.1, offset: CGSize(width: 0, height: 2), radius: 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(foodName: String, nutritionData: [String: Any], servingSize: Int) {
        foodNameLabel.text = "음식명: \(foodName)"
        
        var nutritionText = ""
        if let calories = nutritionData["calories"] as? Double {
            nutritionText += "칼로리: \(calories) kcal\n"
        }
        if let fat = nutritionData["fat"] as? Double {
            nutritionText += "지방: \(fat) g\n"
        }
        if let protein = nutritionData["protein"] as? Double {
            nutritionText += "단백질: \(protein) g\n"
        }
        if let carbs = nutritionData["carbs"] as? Double {
            nutritionText += "탄수화물: \(carbs) g\n"
        }
        if let allergy = nutritionData["allergy"] as? String {
            nutritionText += "알레르기 유발 성분: \(allergy)"
        }
        nutritionLabel.text = nutritionText
        
        servingSizeLabel.text = "인분: \(servingSize)"
        stepper.value = Double(servingSize)
    }
}

// MARK: - FoodRecord Struct

struct FoodRecord: Codable {
    let name: String
    let intake_amount: Int
    let date: String
    let mealtime: String
    let foodName: String
}

// MARK: - Data Extension for Appending Strings

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

