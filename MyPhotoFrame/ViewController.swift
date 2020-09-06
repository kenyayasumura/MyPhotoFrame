//
//  ViewController.swift
//  MyPhotoFrame
//
//  Created by 安村建哉 on 2020/08/28.
//  Copyright © 2020 安村建哉. All rights reserved.
//

import UIKit
import Photos
import BSImagePicker

class ViewController: UIViewController, UIImagePickerControllerDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var text: UILabel!
    
    let transition = CircularTransition()
    var selectedAssets: [PHAsset] = []
    var photoArray: [UIImage] = []
    var orientationFlg: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoBtn.layer.cornerRadius = photoBtn.frame.size.width / 2
        text.alpha = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if photoArray.isEmpty {
            showAlert(title: "エラー", message: "画像が選択されていません。")
        } else {
            orientationFlg = false
            let secondVC = segue.destination as! SecondViewController
            secondVC.photoArray = photoArray
            secondVC.transitioningDelegate = self
            secondVC.modalPresentationStyle = .custom
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if orientationFlg {
            return .portrait
        } else {
            return .all
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = photoBtn.center
        transition.circleColor = photoBtn.backgroundColor!
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dissmiss
        transition.startingPoint = photoBtn.center
        transition.circleColor = photoBtn.backgroundColor!
        return transition
    }
    
    func showAlert(title: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertController.Style.alert)
        
        //成功時の処理
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        
        //失敗時の処理
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func convertAssetsToImages() {
        if selectedAssets.count != 0 {
            for i in 0..<selectedAssets.count {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: selectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info) -> Void in
                    thumbnail = result!
                })
                
                let data = thumbnail.jpegData(compressionQuality: 0.7)
                let newImage = UIImage(data: data!)
                self.photoArray.append(newImage! as UIImage)
            }
            
            UIView.transition(with: text,
                              duration: 5,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in
                                self!.text.alpha = 1
            }, completion: nil)
        }
    }
    
    @IBAction func getPicturesFromAlbum() {
        let vc = BSImagePickerViewController()
        selectedAssets = []
        photoArray = []
        
        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
              // User selected an asset.
              // Do something with it, start upload perhaps?
            }, deselect: { (asset: PHAsset) -> Void in
              // User deselected an assets.
              // Do something, cancel upload?
            }, cancel: { (assets: [PHAsset]) -> Void in
              // User cancelled. And this where the assets currently selected.
            }, finish: { (assets: [PHAsset]) -> Void in
              // User finished with these assets
                for i in 0..<assets.count {
                    self.selectedAssets.append(assets[i])
                }
                self.convertAssetsToImages()
        }, completion: nil)
    }
    
}
