import UIKit

class HeroHeaderUIView: UIView {
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.darkGray
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.clear
        return button
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.clear
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        addGradient()
    }
    
    private func setupView() {
        addSubview(heroImageView)
        addSubview(playButton)
        addSubview(downloadButton)
        
        // Set default image safely
        if let defaultImage = UIImage(named: "hero_placeholder") {
            heroImageView.image = defaultImage
        } else {
            heroImageView.backgroundColor = UIColor.darkGray
        }
        
        // Add button actions
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        heroImageView.frame = bounds
        
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 40
        let buttonSpacing: CGFloat = 20
        
        playButton.frame = CGRect(
            x: (bounds.width - (buttonWidth * 2 + buttonSpacing)) / 2,
            y: bounds.height - 80,
            width: buttonWidth,
            height: buttonHeight
        )
        
        downloadButton.frame = CGRect(
            x: playButton.frame.maxX + buttonSpacing,
            y: bounds.height - 80,
            width: buttonWidth,
            height: buttonHeight
        )
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.locations = [0.7, 1.0]
        layer.addSublayer(gradientLayer)
        
        // Update gradient frame in layoutSubviews
        DispatchQueue.main.async {
            gradientLayer.frame = self.bounds
        }
    }
    
    @objc private func playButtonTapped() {
        print("Play button tapped")
    }
    
    @objc private func downloadButtonTapped() {
        print("Download button tapped")
    }
}