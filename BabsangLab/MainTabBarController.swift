import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    func setupTabBar() {
        let todayDietVC = MainViewController()
        let todayDietNavVC = UINavigationController(rootViewController: todayDietVC) // UINavigationController로 감싸기
        todayDietNavVC.tabBarItem = UITabBarItem(title: "오늘 식단", image: UIImage(systemName: "house"), tag: 0)

        let dietRecordVC = UIViewController()
        dietRecordVC.view.backgroundColor = .white
        dietRecordVC.tabBarItem = UITabBarItem(title: "식단 기록", image: UIImage(systemName: "list.bullet"), tag: 1)

        let profileVC = UIViewController()
        profileVC.view.backgroundColor = .white
        profileVC.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), tag: 2)

        viewControllers = [todayDietNavVC, dietRecordVC, profileVC]
        selectedIndex = 0 // "오늘 식단" 화면을 기본 선택
    }

}


