import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    func setupTabBar() {
        // 오늘 식단 탭
        let todayDietVC = MainViewController()
        let todayDietNavVC = UINavigationController(rootViewController: todayDietVC)
        todayDietNavVC.tabBarItem = UITabBarItem(title: "오늘 식단", image: UIImage(systemName: "house"), tag: 0)

        // 식단 기록 탭
        let dietRecordVC = CalendarViewController() // CalendarViewController 사용
        let dietRecordNavVC = UINavigationController(rootViewController: dietRecordVC)
        dietRecordNavVC.tabBarItem = UITabBarItem(title: "식단 기록", image: UIImage(systemName: "list.bullet"), tag: 1)

        // 프로필 탭
        let profileVC = ProfileViewController() // ProfileViewController 사용
        let profileNavVC = UINavigationController(rootViewController: profileVC)
        profileNavVC.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), tag: 2)

        // 탭 바에 뷰 컨트롤러 설정
        viewControllers = [todayDietNavVC, dietRecordNavVC, profileNavVC]
        selectedIndex = 0 // "오늘 식단" 화면을 기본 선택
    }



}


