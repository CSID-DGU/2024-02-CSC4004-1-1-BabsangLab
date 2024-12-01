import UIKit

class EditUserInfoViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIStackView()
    let titleLabel = UILabel()
    let startButton = UIButton(type: .system)
    
    var textFields: [UITextField] = []
    var errorLabels: [UILabel] = []
    var 기타TextField: UITextField?
    var checkBoxes: [UIButton] = []

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

        // 체중 관리
        addSegmentedControlSection(title: "체중 관리", items: ["감량", "유지", "증량"], defaultIndex: 1)
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
        startButton.setTitle("수정하기", for: .normal)
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

    func createCheckBox(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("⬜️ \(title)", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(checkBoxTapped(_:)), for: .touchUpInside)
        checkBoxes.append(button)
        return button
    }

    func createCheckBoxWithTextField(goal: String) -> UIStackView {
        let checkBox = createCheckBox(title: goal)
        let textField = createTextField(placeholder: "기타를 입력하세요")
        textField.isHidden = true
        기타TextField = textField

        let stackView = UIStackView(arrangedSubviews: [checkBox, textField])
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
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
        textField.borderStyle = .none // 사각형 박스 제거
        textField.translatesAutoresizingMaskIntoConstraints = false

        // 밑줄 추가
        let underline = UIView()
        underline.backgroundColor = .lightGray
        underline.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(underline)

        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 0.3), // 밑줄 두께
            underline.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 7) // 밑줄 위치
        ])

        textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        return textField
    }

    @objc func checkBoxTapped(_ sender: UIButton) {
        if sender.title(for: .normal)?.contains("☑️") == true {
            sender.setTitle(sender.title(for: .normal)?.replacingOccurrences(of: "☑️", with: "⬜️"), for: .normal)
            if sender.title(for: .normal)?.contains("기타:") == true {
                기타TextField?.isHidden = true
                기타TextField?.text = ""
            }
        } else {
            sender.setTitle(sender.title(for: .normal)?.replacingOccurrences(of: "⬜️", with: "☑️"), for: .normal)
            if sender.title(for: .normal)?.contains("기타:") == true {
                기타TextField?.isHidden = false
            }
        }
        validateForm()
    }

    @objc func validateForm() {
        var isValid = true

        for (index, textField) in textFields.enumerated() {
            if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
                errorLabels[index].text = "이 필드를 입력해주세요."
                errorLabels[index].isHidden = false
                isValid = false
            } else {
                errorLabels[index].isHidden = true
            }
        }

        if let genderSegmentedControl = contentView.arrangedSubviews.compactMap({ $0 as? UISegmentedControl }).first,
           genderSegmentedControl.selectedSegmentIndex == UISegmentedControl.noSegment {
            isValid = false
        }

        if let weightGoalSegmentedControl = contentView.arrangedSubviews.compactMap({ $0 as? UISegmentedControl }).last,
           weightGoalSegmentedControl.selectedSegmentIndex == UISegmentedControl.noSegment {
            isValid = false
        }

        startButton.isEnabled = isValid
        startButton.backgroundColor = isValid ? .systemGreen : .lightGray
    }


    @objc func startButtonTapped() {
        // 성별 선택값 가져오기
        let genderSegmentedControl = contentView.arrangedSubviews.compactMap { $0 as? UISegmentedControl }.first
        let gender = (genderSegmentedControl?.selectedSegmentIndex == 0) ? "MALE" : "FEMALE"

        // 체중 목표 선택값 가져오기
        let weightGoalSegmentedControl = contentView.arrangedSubviews.compactMap { $0 as? UISegmentedControl }.last
        var weightGoal = "maintain"
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

        // 사용자 정보 생성
        let updatedInfo: [String: Any] = [
            "userId": UserInfoManager.shared.userId ?? "",
            "password": UserInfoManager.shared.password ?? "",
            "age": Int(textFields[1].text ?? "") ?? 0,
            "gender": gender,
            "height": Double(textFields[2].text ?? "") ?? 0.0,
            "weight": Double(textFields[3].text ?? "") ?? 0.0,
            "med_history": textFields[4].text ?? "",
            "allergy": textFields[5].text ?? "",
            "weight_goal": weightGoal
        ]

        guard let url = URL(string: "http://http://34.64.172.57:8080/user/update") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updatedInfo, options: [])
        } catch {
            print("JSON Serialization Error: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No Response Data")
                return
            }

            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = responseJSON["success"] as? Bool, success {
                    // 성공적으로 서버에 반영되었으므로 UserInfoManager 업데이트
                    DispatchQueue.main.async {
                        UserInfoManager.shared.age = updatedInfo["age"] as? Int
                        UserInfoManager.shared.gender = updatedInfo["gender"] as? String
                        UserInfoManager.shared.height = updatedInfo["height"] as? Double
                        UserInfoManager.shared.weight = updatedInfo["weight"] as? Double
                        UserInfoManager.shared.medHistory = updatedInfo["med_history"] as? String
                        UserInfoManager.shared.allergy = updatedInfo["allergy"] as? String
                        UserInfoManager.shared.weightGoal = updatedInfo["weight_goal"] as? String

                        // 정보 수정 완료 후 이전 화면으로 돌아가기
                                           self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                    }
                }
            } catch {
            }
        }.resume()
    }

}


#Preview {
    UserInfoViewController()
}


