//
//  GoodByeViewController.swift
//  CurtainTransition
//
//  Created by waleed azhar on 2017-04-18.
//  Copyright © 2017 waleed azhar. All rights reserved.
//

import UIKit

class GoodByeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        let iv = UIImageView(image: #imageLiteral(resourceName: "bs"))
        iv.frame = view.bounds
       
        let ve = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        ve.frame = view.bounds
        self.view.insertSubview(ve, at: 0)
        self.view.insertSubview(iv, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func s(_ sender: UIButton) {
        if let p = self.parent as? CurtainViewController{
            p.close()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
