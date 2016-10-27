//
//  HurreyViewController.swift
//  Savio
//
//  Created by Prashant on 23/05/16.
//  Copyright © 2016 Prashant. All rights reserved.
//

import UIKit

class HurreyViewController: UIViewController {
    @IBOutlet weak var btn:UIButton?
    var isSavingPresent:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        btn?.layer.cornerRadius = 5.0
    }
 
    @IBAction func createPlanPressed(sender: AnyObject) {
        let objContainer = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
        self.navigationController?.pushViewController(objContainer, animated: true)
    }
}
