import UIKit

class LoginViewController: UIViewController {

    // 로고 이미지 뷰
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Lunchbox")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // 타이틀 레이블
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "밥상연구소"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 아이디 입력 필드
    let idTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "아이디를 입력하세요"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        textField.textColor = .black
        textField.layer.cornerRadius = 5
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    // 비밀번호 입력 필드
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력하세요"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        textField.textColor = .black
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 5
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    // 로그인 버튼
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // 계정 생성 레이블
    let signupLabel: UILabel = {
        let label = UILabel()
        label.text = "계정이 없으신가요?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .light
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(openSignupPage))
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(tapGesture2)

        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(idTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signupLabel)

        setupConstraints()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func handleLogin() {
        let mainTabBarController = MainTabBarController()
        mainTabBarController.modalPresentationStyle = .fullScreen
        self.present(mainTabBarController, animated: true, completion: nil)
        
        /*guard let userId = idTextField.text, !userId.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "오류", message: "아이디와 비밀번호를 입력하세요.")
            return
        }

        let urlString = "http://34.64.172.57:8080/user/login"
        guard let url = URL(string: urlString) else {
            showAlert(title: "오류", message: "잘못된 URL입니다.")
            return
        }

        let requestBody: [String: String] = [
            "id": userId,
            "password": password
        ]
        
        print("요청 데이터: \(requestBody)") // 요청 데이터 확인용

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            showAlert(title: "오류", message: "요청 데이터를 생성할 수 없습니다.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "오류", message: "네트워크 오류: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    self.showAlert(title: "오류", message: "서버 오류가 발생했습니다.")
                    return
                }
                
                print("서버 응답 코드: \(httpResponse.statusCode)") // 서버 응답 코드 확인
                print("서버 응답 데이터: \(String(data: data, encoding: .utf8) ?? "No Response")") // 서버 응답 데이터 확인
                
                if httpResponse.statusCode == 200 {
                    do {
                        let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        print("로그인 성공: \(responseObject ?? [:])")

                        // 로그인 성공 시 메인 화면으로 전환
                        let mainTabBarController = MainTabBarController()
                        mainTabBarController.modalPresentationStyle = .fullScreen
                        self.present(mainTabBarController, animated: true, completion: nil)
                    } catch {
                        self.showAlert(title: "오류", message: "응답 데이터를 처리할 수 없습니다.")
                    }
                } else {
                    self.showAlert(title: "오류", message: "서버 오류가 발생했습니다.")
                }
            }
        }.resume()*/
    }

    @objc func openSignupPage() {
        let signupVC = SignupViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // 로고 이미지 뷰
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -155),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),

            // 타이틀 레이블
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // 아이디 입력 필드
            idTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            idTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            idTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            idTextField.heightAnchor.constraint(equalToConstant: 50),

            // 비밀번호 입력 필드
            passwordTextField.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            // 로그인 버튼
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            // 계정 생성 레이블
            signupLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            signupLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

#Preview {
    LoginViewController()
}

