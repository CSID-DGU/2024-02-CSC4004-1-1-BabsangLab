import UIKit
import Foundation

// MARK: - Models

// 공통 응답 모델을 제네릭으로 정의하여 재사용성을 높였습니다.
struct ResponseDto<T: Codable>: Codable {
    let responseDto: T?
    let error: String?
    let success: Bool

    enum CodingKeys: String, CodingKey {
        case responseDto = "ResponseDto"
        case error
        case success
    }
}


// 기존의 RecordResponse 모델
struct RecordResponse: Codable {
    let mealtime: String
    let calories: Double
    let fat: Double
    let protein: Double
    let carbs: Double
    let intakeAmount: Int?

    enum CodingKeys: String, CodingKey {
        case mealtime
        case calories
        case fat
        case protein
        case carbs
        case intakeAmount = "intake_amount"
    }
}

// 달성률 API 응답 모델
struct RateResponseDto: Codable {
    let rateCalories: Double
    let rateProtein: Double
    let rateFat: Double
    let rateCarb: Double

    enum CodingKeys: String, CodingKey {
        case rateCalories
        case rateProtein
        case rateFat
        case rateCarb
    }
}

struct RateResponseContainer: Codable {
    let rateResponseDto: RateResponseDto?

    enum CodingKeys: String, CodingKey {
        case rateResponseDto = "RateResponseDto"
    }
}

// 몸무게 정보가 없을 때의 알림 응답 모델
struct NotifyResponseDto: Codable {
    let message: String

    enum CodingKeys: String, CodingKey {
        case message
    }
}

struct NotifyResponseContainer: Codable {
    let notifyResponseDto: NotifyResponseDto?

    enum CodingKeys: String, CodingKey {
        case notifyResponseDto = "NotifyResponseDto"
    }
}

// 음식 추천 API 응답 모델
struct FoodRecommendation: Codable {
    let foodName: String
    let calories: Double
    let fat: Double
    let protein: Double
    let carbs: Double
    let allergy: String?

    enum CodingKeys: String, CodingKey {
        case foodName
        case calories
        case fat
        case protein
        case carbs
        case allergy
    }
}

struct RecommendResponseContainer: Codable {
    let recommendDtoList: [FoodRecommendation]?

    enum CodingKeys: String, CodingKey {
        case recommendDtoList = "RecommendDtoList"
    }
}

// MARK: - MainViewController

class MainViewController: UIViewController {

    // MARK: - UI Elements

    let nutritionView = UIView()
    let calorieLabel = UILabel()
    var recordCollectionView: UICollectionView!
    let analysisView = UIView()
    let analysisScrollView = UIScrollView()
    let analysisContentView = UIView()
    let floatingPlusButton = UIButton(type: .system)
    let progressCircle = CAShapeLayer()
    var totalCalories: CGFloat = 1800
    var consumedCalories: CGFloat = 0 // 초기값 0으로 설정
    var nutritionDetails: (carbs: Double, protein: Double, fat: Double) = (0, 0, 0)
    var recordList: [RecordResponse] = []

    // 달성률 및 음식 추천을 위한 변수
    var achievementRates: RateResponseDto?
    var foodRecommendations: [FoodRecommendation] = []
    var displayedRecommendations: [FoodRecommendation] = []

    // MARK: - User Information
    var userName: String {
        return UserInfoManager.shared.name ?? "defaultUser"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDefaultUser()
        setupCustomNavigationBar()
        setupNutritionView()
        setupRecordView()
        setupAnalysisView()
        setupFloatingButtons()
        fetchTodayDiet()
        fetchAchievementRates()
        fetchFoodRecommendations()
    }

    // MARK: - Setup Default User (For Testing)
    func setupDefaultUser() {
        if UserInfoManager.shared.name == nil {
            UserInfoManager.shared.name = "s" // 기본 사용자 이름 설정
        }
    }

    // MARK: - Setup UI

