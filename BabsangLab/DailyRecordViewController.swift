import UIKit
import Foundation

// MARK: - DailyRecordViewController

class DailyRecordViewController: UIViewController {

    // MARK: - UI Elements

    let nutritionView = UIView()
    var recordCollectionView: UICollectionView!
    let analysisView = UIView()
    let analysisScrollView = UIScrollView()
    let analysisContentView = UIView()
    // "+" 버튼 제거

    var totalCalories: CGFloat = 2000 // 예시로 2000 kcal로 설정
    var consumedCalories: CGFloat = 0 // 초기값 0으로 설정
    var nutritionDetails: (carbs: Double, protein: Double, fat: Double) = (0, 0, 0)
    var recordList: [RecordResponse] = []

    // 달성률을 위한 변수
    var achievementRates: RateResponseDto?

    // MARK: - User Information
    var userName: String {
        return UserInfoManager.shared.name ?? "defaultUser"
    }

    // 선택된 날짜
    var selectedDate: Date?

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCustomNavigationBar()
        setupNutritionView()
        setupRecordView()
        setupAnalysisView()
        // 음식 추가 버튼 제거
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 데이터 새로고침
        fetchDailyDiet()
        fetchAchievementRates()
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd"
        titleLabel.text = dateFormatter.string(from: selectedDate ?? Date())
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        navigationBarView.addSubview(titleLabel)
        view.addSubview(navigationBarView)

