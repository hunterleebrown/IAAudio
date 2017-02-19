//
//  IAHomeViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/9/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IAHomeViewController: UIViewController {

    
    @IBOutlet weak var playerHolder: UIView!
    @IBOutlet weak var tabControllerHolder: UIView!
    @IBOutlet weak var topViewCover: UIView!

    var minimizedPlayerTopContraint: NSLayoutConstraint?
    var maximizedPlayerTopConstraint: NSLayoutConstraint?

    weak var playerViewController: IAPlayerViewController!
    weak var iaTabBarController: IAHomeTabBarController!
    
    var pushUpPlayerTimerStarted = false


    
    var playerIsExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainViewMargins = self.view.layoutMarginsGuide
        self.minimizedPlayerTopContraint = self.playerHolder.topAnchor.constraint(equalTo: mainViewMargins.bottomAnchor, constant: -66)
        self.minimizedPlayerTopContraint?.isActive = true
        self.minimizedPlayerTopContraint?.identifier = "minimizePlayer"
        
        self.maximizedPlayerTopConstraint = self.playerHolder.topAnchor.constraint(equalTo: mainViewMargins.topAnchor)
        self.maximizedPlayerTopConstraint?.isActive = false
        self.maximizedPlayerTopConstraint?.identifier = "maximizePlayer"
        
        self.playerHolder.superview?.layoutIfNeeded()
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(IAHomeViewController.minimizePlayer),
            name: NSNotification.Name(rawValue: "minimizePlayer"),
            object: nil
        )
        
//        self.topViewCover.backgroundColor = IAColors.fairyRed
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func playerMove(){
        showFullPlayer(!self.playerIsExpanded)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playerEmbedSegue" {
            self.playerViewController = segue.destination as! IAPlayerViewController
            self.playerViewController.baseViewController = self
        }
        if segue.identifier == "tabEmbedSegue" {
            let navController = segue.destination as! UINavigationController
            self.iaTabBarController = navController.viewControllers.first as! IAHomeTabBarController
        }

    }


    func pushUpPlayerWithTimer(){
        showFullPlayer(true)
        self.pushUpPlayerTimerStarted = true
        let delay = 5.0 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            if self.pushUpPlayerTimerStarted {
                self.showFullPlayer(false)
            }
        }
    }
    
    func minimizePlayer() {
        self.showFullPlayer(false)
    }
    
    func showFullPlayer(_ isFull:Bool){
        
        self.minimizedPlayerTopContraint?.isActive = false
        self.maximizedPlayerTopConstraint?.isActive = false
        
        if (isFull) {
            self.minimizedPlayerTopContraint?.isActive = false
            self.maximizedPlayerTopConstraint?.isActive = true
        } else {
            self.maximizedPlayerTopConstraint?.isActive = false
            self.minimizedPlayerTopContraint?.isActive = true
        }
        
        UIView.animate(withDuration: 0.33, animations: { 
            self.playerHolder.superview?.layoutIfNeeded()
        }) { (done) in
            self.playerIsExpanded = isFull
        }
    }
    
    

    

    
}
