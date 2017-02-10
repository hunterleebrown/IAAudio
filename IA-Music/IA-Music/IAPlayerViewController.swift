//
//  IAPlayerViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/9/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class IAPlayerViewController: UIViewController {

    @IBOutlet weak var playerControlsView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var randomButton: UIButton!
    
    @IBOutlet weak var playingProgress: UISlider!
    @IBOutlet weak var topProgress: UIProgressView!
    
    @IBOutlet weak var minTime: UILabel!
    @IBOutlet weak var maxTime: UILabel!
    
    @IBOutlet weak var nowPlayingTitle: UILabel!
    @IBOutlet weak var nowPlayingItemTitle: UILabel!
    @IBOutlet weak var nowPlayingItemButton: UIButton!
    
    
    @IBOutlet weak var progressStack: UIView!
    @IBOutlet weak var titleStack: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var helpIconButton: UIButton!
    
    @IBOutlet weak var airPlayPicker: MPVolumeView!

    weak var baseViewController: IAHomeViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.hidesWhenStopped = false
        self.activityIndicator.type = .lineScaleParty
        self.playButton.setIAIcon(.iosPlayOutline, forState: UIControlState())
        self.forwardButton.setIAIcon(.iosSkipforwardOutline, forState: UIControlState())
        self.backwardButton.setIAIcon(.iosSkipbackwardOutline, forState: UIControlState())
        self.randomButton.setTitle(IAFontMapping.RANDOM, for: UIControlState())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func epandPlayer() {
        self.baseViewController.playerMove()
    }


}