        NSLayoutConstraint.activate([
            navigationBarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            navigationBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBarView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.centerXAnchor.constraint(equalTo: navigationBarView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navigationBarView.centerYAnchor)
        ])
    }

    func setupNutritionView() {
        nutritionView.translatesAutoresizingMaskIntoConstraints = false
        nutritionView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        nutritionView.layer.cornerRadius = 10

        view.addSubview(nutritionView)

        NSLayoutConstraint.activate([
            nutritionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            nutritionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nutritionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nutritionView.heightAnchor.constraint(equalToConstant: 170) // 높이를 늘려 레이블 공간 확보
        ])

        let caloriesProgressView = createCircularProgressView(title: "칼로리", icon: "flame.fill", progress: 0, color: .systemRed, consumedLabelTag: 100)
        let carbsProgressView = createCircularProgressView(title: "탄수화물", icon: "leaf.fill", progress: 0, color: .systemGreen, consumedLabelTag: 101)
        let proteinProgressView = createCircularProgressView(title: "단백질", icon: "bolt.fill", progress: 0, color: .systemOrange, consumedLabelTag: 102)
        let fatProgressView = createCircularProgressView(title: "지방", icon: "drop.fill", progress: 0, color: .systemPurple, consumedLabelTag: 103)

        let progressStackView = UIStackView(arrangedSubviews: [caloriesProgressView, carbsProgressView, proteinProgressView, fatProgressView])
        progressStackView.axis = .horizontal
        progressStackView.distribution = .fillEqually
        progressStackView.spacing = 16
        progressStackView.translatesAutoresizingMaskIntoConstraints = false

        nutritionView.addSubview(progressStackView)

        NSLayoutConstraint.activate([
            progressStackView.topAnchor.constraint(equalTo: nutritionView.topAnchor, constant: 16),
            progressStackView.leadingAnchor.constraint(equalTo: nutritionView.leadingAnchor, constant: 16),
            progressStackView.trailingAnchor.constraint(equalTo: nutritionView.trailingAnchor, constant: -16),
            progressStackView.bottomAnchor.constraint(equalTo: nutritionView.bottomAnchor, constant: -16)
        ])
    }

    func createCircularProgressView(title: String, icon: String, progress: CGFloat, color: UIColor, consumedLabelTag: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView()
        imageView.image = UIImage(systemName: icon)
        imageView.tintColor = color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        let circularProgressView = CircularProgressView()
        circularProgressView.progress = progress
        circularProgressView.progressColor = color
        circularProgressView.trackColor = UIColor.lightGray.withAlphaComponent(0.3)
        circularProgressView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let consumedLabel = UILabel()
        consumedLabel.font = UIFont.systemFont(ofSize: 8.5)
        consumedLabel.textColor = .darkGray
        consumedLabel.textAlignment = .center
        consumedLabel.translatesAutoresizingMaskIntoConstraints = false
        consumedLabel.tag = consumedLabelTag

        container.addSubview(imageView)
        container.addSubview(circularProgressView)
        container.addSubview(titleLabel)
        container.addSubview(consumedLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),

            circularProgressView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            circularProgressView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circularProgressView.widthAnchor.constraint(equalToConstant: 60),
            circularProgressView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: circularProgressView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            consumedLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            consumedLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            consumedLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            consumedLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    func setupRecordView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 160)
        layout.minimumLineSpacing = 16

        recordCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        recordCollectionView.translatesAutoresizingMaskIntoConstraints = false
        recordCollectionView.backgroundColor = .clear
        recordCollectionView.register(RecordCell.self, forCellWithReuseIdentifier: "RecordCell")
        recordCollectionView.dataSource = self
        recordCollectionView.delegate = self

        view.addSubview(recordCollectionView)

        NSLayoutConstraint.activate([
            recordCollectionView.topAnchor.constraint(equalTo: nutritionView.bottomAnchor, constant: 27),
            recordCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recordCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recordCollectionView.heightAnchor.constraint(equalToConstant: 190),
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
            analysisView.topAnchor.constraint(equalTo: recordCollectionView.bottomAnchor, constant: 27),
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

    // "+" 버튼을 제외하고 설정합니다.
    // func setupFloatingButtons() {
    //     // 기존 MainViewController와 동일한 설정
    // }

    // MARK: - Actions

    @objc func showAddOptions() {
        // DailyRecordViewController에서는 "+" 버튼이 없으므로 이 메서드를 제거하거나 비활성화
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
        guard let navigationController = self.navigationController else {
            print("NavigationController가 nil입니다.")
            return
        }
        let resultVC = ResultViewController()
        resultVC.selectedImage = image
        resultVC.selectedFoodType = foodType
        navigationController.pushViewController(resultVC, animated: true)
    }

    // MARK: - Networking

    func fetchDailyDiet() {
        guard let url = constructURL(for: selectedDate ?? Date()) else {
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
            } catch let decodingError as DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("DecodingError.dataCorrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("DecodingError.keyNotFound: key '\(key)' not found, \(context.debugDescription)")
                case .valueNotFound(let value, let context):
                    print("DecodingError.valueNotFound: value '\(value)' not found, \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("DecodingError.typeMismatch: type '\(type)' mismatch, \(context.debugDescription)")
                @unknown default:
                    print("DecodingError: \(decodingError.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "데이터 파싱 오류: \(decodingError.localizedDescription)")
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

    func constructURL(for date: Date) -> URL? {
        let baseURL = "http://34.64.172.57:8080/record/date"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "userName", value: userName),
            URLQueryItem(name: "date", value: dateString)
        ]

        return components?.url
    }

    // 달성률 가져오기
    func fetchAchievementRates() {
        guard let url = constructAchievementRateURL(for: selectedDate ?? Date()) else {
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
                let responseDto = try decoder.decode(ResponseDto<RateResponseDto>.self, from: data)

                if responseDto.success, let rates = responseDto.responseDto {
                    self.achievementRates = rates
                    DispatchQueue.main.async {
                        self.updateCalorieProgress()
                        self.updateAnalysisView()
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
            } catch let decodingError as DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("DecodingError.dataCorrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("DecodingError.keyNotFound: key '\(key)' not found, \(context.debugDescription)")
                case .valueNotFound(let value, let context):
                    print("DecodingError.valueNotFound: value '\(value)' not found, \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("DecodingError.typeMismatch: type '\(type)' mismatch, \(context.debugDescription)")
                @unknown default:
                    print("DecodingError: \(decodingError.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.showUnknownErrorAlert(message: "데이터 파싱 오류: \(decodingError.localizedDescription)")
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

    func constructAchievementRateURL(for date: Date) -> URL? {
        let baseURL = "http://34.64.172.57:8080/record/rate"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "userName", value: userName),
            URLQueryItem(name: "date", value: dateString)
        ]

        return components?.url
    }

    // MARK: - Data Processing

    func processFetchedRecords(_ records: [RecordResponse]) {
        self.recordList = records
        self.recordCollectionView.reloadData()

        // 칼로리 및 영양소 합산 (intakeAmount 중복 계산 제거)
        var totalConsumedCalories: Double = 0
        var totalCarbs: Double = 0
        var totalProtein: Double = 0
        var totalFat: Double = 0

        for record in records {
            // intakeAmount을 곱지 않음
            totalConsumedCalories += record.calories
            totalCarbs += record.carbs
            totalProtein += record.protein
            totalFat += record.fat
        }

        self.consumedCalories = CGFloat(totalConsumedCalories)
        self.nutritionDetails = (carbs: totalCarbs, protein: totalProtein, fat: totalFat)

        // UI 업데이트
        updateCalorieProgress()
        updateAnalysisView()
    }

    // MARK: - UI Updates

    func updateCalorieProgress() {
        // Update the progress for each circular progress view
        if let progressStackView = nutritionView.subviews.compactMap({ $0 as? UIStackView }).first,
           progressStackView.arrangedSubviews.count >= 4,
           let rates = achievementRates {

            let caloriesContainer = progressStackView.arrangedSubviews[0]
            let carbsContainer = progressStackView.arrangedSubviews[1]
            let proteinContainer = progressStackView.arrangedSubviews[2]
            let fatContainer = progressStackView.arrangedSubviews[3]

            if let caloriesProgressView = caloriesContainer.subviews.compactMap({ $0 as? CircularProgressView }).first,
               let carbsProgressView = carbsContainer.subviews.compactMap({ $0 as? CircularProgressView }).first,
               let proteinProgressView = proteinContainer.subviews.compactMap({ $0 as? CircularProgressView }).first,
               let fatProgressView = fatContainer.subviews.compactMap({ $0 as? CircularProgressView }).first {

                // 달성률이 0보다 클 때만 계산
                guard rates.rateCalories > 0, rates.rateCarbs > 0, rates.rateProtein > 0, rates.rateFat > 0 else {
                    // 달성률이 0인 경우 처리 (예: 목표가 설정되지 않음)
                    print("달성률이 0입니다.")
                    return
                }

                // 목표값 계산
                let targetCalories = consumedCalories / CGFloat(rates.rateCalories)
                let targetCarbs = CGFloat(nutritionDetails.carbs) / CGFloat(rates.rateCarbs)
                let targetProtein = CGFloat(nutritionDetails.protein) / CGFloat(rates.rateProtein)
                let targetFat = CGFloat(nutritionDetails.fat) / CGFloat(rates.rateFat)

                // 프로그레스 뷰에 달성률 설정
                let caloriesProgress = CGFloat(rates.rateCalories) // 예: 0.6 -> 60%
                caloriesProgressView.setProgress(to: caloriesProgress, animated: true)

                let carbsProgress = CGFloat(rates.rateCarbs)
                carbsProgressView.setProgress(to: carbsProgress, animated: true)

                let proteinProgress = CGFloat(rates.rateProtein)
                proteinProgressView.setProgress(to: proteinProgress, animated: true)

                let fatProgress = CGFloat(rates.rateFat)
                fatProgressView.setProgress(to: fatProgress, animated: true)

                // "소비/목표" 레이블 업데이트
                if let caloriesLabel = caloriesContainer.viewWithTag(100) as? UILabel {
                    caloriesLabel.text = "\(Int(consumedCalories))/\(Int(targetCalories)) kcal"
                }

                if let carbsLabel = carbsContainer.viewWithTag(101) as? UILabel {
                    carbsLabel.text = "\(Int(nutritionDetails.carbs))/\(Int(targetCarbs)) g"
                }

                if let proteinLabel = proteinContainer.viewWithTag(102) as? UILabel {
                    proteinLabel.text = "\(Int(nutritionDetails.protein))/\(Int(targetProtein)) g"
                }

                if let fatLabel = fatContainer.viewWithTag(103) as? UILabel {
                    fatLabel.text = "\(Int(nutritionDetails.fat))/\(Int(targetFat)) g"
                }
            }
        }
    }

    func updateAnalysisView() {
        // Remove all subviews from analysisContentView
        analysisContentView.subviews.forEach { $0.removeFromSuperview() }

        var previousView: UIView?

        // 식단 분석 섹션 추가
        if let rates = achievementRates {
            // "식단 분석" 제목과 이미지 추가
            let dietAnalysisTitleStack = UIStackView()
            dietAnalysisTitleStack.axis = .horizontal
            dietAnalysisTitleStack.spacing = 8
            dietAnalysisTitleStack.alignment = .center
            dietAnalysisTitleStack.translatesAutoresizingMaskIntoConstraints = false

            let dietAnalysisEmojiLabel = UILabel()
            dietAnalysisEmojiLabel.text = "📊"
            dietAnalysisEmojiLabel.font = UIFont.systemFont(ofSize: 24)

            let dietAnalysisTitleLabel = UILabel()
            dietAnalysisTitleLabel.text = "식단 분석"
            dietAnalysisTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            dietAnalysisTitleLabel.translatesAutoresizingMaskIntoConstraints = false

            dietAnalysisTitleStack.addArrangedSubview(dietAnalysisEmojiLabel)
            dietAnalysisTitleStack.addArrangedSubview(dietAnalysisTitleLabel)

            analysisContentView.addSubview(dietAnalysisTitleStack)

            NSLayoutConstraint.activate([
                dietAnalysisTitleStack.topAnchor.constraint(equalTo: analysisContentView.topAnchor, constant: 16),
                dietAnalysisTitleStack.leadingAnchor.constraint(equalTo: analysisContentView.leadingAnchor, constant: 16)
            ])

            previousView = dietAnalysisTitleStack

            // 영양소 상태 메시지 추가
            let messages = generateNutrientMessages()

            let messagesStackView = UIStackView()
            messagesStackView.axis = .vertical
            messagesStackView.spacing = 8
            messagesStackView.translatesAutoresizingMaskIntoConstraints = false

            for message in messages {
                let messageLabel = UILabel()
                messageLabel.text = message
                messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                messageLabel.textColor = .black
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = .left
                messagesStackView.addArrangedSubview(messageLabel)
            }

            analysisContentView.addSubview(messagesStackView)

            NSLayoutConstraint.activate([
                messagesStackView.topAnchor.constraint(equalTo: previousView!.bottomAnchor, constant: 8),
                messagesStackView.leadingAnchor.constraint(equalTo: analysisContentView.leadingAnchor, constant: 16),
                messagesStackView.trailingAnchor.constraint(equalTo: analysisContentView.trailingAnchor, constant: -16)
            ])

            previousView = messagesStackView
        }

        // 음식 추천 섹션 제외

        // 마지막 뷰의 하단을 contentView의 하단에 고정
        if let lastView = previousView {
            NSLayoutConstraint.activate([
                lastView.bottomAnchor.constraint(equalTo: analysisContentView.bottomAnchor, constant: -16)
            ])
        }
    }

    // MARK: - Error Handling

    func showUnknownErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Generate Nutrient Messages

    func generateNutrientMessages() -> [String] {
        var messages = [String]()
        if let rates = achievementRates {
            if rates.rateCalories < 1 {
                messages.append("칼로리가 부족해요 🔥")
            } else if rates.rateCalories < 1.2 {
                messages.append("칼로리가 적당히 섭취되었어요 🍎")
            } else {
                messages.append("칼로리가 초과되었어요 😓")
            }

            if rates.rateCarbs < 1 {
                messages.append("탄수화물이 부족해요 🍞")
            } else if rates.rateCarbs < 1.2 {
                messages.append("탄수화물이 적당히 섭취되었어요 🌾")
            } else {
                messages.append("탄수화물이 초과되었어요 🥖")
            }

            if rates.rateProtein < 1 {
                messages.append("단백질이 부족해요 🍗")
            } else if rates.rateProtein < 1.2 {
                messages.append("단백질이 적당히 섭취되었어요 💪")
            } else {
                messages.append("단백질이 초과되었어요 🥩")
            }

            if rates.rateFat < 1 {
                messages.append("지방이 부족해요 🥑")
            } else if rates.rateFat < 1.2 {
                messages.append("지방이 적당히 섭취되었어요 🥥")
            } else {
                messages.append("지방이 초과되었어요 🍔")
            }
        }
        return messages
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension DailyRecordViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // 섹션의 아이템 개수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordList.count
    }

    // 각 아이템에 대한 셀 반환
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordCell", for: indexPath) as? RecordCell else {
            return UICollectionViewCell()
        }
        let record = recordList[indexPath.item]
        // intakeAmount을 더 이상 곱하지 않음
        let calories = Int(record.calories)
        cell.configure(name: record.foodName, mealTime: mealTimeKorean(from: record.mealtime), calories: "\(calories) kcal")
        return cell
    }

    // 아이템 크기 설정 (필요시)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 160)
    }

    // 섹션 인셋 설정 (필요시)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    // 셀 선택 시 동작 (필요시)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 예: 상세 정보 보기
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    // 식사 시간을 한글로 변환하는 메서드
    func mealTimeKorean(from mealTime: String?) -> String {
        guard let mealTime = mealTime else { return "알 수 없음" }
        switch mealTime.lowercased() {
        case "breakfast":
            return "아침"
        case "lunch":
            return "점심"
        case "dinner":
            return "저녁"
        default:
            return "알 수 없음"
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension DailyRecordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

