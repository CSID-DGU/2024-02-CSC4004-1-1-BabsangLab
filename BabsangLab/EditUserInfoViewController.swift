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

        // 식단 목표
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
        startButton.backgroundColor = isValid ? .systemGreen : .lightGray
    }

    @objc func startButtonTapped() {
        // 시작 버튼 로직
        print("정보 입력 완료")
    }
}


#Preview {
    UserInfoViewController()
}


