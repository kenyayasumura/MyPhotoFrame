//
//  SecondViewController.swift
//  MyPhotoFrame
//
//  Created by 安村建哉 on 2020/09/06.
//  Copyright © 2020 安村建哉. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dissmissBtn: UIButton!
    var dismissFlg: Bool = false
    var photoArray: [UIImage] = []
    var index = 0
    let animationDuration: TimeInterval = 1
    let switchingInterval: TimeInterval = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func initView() {
        dissmissBtn.layer.cornerRadius = dissmissBtn.frame.size.width / 2
        dissmissBtn.isHidden = true
        imageView.image = photoArray[index]
        animateImageView()
        imageView.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            UIView.transition(with: self.imageView,
                              duration: self.animationDuration,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in
                                  self!.imageView.alpha = 1
                              }, completion: nil)
        }
    }
    
    func animateImageView() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.switchingInterval) {
                self.animateImageView()
            }
        }

        let transition = CATransition()
        transition.type = CATransitionType.fade

        imageView.layer.add(transition, forKey: kCATransition)
        imageView.image = photoArray[index]

        CATransaction.commit()

        index = index < photoArray.count - 1 ? index + 1 : 0
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        dismissFlg.toggle()
        if dismissFlg {
            dissmissBtn.isHidden = true
        } else {
            dissmissBtn.isHidden = false
        }
     }
    
    @IBAction func dissmissSecondVC(_ sender: Any) {
        UIView.transition(with: imageView,
            duration: animationDuration,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
            self!.imageView.alpha = 0
            }, completion: {(success:Bool) in
                
                let preVC = self.presentingViewController as! ViewController
                preVC.orientationFlg = true
            
                DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration) {
                    self.dismiss(animated: true, completion: nil)
                }
            })
    }
}

