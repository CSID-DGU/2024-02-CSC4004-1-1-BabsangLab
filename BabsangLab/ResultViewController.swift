import UIKit

class ResultViewController: UIViewController {
    var selectedImage: UIImage?
    var selectedFoodType: FoodType? 
    let foodTypeLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .large)

    // URL 설정: 단일 음식과 다중 음식 예측용
    let singlePredictURL = "https://foodclassificationproject.du.r.appspot.com/predict"
    let multiPredictURL = "https://foodclassificationproject.du.r.appspot.com/multi_predict"

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
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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

        var imageData: Data?
        if let resizedImage = resizeImage(image, targetSize: CGSize(width: 299, height: 299)) {
            imageData = resizedImage.jpegData(compressionQuality: 0.8)
        }

        guard let imageData = imageData else {
            foodTypeLabel.text = "이미지 데이터를 처리할 수 없습니다."
            return
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
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
        if forMultipleFoods {
            // 다중 음식 처리: 각 크롭된 이미지의 상위 1개 예측만 표시
            if let predictions = json["predictions"] as? [[String: Any]] {
                let results = predictions.compactMap { prediction -> String? in
                    guard let foodName = prediction["class"] as? String else { return nil }
                    return foodName
                }
                foodTypeLabel.text = "다중 음식 예측 결과: \(results.joined(separator: ", "))"
            } else {
                foodTypeLabel.text = "다중 음식 예측 결과를 처리할 수 없습니다."
            }
        } else {
            // 단일 음식 처리
            if let topPrediction = json["prediction"] as? [String: String],
               let foodName = topPrediction["class"],
               let confidence = topPrediction["confidence"] {
                // 신뢰도가 80% 이상일 때, 상위 1개 결과 출력
                foodTypeLabel.text = "예측 결과: \(foodName) (\(confidence))"
            } else if let top3 = json["top_3"] as? [[String: String]] {
                // 신뢰도가 80% 미만일 때, 상위 3개 결과 선택받기
                let options = top3.compactMap { $0["class"] }
                showTop3Selection(options: options)
            } else {
                foodTypeLabel.text = "예측 결과를 처리할 수 없습니다."
            }
        }
    }


    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = CGSize(
            width: size.width * min(widthRatio, heightRatio),
            height: size.height * min(widthRatio, heightRatio)
        )
        let rect = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func showTop3Selection(options: [String]) {
        let alert = UIAlertController(title: "예측 결과", message: "결과 중 하나를 선택하세요.", preferredStyle: .actionSheet)
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { _ in
                self.foodTypeLabel.text = "선택한 음식: \(option)"
            }))
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

