//
//  IdeeView.swift
//  DeutsWords
//
//  Created by deus4 on 24/10/16.
//  Copyright © 2016 Deus4. All rights reserved.
//

import UIKit

class IdeeView: UIView {
    

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var textLabels: [UILabel]!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "IdeeXib", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    @IBAction func closeButtonAction(_ sender: UIButton) {
        let parentVC = self.window?.rootViewController as! ViewController
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.2
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { (ended) -> Void in
            self.removeFromSuperview()
            parentVC.colorButton.isUserInteractionEnabled = true
            parentVC.ideeButton.isUserInteractionEnabled = true
        })
    }
    
    
}
