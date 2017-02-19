//
//  IAViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/18/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit


class IAViewController: UIViewController {
    
    //MARK: - Top Nav View
    @IBOutlet weak var topNavView: IATopNavView?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let topNav = self.topNavView, self.navigationController != nil {
            topNav.frame = (self.navigationController?.navigationBar.bounds)!
            self.navigationItem.titleView = topNav
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