    func setupCustomNavigationBar() {
        let navigationBarView = UIView()
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        navigationBarView.backgroundColor = .white
        navigationBarView.layer.shadowColor = UIColor.black.cgColor
        navigationBarView.layer.shadowOpacity = 0.1
        navigationBarView.layer.shadowOffset = CGSize(width: 0, height: 2)
        navigationBarView.layer.shadowRadius = 4

        let titleLabel = UILabel()
        titleLabel.text = "오늘의 식단"
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
        progressCircle.strokeEnd = 0 // 초기값 0
        progressView.layer.addSublayer(progressCircle)

        let centerLabel = UILabel()
        centerLabel.text = "0\n/ \(Int(totalCalories)) kcal"
        centerLabel.numberOfLines = 2
        centerLabel.textAlignment = .center
        centerLabel.font = UIFont.boldSystemFont(ofSize: 12)
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        centerLabel.tag = 100 // 나중에 접근하기 위해 태그 설정
        progressView.addSubview(centerLabel)

        NSLayoutConstraint.activate([
            centerLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor)
        ])

        let nutritionStack = UIStackView()
        nutritionStack.axis = .horizontal
        nutritionStack.distribution = .fillEqually
        nutritionStack.spacing = 20
        nutritionStack.translatesAutoresizingMaskIntoConstraints = false

        let nutritionLabels = ["탄수화물", "단백질", "지방"]
        let nutritionValues = ["0g", "0g", "0g"]

