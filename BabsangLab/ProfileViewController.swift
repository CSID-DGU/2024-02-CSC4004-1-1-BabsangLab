import UIKit

class ProfileViewController: UIViewController {

    let scrollView = UIScrollView()
    let contentView = UIStackView()
    let profileHeaderView = UIView()
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let editButton = UIButton(type: .system)

    // 유저 정보 (임시 데이터)
    var userInfo: [String: String] = [
        "나이": "25",
        "성별": "남성",
        "키": "175cm",
        "체중": "70kg",
        "병력": "없음",
        "알레르기": "없음",
        "체중 관리": "유지",
        "식단 목표": "건강 증진, 근력 강화"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "프로필"
        setupScrollView()
        setupContentView()
        setupProfileHeader()
        setupUserInfoCards()
        setupEditButton()
    }

    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

    func setupProfileHeader() {
        profileHeaderView.backgroundColor = .systemGreen
        profileHeaderView.layer.cornerRadius = 12
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addArrangedSubview(profileHeaderView)

        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .white
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 40
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.text = "홍길동" // 이름은 userInfo에 맞게 표시
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        profileHeaderView.addSubview(profileImageView)
        profileHeaderView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            profileHeaderView.heightAnchor.constraint(equalToConstant: 150),

            profileImageView.centerXAnchor.constraint(equalTo: profileHeaderView.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: profileHeaderView.topAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.centerXAnchor.constraint(equalTo: profileHeaderView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
        ])
    }

    func setupUserInfoCards() {
        for (key, value) in userInfo {
            let cardView = createInfoCard(title: key, value: value)
            contentView.addArrangedSubview(cardView)
        }
    }

    func setupEditButton() {
        editButton.setTitle("정보 수정", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.backgroundColor = UIColor.systemGreen
        editButton.layer.cornerRadius = 8
        editButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        contentView.addArrangedSubview(editButton)
    }

    func createInfoCard(title: String, value: String) -> UIView {
        let cardView = UIView()
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 0
        cardView.backgroundColor = UIColor.systemGray6
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 18)
        valueLabel.textColor = UIColor.black
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(titleLabel)
        cardView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])

        return cardView
    }

    @objc func editButtonTapped() {
        let editVC = EditUserInfoViewController()
        navigationController?.pushViewController(editVC, animated: true)
    }
}



