
import UIKit

protocol PostItDelegate {
    func increaseValue(index: Int)
    func decreaseValue(index: Int)
}

class PostItTVCell: UITableViewCell {
    //MARK: Variables & Outlets
    var index = Int()
    var delegate: PostItDelegate?
    @IBOutlet weak var btn_Down: UIButton!
    @IBOutlet weak var btn_Up: UIButton!
    @IBOutlet weak var lbl_Name: UILabel!
    
    func awakeFromNib(conteudo_Post_It: String) {
        super.awakeFromNib()
        btn_Up.alpha = 0.0
        btn_Down.alpha = 0.0
        
        self.lbl_Name.text = conteudo_Post_It
        self.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: Button Actions:
    @IBAction func btn_Up(_ sender: Any) {
        print("self tag = \(self.tag)")
        delegate?.increaseValue(index: index)
    }
    
    @IBAction func btn_Down(_ sender: Any) {
        delegate?.decreaseValue(index: index)
    }    
}

