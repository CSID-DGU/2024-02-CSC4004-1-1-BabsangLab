import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var selectedFoodType: FoodType?

    override func viewDidLoad() {
        print("test")
        super.viewDidLoad()
        view.backgroundColor = .white
        openCamera() // View가 로드되면 바로 카메라를 호출합니다.
    }

    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("카메라를 사용할 수 없습니다.")
            showAlert(title: "오류", message: "카메라를 사용할 수 없습니다.")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                let resultVC = ResultViewController()
                resultVC.selectedImage = image
                resultVC.selectedFoodType = self.selectedFoodType!

                // 네비게이션 스택에서 CameraViewController를 제거
                if let navigationControllers = self.navigationController?.viewControllers {
                    let filteredViewControllers = navigationControllers.filter { $0 !== self }
                    self.navigationController?.setViewControllers(filteredViewControllers + [resultVC], animated: true)
                }
            }
        }
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}


