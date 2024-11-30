import UIKit

class ResultViewController: UIViewController {
    var selectedImage: UIImage?
    var selectedFoodType: FoodType?
    
    // 기존 UI 요소
    let foodTypeLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // 추가된 UI 요소
    let servingSizeLabel = UILabel()
    let servingSizeStepper = UIStepper()
    let saveButton = UIButton()
    let tableView = UITableView()
    
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
    let nutritionAPIBaseURL = "http://34.47.127.47:8080/analysis"
    
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
        default:
            foodTypeLabel.text = "음식 종류를 선택하지 않았습니다."
        }
    }
    
    func setupResultUI() {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        if let image = selectedImage {
            imageView.image = image
        }
        
        foodTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        foodTypeLabel.textAlignment = .center
        foodTypeLabel.font = UIFont.boldSystemFont(ofSize: 15)
        foodTypeLabel.textColor = .darkGray
        foodTypeLabel.numberOfLines = 0
        view.addSubview(foodTypeLabel)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        // 추가된 UI 요소 설정
        servingSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        servingSizeLabel.text = "인분: 1"
        servingSizeLabel.font = UIFont.systemFont(ofSize: 16)
        servingSizeLabel.isHidden = true // 초기에는 숨김
        view.addSubview(servingSizeLabel)
        
        servingSizeStepper.translatesAutoresizingMaskIntoConstraints = false
        servingSizeStepper.minimumValue = 1
        servingSizeStepper.value = 1
        servingSizeStepper.isHidden = true // 초기에는 숨김
        servingSizeStepper.addTarget(self, action: #selector(servingSizeChanged(_:)), for: .valueChanged)
        view.addSubview(servingSizeStepper)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("식단 기록하기", for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.isHidden = true // 초기에는 숨김
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        
        // 다중 음식일 경우 테이블 뷰 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true // 초기에는 숨김
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MultiFoodCell.self, forCellReuseIdentifier: "MultiFoodCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            foodTypeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            foodTypeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            foodTypeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activityIndicator.topAnchor.constraint(equalTo: foodTypeLabel.bottomAnchor, constant: 20),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 단일 음식일 때의 UI 배치
            servingSizeLabel.topAnchor.constraint(equalTo: foodTypeLabel.bottomAnchor, constant: 20),
            servingSizeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            servingSizeStepper.topAnchor.constraint(equalTo: servingSizeLabel.bottomAnchor, constant: 10),
            servingSizeStepper.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            saveButton.topAnchor.constraint(equalTo: servingSizeStepper.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 다중 음식일 때의 테이블 뷰 배치
            tableView.topAnchor.constraint(equalTo: foodTypeLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20)
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
    
    func predictFood(image: UIImage, url: String, forMultipleFoods: Bool) {
        guard let requestURL = URL(string: url) else {
            foodTypeLabel.text = "예측 서버 URL이 잘못되었습니다."
            return
        }
        
        activityIndicator.startAnimating()
        foodTypeLabel.text = "예측 중입니다..."
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 이미지를 JPEG 데이터로 변환
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            foodTypeLabel.text = "이미지 데이터를 처리할 수 없습니다."
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
            // 응답 정보 로그 출력
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 서버로부터 응답을 받았습니다: 상태 코드 \(httpResponse.statusCode)")
            }
            
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "예측 중 오류 발생: \(error.localizedDescription)"
                }
                print("❌ 예측 요청 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "서버 응답 데이터가 없습니다."
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
                        self?.handlePredictionResponse(json: json, forMultipleFoods: forMultipleFoods)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.foodTypeLabel.text = "JSON 파싱 오류"
                    }
                    print("❌ JSON 파싱 오류: 데이터 형식이 맞지 않습니다.")
                }
            } catch {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "JSON 파싱 오류: \(error.localizedDescription)"
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
            // 단일 음식 예측 처리 로직 수정
            if let topPrediction = json["prediction"] as? [String: Any],
               let foodNameRaw = topPrediction["class"] as? String,
               let confidenceStr = topPrediction["confidence"] as? String {
                
                // `%` 기호 제거
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
        activityIndicator.startAnimating()
        foodTypeLabel.text = "\(foodName)의 영양 정보를 불러오는 중입니다..."
        
        // 한글 음식명을 URL 인코딩
        guard let encodedFoodName = foodName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(nutritionAPIBaseURL)?foodName=\(encodedFoodName)") else {
            foodTypeLabel.text = "영양소 정보 API URL이 잘못되었습니다."
            activityIndicator.stopAnimating()
            print("❌ 영양소 정보 API URL이 잘못되었습니다.")
            return
        }
        
        // 영양소 정보 요청 로그 출력
        print("📤 영양소 정보를 요청합니다: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // 응답 정보 로그 출력
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 영양소 정보 응답 수신: 상태 코드 \(httpResponse.statusCode)")
            }
            
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "영양 정보 요청 중 오류 발생: \(error.localizedDescription)"
                }
                print("❌ 영양 정보 요청 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "영양 정보 응답 데이터가 없습니다."
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
                        self?.displayNutritionInfo(foodName: foodName, calories: calories, fat: fat, protein: protein, carbs: carbs, allergy: allergy)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.foodTypeLabel.text = "영양 정보 데이터를 처리할 수 없습니다."
                    }
                    print("❌ 영양 정보 데이터를 처리할 수 없습니다.")
                }
            } catch {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "JSON 파싱 오류: \(error.localizedDescription)"
                }
                print("❌ JSON 파싱 오류: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func requestNutritionInfoForMultipleFoods(foodNames: [String]) {
        activityIndicator.startAnimating()
        foodTypeLabel.text = "다중 음식의 영양 정보를 불러오는 중입니다..."
        
        let foodNamesString = foodNames.joined(separator: ",")
        
        // 한글 음식명을 URL 인코딩
        guard let encodedFoodNames = foodNamesString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(nutritionAPIBaseURL)/foods?foodNames=\(encodedFoodNames)") else {
            foodTypeLabel.text = "영양소 정보 API URL이 잘못되었습니다."
            activityIndicator.stopAnimating()
            print("❌ 영양소 정보 API URL이 잘못되었습니다.")
            return
        }
        
        // 영양소 정보 요청 로그 출력
        print("📤 다중 음식 영양소 정보를 요청합니다: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // 응답 정보 로그 출력
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 다중 음식 영양소 정보 응답 수신: 상태 코드 \(httpResponse.statusCode)")
            }
            
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "영양 정보 요청 중 오류 발생: \(error.localizedDescription)"
                }
                print("❌ 영양 정보 요청 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "영양 정보 응답 데이터가 없습니다."
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
                    self?.multipleFoodServingSizes = Array(repeating: 1, count: responseDto.count)
                    self?.multipleFoodNames = []
                    self?.multipleFoodNutritions = []
                    
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
                        self?.multipleFoodNames.append(foodName)
                        self?.multipleFoodNutritions.append(nutritionData)
                    }
                    
                    DispatchQueue.main.async {
                        self?.displayNutritionInfoForMultipleFoods()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.foodTypeLabel.text = "영양 정보 데이터를 처리할 수 없습니다."
                    }
                    print("❌ 영양 정보 데이터를 처리할 수 없습니다.")
                }
            } catch {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "JSON 파싱 오류: \(error.localizedDescription)"
                }
                print("❌ JSON 파싱 오류: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // 다중 음식의 영양소 정보를 표시하는 함수
    func displayNutritionInfoForMultipleFoods() {
        // 테이블 뷰와 저장 버튼을 표시
        tableView.isHidden = false
        saveButton.isHidden = false
        tableView.reloadData()
        print("✅ 다중 음식 영양 정보 표시 완료")
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
        foodTypeLabel.text = nutritionInfo
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
        servingSizeLabel.isHidden = false
        servingSizeStepper.isHidden = false
        saveButton.isHidden = false
    }
    
    // 식단 기록하기 요청 함수 (단일 음식)
    func recordSingleFood(foodName: String, servingSize: Int) {
        let urlString = "http://34.47.127.47:8080/analysis/record"
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
            "intake_amount": servingSize
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
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 식단 기록 응답 수신: 상태 코드 \(httpResponse.statusCode)")
            }
            
            // 응답 데이터 처리 (필요에 따라 추가)
            
            DispatchQueue.main.async {
                // 메인 화면으로 돌아가기
                self.navigationController?.popToRootViewController(animated: true)
            }
        }.resume()
    }
    
    // 식단 기록하기 요청 함수 (다중 음식)
    func recordMultipleFoods() {
        let urlString = "http://34.47.127.47:8080/analysis/foods/record"
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
            "foodNames": multipleFoodNames,
            "date": currentDate,
            "mealtime": mealtime,
            "intake_amounts": multipleFoodServingSizes
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
            
            // 요청 로그 출력
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 다중 음식 식단 기록 요청: \(jsonString)")
            }
        } catch {
            print("❌ JSON 직렬화 오류: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 식단 기록 요청 오류: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 다중 음식 식단 기록 응답 수신: 상태 코드 \(httpResponse.statusCode)")
            }
            
            // 응답 데이터 처리 (필요에 따라 추가)
            
            DispatchQueue.main.async {
                // 메인 화면으로 돌아가기
                self.navigationController?.popToRootViewController(animated: true)
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
    
    // 사용자 이름 가져오기 함수 (회원가입 시 저장된 이름 사용)
    func getUserName() -> String {
        // 예시로 UserDefaults에서 사용자 이름을 가져옵니다.
        // 실제 앱에서는 적절한 방법으로 사용자 이름을 가져오세요.
        if let userName = UserDefaults.standard.string(forKey: "userName") {
            return userName
        } else {
            return "UnknownUser"
        }
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

// 다중 음식 셀 클래스
class MultiFoodCell: UITableViewCell {
    let foodNameLabel = UILabel()
    let nutritionLabel = UILabel()
    let servingSizeLabel = UILabel()
    let stepper = UIStepper()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        foodNameLabel.translatesAutoresizingMaskIntoConstraints = false
        nutritionLabel.translatesAutoresizingMaskIntoConstraints = false
        servingSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        stepper.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(foodNameLabel)
        contentView.addSubview(nutritionLabel)
        contentView.addSubview(servingSizeLabel)
        contentView.addSubview(stepper)
        
        NSLayoutConstraint.activate([
            foodNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            foodNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            foodNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            nutritionLabel.topAnchor.constraint(equalTo: foodNameLabel.bottomAnchor, constant: 5),
            nutritionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nutritionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            servingSizeLabel.topAnchor.constraint(equalTo: nutritionLabel.bottomAnchor, constant: 5),
            servingSizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            stepper.centerYAnchor.constraint(equalTo: servingSizeLabel.centerYAnchor),
            stepper.leadingAnchor.constraint(equalTo: servingSizeLabel.trailingAnchor, constant: 10),
            stepper.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),
            stepper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        stepper.minimumValue = 1
        stepper.value = 1
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

// Data에 문자열을 추가하기 위한 확장
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

