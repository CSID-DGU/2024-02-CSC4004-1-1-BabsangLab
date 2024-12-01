import UIKit

class SignupViewController: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let idTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "아이디를 입력하세요"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.textColor = .black
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let checkIdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("중복 확인", for: .normal)
        button.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.2, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let duplicateCheckLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.red
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력하세요"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.textColor = .black
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호 확인"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.textColor = .black
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호가 일치하지 않습니다."
        label.textColor = UIColor.red
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    var isIdChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(titleLabel)
        view.addSubview(idTextField)
        view.addSubview(checkIdButton)
        view.addSubview(duplicateCheckLabel)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(passwordErrorLabel)
        view.addSubview(nextButton)
        
        checkIdButton.addTarget(self, action: #selector(checkId), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(navigateToUserInfoViewController), for: .touchUpInside)
        
        setupConstraints()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func checkId() {
        guard let enteredId = idTextField.text, !enteredId.isEmpty else {
            duplicateCheckLabel.text = "아이디를 입력해주세요."
            duplicateCheckLabel.isHidden = false
            isIdChecked = false
            validateForm()
            return
        }
        
        let urlString = "http://34.47.127.47:8080/user/register?userId=\(enteredId)"
        guard let url = URL(string: urlString) else {
            duplicateCheckLabel.text = "잘못된 URL입니다."
            duplicateCheckLabel.isHidden = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.duplicateCheckLabel.text = "네트워크 오류: \(error.localizedDescription)"
                    self.duplicateCheckLabel.textColor = .red
                    self.duplicateCheckLabel.isHidden = false
                    self.isIdChecked = false
                    return
                }
                
                guard let data = data else {
                    self.duplicateCheckLabel.text = "데이터를 받지 못했습니다."
                    self.duplicateCheckLabel.textColor = .red
                    self.duplicateCheckLabel.isHidden = false
                    self.isIdChecked = false
                    return
                }
                
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let success = response?["success"] as? Bool, success {
                        self.duplicateCheckLabel.text = "사용 가능한 아이디입니다."
                        self.duplicateCheckLabel.textColor = .green
                        self.duplicateCheckLabel.isHidden = false
                        self.isIdChecked = true
                    } else {
                        self.duplicateCheckLabel.text = "이미 사용 중인 아이디입니다."
                        self.duplicateCheckLabel.textColor = .red
                        self.duplicateCheckLabel.isHidden = false
                        self.isIdChecked = false
                    }
                } catch {
                    self.duplicateCheckLabel.text = "응답 처리 오류: \(error.localizedDescription)"
                    self.duplicateCheckLabel.textColor = .red
                    self.duplicateCheckLabel.isHidden = false
                    self.isIdChecked = false
                }
                self.validateForm()
            }
        }
        task.resume()
    }
    
    @objc func validateForm() {
        let isPasswordValid = passwordTextField.text == confirmPasswordTextField.text && !(passwordTextField.text?.isEmpty ?? true)
        passwordErrorLabel.isHidden = isPasswordValid
        nextButton.isEnabled = isIdChecked && isPasswordValid
        nextButton.backgroundColor = nextButton.isEnabled ? UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0) : .lightGray
    }
    
    @objc func navigateToUserInfoViewController() {
        let userInfoVC = UserInfoViewController()
        userInfoVC.userId = idTextField.text ?? ""
        userInfoVC.password = passwordTextField.text ?? ""
        navigationController?.pushViewController(userInfoVC, animated: true)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            idTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 80),
            idTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            idTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -140),
            idTextField.heightAnchor.constraint(equalToConstant: 45),
            
            checkIdButton.centerYAnchor.constraint(equalTo: idTextField.centerYAnchor),
            checkIdButton.leadingAnchor.constraint(equalTo: idTextField.trailingAnchor, constant: 10),
            checkIdButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            checkIdButton.heightAnchor.constraint(equalToConstant: 45),
            
            duplicateCheckLabel.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: 8),
            duplicateCheckLabel.leadingAnchor.constraint(equalTo: idTextField.leadingAnchor),
            duplicateCheckLabel.trailingAnchor.constraint(equalTo: idTextField.trailingAnchor),
            
            passwordTextField.topAnchor.constraint(equalTo: duplicateCheckLabel.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 45),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 45),
            
            passwordErrorLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 8),
            passwordErrorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 100),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}



#Preview {
    SignupViewController()
}
