import UIKit

class UserInfoViewController: UIViewController {
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
        view.backgroundColor = UIColor.white
        setupFixedElements()
        setupScrollView()
        setupContentView()
        setupFormFields()

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setupFixedElements() {
        titleLabel.text = "사용자 정보 입력"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        
        startButton.setTitle("시작하기", for: .normal)
        startButton.backgroundColor = UIColor.lightGray
        startButton.setTitleColor(UIColor.white, for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.isEnabled = false
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),

            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -16)
        ])
    }

    func setupContentView() {
        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.alignment = .fill
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    func setupFormFields() {
   
        addSection(title: "이름", placeholder: "이름을 입력하세요 (예: 홍길동)")
        addSection(title: "나이", placeholder: "나이를 입력하세요 (예: 22)")

      
        let genderLabel = createTitleLabel(text: "성별")
        contentView.addArrangedSubview(genderLabel)
        let genderSegmentedControl = UISegmentedControl(items: ["남성", "여성"])
        genderSegmentedControl.selectedSegmentIndex = 0
        contentView.addArrangedSubview(genderSegmentedControl)

   
        addSection(title: "키", placeholder: "키를 입력하세요 (예: 170)")
        addSection(title: "체중", placeholder: "체중을 입력하세요 (예: 70)")

    
        addSection(title: "병력", placeholder: "병력 사항을 입력하세요")
        addSection(title: "알레르기", placeholder: "알레르기 정보를 입력하세요")
        
        
        let weightGoalLabel = createTitleLabel(text: "체중 관리")
        contentView.addArrangedSubview(weightGoalLabel)
        let weightGoalSegmentedControl = UISegmentedControl(items: ["감량", "유지", "증량"])
        weightGoalSegmentedControl.selectedSegmentIndex = 0
        contentView.addArrangedSubview(weightGoalSegmentedControl)

        let dietGoalsLabel = createTitleLabel(text: "식단 관리 목표")
        contentView.addArrangedSubview(dietGoalsLabel)

        let goals = ["체중 조절", "건강 증진", "근력 강화", "알레르기 예방", "개인 건강 문제(질병 등)", "기타:"]
        for goal in goals {
            if goal == "기타:" {
                let 기타StackView = createCheckBoxWithTextField(goal: goal)
                contentView.addArrangedSubview(기타StackView)
            } else {
                let checkBox = createCheckBox(title: goal)
                contentView.addArrangedSubview(checkBox)
            }
        }
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

    @objc func startButtonTapped() {
        
        let mainTabBarController = MainTabBarController()
               mainTabBarController.modalPresentationStyle = .fullScreen
               present(mainTabBarController, animated: true, completion: nil)
        
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

        if 기타TextField?.isHidden == false && 기타TextField?.text?.isEmpty == true {
            isValid = false
        }

        let isAnyCheckBoxSelected = checkBoxes.contains { $0.title(for: .normal)?.contains("☑️") == true }
        isValid = isValid && isAnyCheckBoxSelected

        startButton.isEnabled = isValid
        startButton.backgroundColor = isValid ? UIColor(red: 0.0, green: 0.6, blue: 0.2, alpha: 1.0) : .lightGray
    }

    func createTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        return textField
    }
}

#Preview {
    UserInfoViewController()
}

