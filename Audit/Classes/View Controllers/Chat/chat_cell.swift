//
//  chat_cell.swift
//  Audit
//
//  Created by Mac on 11/1/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import AVFoundation

protocol ChatDownloadcellDelegate {
    func downloadction(index: Int, downloadId: Int)
}

class chat_cell: UITableViewCell {
    
    var index = Int()
    var downloadId = Int()
    var delegate: ChatDownloadcellDelegate?
    
    @IBOutlet weak var img_profilepic: UIImageView!

    @IBOutlet weak var img_bubble: UIImageView!
    @IBOutlet weak var lbl_message: UILabel!
    @IBOutlet weak var lbl_date: UILabel!

    @IBOutlet weak var img_media: UIImageView!
    @IBOutlet weak var img_play: UIImageView!
    
    @IBOutlet weak var blur_view: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setChatUserData(obChat: ChatModel) {
        if UserProfile.id == obChat.fromid {
            self.setSenderChatData(obChat: obChat)
        } else {
            self.setReceiverChatData(obChat: obChat)
        }
    }
    
    func setSenderChatData(obChat: ChatModel) {
        
        img_profilepic.backgroundColor = .white
                
        if obChat.msgtype == 1 {
            lbl_message.text = obChat.msg
        }
        else if obChat.msgtype == 2 {
            
            img_media.contentMode = .scaleAspectFill

            if obChat.is_download == 1 {
                
                print("is_download -- 1")
                
                let obfile = FileDownloaderManager()
                print("Obfile \(obfile.getMediaDirectoryIfNotExist())")
                let imageUrl = obfile.getMediaDirectoryIfNotExist().appendingPathComponent("\(obChat.msg!)")
                
                let filePath = imageUrl.path
                let fileManager = FileManager.default
                
                if fileManager.fileExists(atPath: filePath) {
                    print("FILE AVAILABLE")
                    
                    blur_view.alpha = 0.0
                    img_media.alpha = 1.0
                    
                    DispatchQueue.global(qos: .background).async {
                        print("This is run on the background queue")
                        let image_download = UIImage(contentsOfFile: imageUrl.path)
                        DispatchQueue.main.async {
                            self.img_media.image = image_download
                        }
                    }
                    
                    let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showAvatar(_:)))
                    tapGestureRecognizer11.numberOfTapsRequired = 1
                    img_media.addGestureRecognizer(tapGestureRecognizer11)
                    
                } else {
                    print("FILE NOT AVAILABLE")
                    
                    blur_view.alpha = 1.0
                    img_media.alpha = 0.3
                    
                    let imgUrl = Server.ImagePath.TestUrl + obChat.msg!
                    self.img_media.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage.init(named: ""))
                }
                
            } else {
                print("is_download -- 0")
            }
        }
        else if obChat.msgtype == 3 {
            
            img_media.contentMode = .scaleAspectFill
            
            img_play.alpha = 1.0

            if obChat.is_download == 1 {
                let obfile = FileDownloaderManager()
                print("Obfile \(obfile.getMediaDirectoryIfNotExist())")
                let videoUrl = obfile.getMediaDirectoryIfNotExist().appendingPathComponent("\(obChat.msg!)")
                
                let filePath = videoUrl.path
                let fileManager = FileManager.default
                
                if fileManager.fileExists(atPath: filePath) {
                    print("FILE AVAILABLE")
                    
                    blur_view.alpha = 0.0
                    img_media.alpha = 1.0
                    img_play.alpha = 1.0
                    
                    DispatchQueue.global(qos: .background).async {
                        print("This is run on the background queue")
                        let image_download = self.getThumbnailFrom(path: videoUrl as URL)
                        DispatchQueue.main.async {
                            self.img_media.image = image_download
                        }
                    }
                    
                } else {
                    print("FILE NOT AVAILABLE")
                    
                    blur_view.alpha = 1.0
                    img_media.alpha = 0.3
                    img_play.alpha = 0.0
                    
                    let imgUrl = Server.ImagePath.TestUrl + obChat.msg!
                    let videoUrl = NSURL(string: imgUrl)
                    DispatchQueue.global(qos: .background).async {
                        print("This is run on the background queue")
                        let image_download = self.getThumbnailFrom(path: videoUrl! as URL)
                        DispatchQueue.main.async {
                            self.img_media.image = image_download
                        }
                    }
                }
               
            } else {}

        }
        else if obChat.msgtype == 4 {
            
            img_media.contentMode = .scaleAspectFill
            
            let obfile = FileDownloaderManager()
            print("Obfile \(obfile.getMediaDirectoryIfNotExist())")
            let videoUrl = obfile.getMediaDirectoryIfNotExist().appendingPathComponent("\(obChat.msg!)")
            
            let filePath = videoUrl.path
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                blur_view.alpha = 0.0
                img_media.alpha = 1.0
                img_media.image = UIImage.init(named: "pdf")
            } else {
                print("FILE NOT AVAILABLE")
                blur_view.alpha = 1.0
                img_media.alpha = 0.3
                img_media.image = UIImage.init(named: "pdf")
            }
        }
        
        print("obChat.msgtime --- \(obChat.msgtime!)")

        let datestr = dc.getTimeDifferenceBetweenTwoDates(strMsgDate: obChat.msgtime!)
        if datestr != ""{
            print("Date -- \(datestr)")
            lbl_date.text = datestr
        } else {
            lbl_date.text = ""
        }
        
        let image = UIImage(named: "green bubble")
        
        img_bubble.image = image?
            .resizableImage(withCapInsets:
                UIEdgeInsetsMake(11, 12, 11, 12),
                            resizingMode: .stretch)
            .withRenderingMode(.alwaysTemplate)
        
        img_bubble.tintColor = UIColor(red: 44/255.0,
                                                 green: 189/255.0,
                                                 blue: 165/255.0,
                                                 alpha: 1.0)
    }
    
    func setReceiverChatData(obChat: ChatModel) {
        
        img_profilepic.backgroundColor = .white

        if obChat.msgtype == 1 {
            lbl_message.text = obChat.msg
        }
        else if obChat.msgtype == 2 {
            
            img_media.contentMode = .scaleAspectFill
            
            if obChat.is_download == 0 {
                blur_view.alpha = 1.0
                img_media.alpha = 0.3

                let imgUrl = Server.ImagePath.TestUrl + obChat.msg!
                self.img_media.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage.init(named: ""))
            } else {
                blur_view.alpha = 0.0
                img_media.alpha = 1.0
                
                let obfile = FileDownloaderManager()
                print("Obfile \(obfile.getMediaDirectoryIfNotExist())")
                let imageUrl = obfile.getMediaDirectoryIfNotExist().appendingPathComponent("\(obChat.msg!)")
                
                DispatchQueue.global(qos: .background).async {
                    print("This is run on the background queue")
                    let image_download = UIImage(contentsOfFile: imageUrl.path)
                    DispatchQueue.main.async {
                        self.img_media.image = image_download
                    }
                }
                
                let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showAvatar(_:)))
                tapGestureRecognizer11.numberOfTapsRequired = 1
                img_media.addGestureRecognizer(tapGestureRecognizer11)
            }
        }
        else if obChat.msgtype == 3 {
            
            img_media.contentMode = .scaleAspectFill
            
            if obChat.is_download == 0 {
                blur_view.alpha = 1.0
                img_media.alpha = 0.3
                img_play.alpha = 0.0
                
                let imgUrl = Server.ImagePath.TestUrl + obChat.msg!
                let videoUrl = NSURL(string: imgUrl)
                DispatchQueue.global(qos: .background).async {
                    print("This is run on the background queue")
                    let image_download = self.getThumbnailFrom(path: videoUrl! as URL)
                    DispatchQueue.main.async {
                        self.img_media.image = image_download
                    }
                }
            } else {
                blur_view.alpha = 0.0
                img_media.alpha = 1.0
                img_play.alpha = 1.0
                
                let obfile = FileDownloaderManager()
                print("Obfile \(obfile.getMediaDirectoryIfNotExist())")
                let videoUrl = obfile.getMediaDirectoryIfNotExist().appendingPathComponent("\(obChat.msg!)")
                
                DispatchQueue.global(qos: .background).async {
                    print("This is run on the background queue")
                    let image_download = self.getThumbnailFrom(path: videoUrl as URL)
                    DispatchQueue.main.async {
                        self.img_media.image = image_download
                    }
                }
            }
        }
        else  if obChat.msgtype == 4 {
            
            img_media.contentMode = .scaleAspectFill
            
            if obChat.is_download == 0 {
                blur_view.alpha = 1.0
                img_media.alpha = 0.3
                img_media.image = UIImage.init(named: "pdf")
            } else {
                blur_view.alpha = 0.0
                img_media.alpha = 1.0
                img_media.image = UIImage.init(named: "pdf")
            }
        }
        
        print("obChat.msgtime --- \(obChat.msgtime!)")
        
        let datestr = dc.getTimeDifferenceBetweenTwoDates(strMsgDate: obChat.msgtime!)
        if datestr != ""{
            print("Date -- \(datestr)")
            lbl_date.text = datestr
        } else {
            lbl_date.text = ""
        }
        
        let image = UIImage(named: "grey bubble")
        
        img_bubble.image = image?
            .resizableImage(withCapInsets:
                UIEdgeInsetsMake(11, 12, 11, 12),
                            resizingMode: .stretch)
            .withRenderingMode(.alwaysTemplate)
        
        img_bubble.tintColor = UIColor(red: 160/255.0,
                                                green: 173/255.0,
                                                blue: 191/255.0,
                                                alpha: 1.0)
    }
    
    @IBAction func showAvatar(_ sender: UITapGestureRecognizer) {
        let imgview = sender.view as! UIImageView
        if imgview.image != nil {
            SJAvatarBrowser.showImage(sender.view as? UIImageView)
        }
    }
    
    //MARK: Button Actions:
    @IBAction func btn_download(_ sender: Any) {
        print("self tag = \(self.tag)")
        delegate?.downloadction(index: index, downloadId: downloadId)
    }
    
    func getThumbnailFrom(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
}

extension UIImageView {
    func downloadImageFrom(link:String, contentMode: UIViewContentMode) {
        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}
