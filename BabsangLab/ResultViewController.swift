import UIKit

class ResultViewController: UIViewController {
    var selectedImage: UIImage?
    var selectedFoodType: FoodType?
    let foodTypeLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let nutrientInfoLabel = UILabel() // 영양소 정보를 표시할 레이블

    // 서버 URL 설정
    let singlePredictURL = "https://foodclassificationproject.du.r.appspot.com/predict"
    let multiPredictURL = "https://foodclassificationproject.du.r.appspot.com/multi_predict"
    let analysisURL = "http://34.47.127.47:8080/analysis"

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
        view.addSubview(foodTypeLabel)

        nutrientInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        nutrientInfoLabel.textAlignment = .center
        nutrientInfoLabel.font = UIFont.systemFont(ofSize: 14)
        nutrientInfoLabel.textColor = .black
        nutrientInfoLabel.numberOfLines = 0
        view.addSubview(nutrientInfoLabel)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 300),

            foodTypeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            foodTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            activityIndicator.topAnchor.constraint(equalTo: foodTypeLabel.bottomAnchor, constant: 20),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nutrientInfoLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            nutrientInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nutrientInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
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

        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            foodTypeLabel.text = "이미지 데이터를 처리할 수 없습니다."
            return
        }

       
        // Multipart/form-data 형식으로 요청 바디 구성
        var body = Data()
        let filename = "image.jpg"
        let mimeType = "image/jpeg"

        // 문자열을 Data로 변환 후 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData) // 이미지 데이터 추가
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body


        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "예측 중 오류 발생: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "서버 응답 데이터가 없습니다."
                }
                return
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
                }
            } catch {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "JSON 파싱 오류: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    func handlePredictionResponse(json: [String: Any], forMultipleFoods: Bool) {
        if let prediction = json["prediction"] as? [String: Any],
           let foodName = prediction["class"] as? String,
           let confidence = prediction["confidence"] as? Double {
            if confidence >= 80 {
                requestNutrientInfo(foodName: foodName)
            } else if let top3 = json["top_3"] as? [[String: String]] {
                let options = top3.compactMap { $0["class"] }
                showTop3Selection(options: options)
            }
        }
    }

    func showTop3Selection(options: [String]) {
        let alert = UIAlertController(title: "예측 결과", message: "결과 중 하나를 선택하세요.", preferredStyle: .actionSheet)
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { _ in
                self.requestNutrientInfo(foodName: option)
            }))
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func requestNutrientInfo(foodName: String) {
        guard let url = URL(string: "\(analysisURL)?foodName=\(foodName)") else {
            foodTypeLabel.text = "영양소 분석 URL이 잘못되었습니다."
            return
        }

        activityIndicator.startAnimating()
        nutrientInfoLabel.text = ""

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "영양소 분석 중 오류 발생: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "서버 응답 데이터가 없습니다."
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let responseDto = json["ResponseDto"] as? [String: Any],
                   let analysis = responseDto["AnalysisDto"] as? [String: Any] {
                    DispatchQueue.main.async {
                        self?.nutrientInfoLabel.text = """
                        칼로리: \(analysis["calories"] ?? 0)
                        지방: \(analysis["fat"] ?? 0)
                        단백질: \(analysis["protein"] ?? 0)
                        탄수화물: \(analysis["carbs"] ?? 0)
                        알레르기: \(analysis["allergy"] ?? "없음")
                        """
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.foodTypeLabel.text = "영양소 정보를 처리할 수 없습니다."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.foodTypeLabel.text = "JSON 파싱 오류: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

