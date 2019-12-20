//
//  VideoPlayerViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 09/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit


class VideoPlayerViewController: UIViewController {
    
    var playerController = AVPlayerViewController()
    var strUrl = String()
    //var videoUrl = URL()
    
    @IBAction func btn_Back(_ sender: Any) {
        
        self.dismiss(animated: true) {
            self.playerController.player?.pause()
            self.playerController.dismiss(animated: true,completion: nil)
        }
    }
    @IBOutlet weak var view_Video: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoUrl = URL(string: strUrl)
        let player = AVPlayer(url:videoUrl!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying(note:)),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        playerController.player = player
        playerController.delegate = self
        playerController.player?.play()
        //self.addChildViewController(playerController)
        view_Video.addSubview(playerController.view)
        playerController.view.frame = CGRect(x: 0, y: 0, width: view_Video.frame.size.width, height: view_Video.frame.size.height)//view_Video.frame
        // Do any additional setup after loading the view.
    }
    
    @objc func didFinishPlaying(note : NSNotification) {
        self.dismiss(animated: true) {
            self.playerController.player?.pause()
            self.playerController.dismiss(animated: true,completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension VideoPlayerViewController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        let currentviewController =  navigationController?.visibleViewController
        
        if currentviewController != playerViewController
        {
            currentviewController?.present(playerViewController,animated: true,completion:nil)
        }
        
        
    }
}
