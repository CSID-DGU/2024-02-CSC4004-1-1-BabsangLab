import UIKit

class UserInfoViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIStackView()
    let titleLabel = UILabel()
    let startButton = UIButton(type: .system)

    var textFields: [UITextField] = []
    var errorLabels: [UILabel] = []
    var weightGoalSegmentedControl: UISegmentedControl? // 추가된 부분

    // SignupViewController에서 전달받는 데이터
    var userId: String = ""
    var password: String = ""

    let keys = ["name", "age", "gender", "height", "weight", "med_history", "allergy"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupScrollView()
        setupContentView()
        setupTitleLabel()
        setupFormFields()
        setupStartButton()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setupContentView() {
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.alignment = .fill
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    func setupTitleLabel() {
        titleLabel.text = "사용자 정보 입력"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .systemGreen
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addArrangedSubview(titleLabel)
    }

    func setupFormFields() {
        addSection(title: "이름", placeholder: "이름을 입력하세요 (예: 홍길동)")
        addSection(title: "나이", placeholder: "나이를 입력하세요 (예: 22)")

        // 성별 선택
        addSegmentedControlSection(title: "성별", items: ["남성", "여성"], defaultIndex: 0)

        addSection(title: "키", placeholder: "키를 입력하세요 (예: 170)")
        addSection(title: "체중", placeholder: "체중을 입력하세요 (예: 70)")

        addSection(title: "병력", placeholder: "병력 사항을 입력하세요")
        addSection(title: "알레르기", placeholder: "알레르기 정보를 입력하세요")

        // 체중 관리 목표 추가
        addWeightGoalSection()
    }

    func addWeightGoalSection() {
        let weightGoalLabel = createTitleLabel(text: "체중 관리")
        contentView.addArrangedSubview(weightGoalLabel)

        weightGoalSegmentedControl = UISegmentedControl(items: ["감량", "유지", "증량"])
        weightGoalSegmentedControl?.selectedSegmentIndex = 0
        weightGoalSegmentedControl?.translatesAutoresizingMaskIntoConstraints = false
        weightGoalSegmentedControl?.addTarget(self, action: #selector(validateForm), for: .valueChanged)
        contentView.addArrangedSubview(weightGoalSegmentedControl!)
    }

    func addSection(title: String, placeholder: String) {
        let label = createTitleLabel(text: title)
        let textField = createTextField(placeholder: placeholder)
        let errorLabel = createErrorLabel()

        textFields.append(textField)
        errorLabels.append(errorLabel)

        contentView.addArrangedSubview(label)
        contentView.addArrangedSubview(textField)
        contentView.addArrangedSubview(errorLabel)
    }

    func addSegmentedControlSection(title: String, items: [String], defaultIndex: Int) {
        let label = createTitleLabel(text: title)
        contentView.addArrangedSubview(label)

        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = defaultIndex
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addArrangedSubview(segmentedControl)
    }

    func setupStartButton() {
        startButton.setTitle("등록하기", for: .normal)
        startButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        startButton.backgroundColor = UIColor.lightGray
        startButton.setTitleColor(UIColor.white, for: .normal)
        startButton.layer.cornerRadius = 12
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.isEnabled = false
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        contentView.addArrangedSubview(startButton)
    }

    func createErrorLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.red
        label.font = UIFont.systemFont(ofSize: 12)
        label.isHidden = true
        return label
    }

    func createTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false

        let underline = UIView()
        underline.backgroundColor = .lightGray
        underline.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(underline)

        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 0.3),
            underline.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 7)
        ])

        textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        return textField
    }

    @objc func validateForm() {
        var isValid = true

        for (index, textField) in textFields.enumerated() {
            if textField.text?.isEmpty == true {
                errorLabels[index].text = "이 필드를 입력해주세요."
                errorLabels[index].isHidden = false
                isValid = false
            } else {
                errorLabels[index].isHidden = true
            }
        }

        startButton.isEnabled = isValid
        startButton.backgroundColor = isValid ? .systemGreen : .lightGray
    }
    
    func navigateToMainScreen() {
        DispatchQueue.main.async {
            let mainTabBarController = MainTabBarController()
            mainTabBarController.modalPresentationStyle = .fullScreen
            self.present(mainTabBarController, animated: true, completion: nil)
            
        }
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default))
        present(alertController, animated: true)
    }

    @objc func startButtonTapped() {
        // 성별 선택값 가져오기
        let genderSegmentedControl = contentView.arrangedSubviews.compactMap { $0 as? UISegmentedControl }.first
        let gender = (genderSegmentedControl?.selectedSegmentIndex == 0) ? "MALE" : "FEMALE"

        // 체중 목표 선택값 가져오기
        var weightGoal = "MAINTAIN"
        if let selectedIndex = weightGoalSegmentedControl?.selectedSegmentIndex {
            switch selectedIndex {
            case 0:
                weightGoal = "lose" // 감량
            case 1:
                weightGoal = "maintain" // 유지
            case 2:
                weightGoal = "gain" // 증량
            default:
                weightGoal = "maintain"
            }
        }

        // 사용자 정보 저장
        UserInfoManager.shared.userId = userId
        UserInfoManager.shared.password = password
        UserInfoManager.shared.name = textFields[0].text ?? ""
        UserInfoManager.shared.age = Int(textFields[1].text ?? "") ?? 0
        UserInfoManager.shared.gender = gender
        UserInfoManager.shared.height = Double(textFields[2].text ?? "") ?? 0.0
        UserInfoManager.shared.weight = Double(textFields[3].text ?? "") ?? 0.0
        UserInfoManager.shared.medHistory = textFields[4].text ?? ""
        UserInfoManager.shared.allergy = textFields[5].text ?? ""
        UserInfoManager.shared.weightGoal = weightGoal // 추가된 부분

        // 서버로 보낼 요청 바디 생성
        let requestBody: [String: Any] = [
            "userId": userId,
            "password": password,
            "name": UserInfoManager.shared.name ?? "",
            "age": UserInfoManager.shared.age ?? 0,
            "gender": UserInfoManager.shared.gender ?? "MALE",
            "height": UserInfoManager.shared.height ?? 0.0,
            "weight": UserInfoManager.shared.weight ?? 0.0,
            "med_history": UserInfoManager.shared.medHistory ?? "",
            "allergy": UserInfoManager.shared.allergy ?? "",
            "weight_goal": UserInfoManager.shared.weightGoal ?? "maintain" // 추가된 부분
        ]
        
        print("Request Body: \(requestBody)")

        guard let url = URL(string: "http://34.64.172.57:8080/user/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }
            print(String(data: data, encoding: .utf8) ?? "No response")

            
            self.navigateToMainScreen()
            // 회원가입 성공 시 메인 화면으로 이동 등 추가 처리 가능

        }.resume()
    }
}

#Preview {
    UserInfoViewController()
}