        for (index, label) in nutritionLabels.enumerated() {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.alignment = .center

            let titleLabel = UILabel()
            titleLabel.text = label
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            titleLabel.textAlignment = .center

            let valueLabel = UILabel()
            valueLabel.text = nutritionValues[index]
            valueLabel.font = UIFont.boldSystemFont(ofSize: 12)
            valueLabel.textAlignment = .center
            valueLabel.tag = 200 + index // 나중에 접근하기 위해 태그 설정

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
        layout.minimumLineSpacing = 16

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

        // UIScrollView와 contentView 초기화
        analysisScrollView.translatesAutoresizingMaskIntoConstraints = false
        analysisContentView.translatesAutoresizingMaskIntoConstraints = false

        analysisView.addSubview(analysisScrollView)
        analysisScrollView.addSubview(analysisContentView)

        view.addSubview(analysisView)

        NSLayoutConstraint.activate([
            analysisView.topAnchor.constraint(equalTo: recordCollectionView.bottomAnchor, constant: 16),
            analysisView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            analysisView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            analysisView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100), // 필요한 경우 조정

            analysisScrollView.topAnchor.constraint(equalTo: analysisView.topAnchor),
            analysisScrollView.leadingAnchor.constraint(equalTo: analysisView.leadingAnchor),
            analysisScrollView.trailingAnchor.constraint(equalTo: analysisView.trailingAnchor),
            analysisScrollView.bottomAnchor.constraint(equalTo: analysisView.bottomAnchor),

            analysisContentView.topAnchor.constraint(equalTo: analysisScrollView.topAnchor),
            analysisContentView.leadingAnchor.constraint(equalTo: analysisScrollView.leadingAnchor),
            analysisContentView.trailingAnchor.constraint(equalTo: analysisScrollView.trailingAnchor),
            analysisContentView.bottomAnchor.constraint(equalTo: analysisScrollView.bottomAnchor),
            analysisContentView.widthAnchor.constraint(equalTo: analysisScrollView.widthAnchor)
        ])
    }

    func setupFloatingButtons() {
        floatingPlusButton.setTitle("+", for: .normal)
        floatingPlusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 34)
        floatingPlusButton.backgroundColor = .systemGreen
        floatingPlusButton.tintColor = .white
        floatingPlusButton.layer.cornerRadius = 30
        floatingPlusButton.translatesAutoresizingMaskIntoConstraints = false

        floatingPlusButton.addTarget(self, action: #selector(showAddOptions), for: .touchUpInside)
        view.addSubview(floatingPlusButton)

        NSLayoutConstraint.activate([
            floatingPlusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            floatingPlusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -26),
            floatingPlusButton.widthAnchor.constraint(equalToConstant: 60),
            floatingPlusButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    // MARK: - Actions

    @objc func showAddOptions() {
        let alertController = UIAlertController(title: "음식 추가하기", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "사진으로 추가하기", style: .default) { _ in
            self.showFoodOptionSelector() // 기존의 카메라 호출 로직
        })
        alertController.addAction(UIAlertAction(title: "앨범으로 추가하기", style: .default) { _ in
            self.openPhotoLibrary() // 새로 추가된 앨범 호출 로직
        })
        alertController.addAction(UIAlertAction(title: "검색으로 추가하기", style: .default) { _ in
            self.navigateToSearch() // 새로 추가된 검색 화면 이동
        })
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alertController, animated: true)
    }

    // 검색으로 추가하기 화면으로 이동하는 메서드
    func navigateToSearch() {
        let searchVC = SearchViewController()
        searchVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(searchVC, animated: true)
    }

    func showFoodOptionSelector() {
        let alertController = UIAlertController(title: "음식 종류 선택", message: "단일 음식과 다중 음식 중 선택하세요.", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "단일 음식", style: .default) { _ in
            self.navigateToCamera(foodType: .singleFood)
        })

        alertController.addAction(UIAlertAction(title: "다중 음식", style: .default) { _ in
            self.navigateToCamera(foodType: .multiFood)
        })

        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alertController, animated: true)
    }

    func navigateToCamera(foodType: FoodType) {
        guard let navigationController = self.navigationController else {
            print("NavigationController가 nil입니다.")
            return
        }
        let cameraVC = CameraViewController()
        cameraVC.selectedFoodType = foodType
        navigationController.pushViewController(cameraVC, animated: true)
    }

    func showFoodOptionSelectorForAlbum(image: UIImage) {
        let alertController = UIAlertController(title: "음식 종류 선택", message: "단일 음식과 다중 음식 중 선택하세요.", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "단일 음식", style: .default) { _ in
            self.navigateToResultViewController(image: image, foodType: .singleFood)
        })

        alertController.addAction(UIAlertAction(title: "다중 음식", style: .default) { _ in
            self.navigateToResultViewController(image: image, foodType: .multiFood)
        })

        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alertController, animated: true)
    }

    func navigateToResultViewController(image: UIImage, foodType: FoodType) {
        let resultVC = ResultViewController()
        resultVC.selectedImage = image
        resultVC.selectedFoodType = foodType
        navigationController?.pushViewController(resultVC, animated: true)
    }

    func openCamera() {
        let cameraVC = UIImagePickerController()
        cameraVC.sourceType = .camera
        cameraVC.delegate = self
        present(cameraVC, animated: true)
    }

    func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("앨범을 사용할 수 없습니다.")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    // MARK: - Networking

    func fetchTodayDiet() {
        guard let url = constructURL() else {
            print("유효한 URL을 생성할 수 없습니다.")
            return
        }

        print("요청 URL: \(url.absoluteString)") // 요청 URL 출력

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 에러 처리
            if let error = error {
                print("네트워크 요청 중 에러 발생: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "네트워크 오류: \(error.localizedDescription)")
                }
                return
            }

            // 응답 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("서버 응답 상태 코드: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    print("서버 응답 오류")
                    DispatchQueue.main.async {
                        self.showUnknownErrorAlert(message: "서버 응답 오류: \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            // 데이터 존재 여부 확인
            guard let data = data else {
                print("응답 데이터가 없습니다.")
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "응답 데이터가 없습니다.")
                }
                return
            }

            // 데이터 출력 (원시 데이터)
            if let rawData = String(data: data, encoding: .utf8) {
                print("응답 데이터: \(rawData)")
            }

            // JSON 파싱
            do {
                let decoder = JSONDecoder()
                let responseDto = try decoder.decode(ResponseDto<[RecordResponse]>.self, from: data)

                if responseDto.success, let records = responseDto.responseDto {
                    // 메인 스레드에서 UI 업데이트
                    DispatchQueue.main.async {
                        self.processFetchedRecords(records)
                    }
                } else {
                    if let errorMessage = responseDto.error {
                        print("API 오류: \(errorMessage)")
                        DispatchQueue.main.async {
                            self.showUnknownErrorAlert(message: "API 오류: \(errorMessage)")
                        }
                    } else {
                        print("알 수 없는 오류가 발생했습니다.")
                        DispatchQueue.main.async {
                            self.showUnknownErrorAlert(message: "알 수 없는 오류가 발생했습니다.")
                        }
                    }
                }
            } catch {
                print("JSON 파싱 중 에러 발생: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "데이터 파싱 오류: \(error.localizedDescription)")
                }
            }
        }

        task.resume()
    }

    func constructURL() -> URL? {
        let baseURL = "http://34.47.127.47:8080/record/date"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = dateFormatter.string(from: Date())

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "userName", value: userName),
            URLQueryItem(name: "date", value: todayDateString)
        ]

        return components?.url
    }

    // 달성률 가져오기
    func fetchAchievementRates() {
        guard let url = constructAchievementRateURL() else {
            print("유효한 URL을 생성할 수 없습니다.")
            return
        }

        print("Achievement Rate 요청 URL: \(url.absoluteString)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 에러 처리
            if let error = error {
                print("Achievement Rate 요청 중 에러 발생: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "네트워크 오류: \(error.localizedDescription)")
                }
                return
            }

            // 응답 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("Achievement Rate 서버 응답 상태 코드: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    print("Achievement Rate 서버 응답 오류")
                    DispatchQueue.main.async {
                        self.showUnknownErrorAlert(message: "서버 응답 오류: \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            // 데이터 존재 여부 확인
            guard let data = data else {
                print("Achievement Rate 응답 데이터가 없습니다.")
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "응답 데이터가 없습니다.")
                }
                return
            }

            // 데이터 출력 (원시 데이터)
            if let rawData = String(data: data, encoding: .utf8) {
                print("Achievement Rate 응답 데이터: \(rawData)")
            }

            // JSON 파싱
            do {
                let decoder = JSONDecoder()
                if let messageResponse = try? decoder.decode(ResponseDto<NotifyResponseContainer>.self, from: data),
                   let message = messageResponse.responseDto?.notifyResponseDto?.message {
                    // 몸무게 정보가 없을 때 처리
                    DispatchQueue.main.async {
                        self.showUnknownErrorAlert(message: message)
                    }
                } else {
                    let rateResponse = try decoder.decode(ResponseDto<RateResponseContainer>.self, from: data)
                    if rateResponse.success, let rates = rateResponse.responseDto?.rateResponseDto {
                        self.achievementRates = rates
                        DispatchQueue.main.async {
                            self.updateAnalysisView()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showUnknownErrorAlert(message: "알 수 없는 오류가 발생했습니다.")
                        }
                    }
                }
            } catch {
                print("Achievement Rate JSON 파싱 중 에러 발생: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "데이터 파싱 오류: \(error.localizedDescription)")
                }
            }
        }

        task.resume()
    }

    func constructAchievementRateURL() -> URL? {
        let baseURL = "http://34.47.127.47:8080/record/rate"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = dateFormatter.string(from: Date())

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "userName", value: userName),
            URLQueryItem(name: "date", value: todayDateString)
        ]

        return components?.url
    }

    // 음식 추천 가져오기
    func fetchFoodRecommendations() {
        guard let url = constructRecommendationURL() else {
            print("유효한 URL을 생성할 수 없습니다.")
            return
        }

        print("Food Recommendation 요청 URL: \(url.absoluteString)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 에러 처리
            if let error = error {
                print("Food Recommendation 요청 중 에러 발생: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "네트워크 오류: \(error.localizedDescription)")
                }
                return
            }

            // 응답 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("Food Recommendation 서버 응답 상태 코드: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    print("Food Recommendation 서버 응답 오류")
                    DispatchQueue.main.async {
                        self.showUnknownErrorAlert(message: "서버 응답 오류: \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            // 데이터 존재 여부 확인
            guard let data = data else {
                print("Food Recommendation 응답 데이터가 없습니다.")
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "응답 데이터가 없습니다.")
                }
                return
            }

            // 데이터 출력 (원시 데이터)
            if let rawData = String(data: data, encoding: .utf8) {
                print("Food Recommendation 응답 데이터: \(rawData)")
            }

            // JSON 파싱
            do {
                let decoder = JSONDecoder()
                let recommendResponse = try decoder.decode(ResponseDto<RecommendResponseContainer>.self, from: data)
                if recommendResponse.success, let recommendations = recommendResponse.responseDto?.recommendDtoList {
                    self.foodRecommendations = recommendations
                    // 랜덤으로 3개의 추천 음식 선택
                    self.displayedRecommendations = Array(recommendations.shuffled().prefix(3))
                    DispatchQueue.main.async {
                        self.updateAnalysisView()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showUnknownErrorAlert(message: "알 수 없는 오류가 발생했습니다.")
                    }
                }
            } catch {
                print("Food Recommendation JSON 파싱 중 에러 발생: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "데이터 파싱 오류: \(error.localizedDescription)")
                }
            }
        }

        task.resume()
    }

    func constructRecommendationURL() -> URL? {
        let baseURL = "http://34.47.127.47:8080/record/recommend"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = dateFormatter.string(from: Date())

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "userName", value: userName),
            URLQueryItem(name: "date", value: todayDateString)
        ]

        return components?.url
    }

    // MARK: - Data Processing

    func processFetchedRecords(_ records: [RecordResponse]) {
        self.recordList = records
        self.recordCollectionView.reloadData()

        // 칼로리 및 영양소 합산
        var totalConsumedCalories: Double = 0
        var totalCarbs: Double = 0
        var totalProtein: Double = 0
        var totalFat: Double = 0

        for record in records {
            let intake = record.intakeAmount ?? 1 // intakeAmount이 없으면 1로 간주
            totalConsumedCalories += record.calories * Double(intake)
            totalCarbs += record.carbs * Double(intake)
            totalProtein += record.protein * Double(intake)
            totalFat += record.fat * Double(intake)
        }

        self.consumedCalories = CGFloat(totalConsumedCalories)
        self.nutritionDetails = (carbs: totalCarbs, protein: totalProtein, fat: totalFat)

        // UI 업데이트
        updateCalorieProgress()
        updateNutritionLabels()
        updateAnalysisView()
    }

    // MARK: - UI Updates

    func updateCalorieProgress() {
        let progress = consumedCalories / totalCalories
        progressCircle.strokeEnd = progress > 1 ? 1 : progress

        if let centerLabel = nutritionView.viewWithTag(100) as? UILabel {
            centerLabel.text = "\(Int(consumedCalories))/\(Int(totalCalories)) kcal"
        }
    }

    func updateNutritionLabels() {
        let nutritionValues = [
            "탄수화물: \(Int(nutritionDetails.carbs))g",
            "단백질: \(Int(nutritionDetails.protein))g",
            "지방: \(Int(nutritionDetails.fat))g"
        ]

        for (index, value) in nutritionValues.enumerated() {
            if let valueLabel = nutritionView.viewWithTag(200 + index) as? UILabel {
                valueLabel.text = value
            }
        }
    }

    func updateAnalysisView() {
        // 기존의 서브뷰 제거
        analysisScrollView.removeFromSuperview()
        analysisView.subviews.forEach { $0.removeFromSuperview() }

        analysisScrollView.translatesAutoresizingMaskIntoConstraints = false
        analysisView.addSubview(analysisScrollView)

        NSLayoutConstraint.activate([
            analysisScrollView.topAnchor.constraint(equalTo: analysisView.topAnchor),
            analysisScrollView.leadingAnchor.constraint(equalTo: analysisView.leadingAnchor),
            analysisScrollView.trailingAnchor.constraint(equalTo: analysisView.trailingAnchor),
            analysisScrollView.bottomAnchor.constraint(equalTo: analysisView.bottomAnchor)
        ])

        analysisContentView.translatesAutoresizingMaskIntoConstraints = false
        analysisScrollView.addSubview(analysisContentView)

        NSLayoutConstraint.activate([
            analysisContentView.topAnchor.constraint(equalTo: analysisScrollView.topAnchor),
            analysisContentView.leadingAnchor.constraint(equalTo: analysisScrollView.leadingAnchor),
            analysisContentView.trailingAnchor.constraint(equalTo: analysisScrollView.trailingAnchor),
            analysisContentView.bottomAnchor.constraint(equalTo: analysisScrollView.bottomAnchor),
            analysisContentView.widthAnchor.constraint(equalTo: analysisScrollView.widthAnchor)
        ])

        var previousView: UIView?

        // 달성률 표시
        if let rates = achievementRates {
            let rateText = """
            탄수화물 달성률: \(String(format: "%.1f", rates.rateCarb))%
            단백질 달성률: \(String(format: "%.1f", rates.rateProtein))%
            지방 달성률: \(String(format: "%.1f", rates.rateFat))%
            """
            let rateLabel = UILabel()
            rateLabel.numberOfLines = 0
            rateLabel.font = UIFont.systemFont(ofSize: 14)
            rateLabel.text = rateText
            rateLabel.translatesAutoresizingMaskIntoConstraints = false
            analysisContentView.addSubview(rateLabel)

            NSLayoutConstraint.activate([
                rateLabel.topAnchor.constraint(equalTo: analysisContentView.topAnchor, constant: 16),
                rateLabel.leadingAnchor.constraint(equalTo: analysisContentView.leadingAnchor, constant: 16),
                rateLabel.trailingAnchor.constraint(equalTo: analysisContentView.trailingAnchor, constant: -16)
            ])

            previousView = rateLabel
        }

        // 음식 추천 표시
        if !displayedRecommendations.isEmpty {
            let recommendationTitleLabel = UILabel()
            recommendationTitleLabel.text = "음식 추천"
            recommendationTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            recommendationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            analysisContentView.addSubview(recommendationTitleLabel)

            NSLayoutConstraint.activate([
                recommendationTitleLabel.topAnchor.constraint(equalTo: previousView?.bottomAnchor ?? analysisContentView.topAnchor, constant: 16),
                recommendationTitleLabel.leadingAnchor.constraint(equalTo: analysisContentView.leadingAnchor, constant: 16)
            ])

            // 새로고침 버튼
            let refreshButton = UIButton(type: .system)
            refreshButton.setTitle("새로고침", for: .normal)
            refreshButton.addTarget(self, action: #selector(refreshRecommendations), for: .touchUpInside)
            refreshButton.translatesAutoresizingMaskIntoConstraints = false
            analysisContentView.addSubview(refreshButton)

            NSLayoutConstraint.activate([
                refreshButton.centerYAnchor.constraint(equalTo: recommendationTitleLabel.centerYAnchor),
                refreshButton.trailingAnchor.constraint(equalTo: analysisContentView.trailingAnchor, constant: -16)
            ])

            previousView = recommendationTitleLabel

            for recommendation in displayedRecommendations {
                let foodLabel = UILabel()
                foodLabel.numberOfLines = 0
                foodLabel.font = UIFont.systemFont(ofSize: 14)
                foodLabel.text = """
                음식명: \(recommendation.foodName)
                칼로리: \(Int(recommendation.calories)) kcal
                탄수화물: \(Int(recommendation.carbs))g, 단백질: \(Int(recommendation.protein))g, 지방: \(Int(recommendation.fat))g
                """
                foodLabel.translatesAutoresizingMaskIntoConstraints = false
                analysisContentView.addSubview(foodLabel)

                NSLayoutConstraint.activate([
                    foodLabel.topAnchor.constraint(equalTo: previousView!.bottomAnchor, constant: 16),
                    foodLabel.leadingAnchor.constraint(equalTo: analysisContentView.leadingAnchor, constant: 16),
                    foodLabel.trailingAnchor.constraint(equalTo: analysisContentView.trailingAnchor, constant: -16)
                ])

                previousView = foodLabel
            }
        }

        // 마지막 뷰의 하단을 contentView의 하단에 고정
        if let lastView = previousView {
            NSLayoutConstraint.activate([
                lastView.bottomAnchor.constraint(equalTo: analysisContentView.bottomAnchor, constant: -16)
            ])
        }
    }

    @objc func refreshRecommendations() {
        if !foodRecommendations.isEmpty {
            displayedRecommendations = Array(foodRecommendations.shuffled().prefix(3))
            updateAnalysisView()
        }
    }

    // MARK: - Error Handling

    func showUnknownErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordCell", for: indexPath) as? RecordCell else {
            return UICollectionViewCell()
        }
        let record = recordList[indexPath.item]
        let intake = record.intakeAmount ?? 1 // intakeAmount이 없으면 1로 간주
        let calories = Int(record.calories * Double(intake))
        cell.configure(name: record.mealtime, mealTime: record.mealtime, calories: "\(calories) kcal")
        return cell
    }
}

// MARK: - UIImagePickerController Delegate

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // 이미지를 선택했을 때 호출되는 델리게이트 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                self.showFoodOptionSelectorForAlbum(image: image)
            }
        }
    }

    // 이미지 선택을 취소했을 때 호출되는 델리게이트 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - RecordCell

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

// MARK: - FoodType Enum

enum FoodType: String {
    case singleFood = "단일 음식"
    case multiFood = "다중 음식"
}

// MARK: - Preview

#Preview {
    MainViewController()
}
