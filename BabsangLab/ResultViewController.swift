import UIKit

class ResultViewController: UIViewController {
    var selectedImage: UIImage? // 이미지 저장을 위한 프로퍼티 추가
    var selectedFoodType: FoodType? // FoodType을 받을 수 있도록 설정

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupResultUI()
    }

    func setupResultUI() {
        // 이미지 표시
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        // 선택된 이미지가 있으면 이미지뷰에 표시
        if let image = selectedImage {
            imageView.image = image
        }

        // 선택된 음식 종류 표시
        let foodTypeLabel = UILabel()
        foodTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        foodTypeLabel.textAlignment = .center
        foodTypeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        foodTypeLabel.textColor = .darkGray
        view.addSubview(foodTypeLabel)

        // FoodType 값이 있는 경우 해당 내용을 표시
        if let selectedFoodType = selectedFoodType {
            foodTypeLabel.text = "선택된 음식 종류: \(selectedFoodType.rawValue)"
        } else {
            foodTypeLabel.text = "음식 종류가 선택되지 않았습니다."
        }

        // 제약 조건 추가
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 300),

            foodTypeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            foodTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

