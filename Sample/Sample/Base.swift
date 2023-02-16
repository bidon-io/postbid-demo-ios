import UIKit


class BaseController: UIViewController {
    
    enum State {
        case idle
        case loading
        case ready
    }
    
    private weak var loadButton: UIButton?
    
    private weak var showButton: UIButton?
    
    @IBAction func showButtonAction(_ sender: UIButton) {
        switchState(.idle)
    }
    
    @IBAction func loadButtonAction(_ sender: UIButton) {
        switchState(.loading)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let view: UIView = Bundle.main.loadNibNamed("BaseView", owner: nil)?.first as? UIView else { return }
        
        if let loadButton: UIButton = view.viewWithTag(1) as? UIButton {
            self.loadButton = loadButton
        }
        if let showButton: UIButton = view.viewWithTag(2) as? UIButton {
            self.showButton = showButton
        }
        
        self.switchState(.idle)
        
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                                     view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                                     view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                                     view.heightAnchor.constraint(equalToConstant: 100)])
    }
}

extension BaseController {
    
    func switchState(_ currentState: BaseController.State) {
        switch currentState {
        case .idle:
            self.loadButton.flatMap { $0.isHidden = false }
            self.showButton.flatMap { $0.isHidden = true }
            break
        case .loading:
            self.loadButton.flatMap { $0.isHidden = true }
            self.showButton.flatMap { $0.isHidden = true }
            break
        case .ready:
            self.loadButton.flatMap { $0.isHidden = true }
            self.showButton.flatMap { $0.isHidden = false }
            break
        }
    }
}
