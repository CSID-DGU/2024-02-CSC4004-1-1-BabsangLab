import UIKit

// MARK: - UIButton Extension for Gradient



// MARK: - UIView Extension for Shadow

extension UIView {
    func addShadow(color: UIColor = .black, opacity: Float = 0.1, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
}

// MARK: - UILabel Extension for Styling

extension UILabel {
    func styleLabel(fontSize: CGFloat, weight: UIFont.Weight = .regular, textColor: UIColor = .black, alignment: NSTextAlignment = .left, numberOfLines: Int = 1) {
        self.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        self.textColor = textColor
        self.textAlignment = alignment
        self.numberOfLines = numberOfLines
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}


