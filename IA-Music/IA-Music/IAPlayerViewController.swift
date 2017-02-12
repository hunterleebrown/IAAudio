//
//  IAPlayerViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/9/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer


class IAPlayerViewController: UIViewController {

    @IBOutlet weak var playerControlsView: UIView!
    @IBOutlet var playButton: UIButton!
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
    var sliderIsTouched : Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.hidesWhenStopped = false
        self.activityIndicator.type = .lineScaleParty
        self.playButton.setIAIcon(.iosPlayOutline, forState: UIControlState())
        self.forwardButton.setIAIcon(.iosSkipforwardOutline, forState: UIControlState())
        self.backwardButton.setIAIcon(.iosSkipbackwardOutline, forState: UIControlState())
        
        self.randomButton.setTitle(IAFontMapping.RANDOM, for: UIControlState())
        
        self.randomButton.tintColor = UIColor.white
     
        self.airPlayPicker.showsRouteButton = true
        self.airPlayPicker.showsVolumeSlider = false
        
        IAPlayer.sharedInstance.controlsController = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func expandPlayer() {
        self.baseViewController.playerMove()
    }

    @IBAction func playerUp() {
        self.baseViewController.showFullPlayer(true)
    }

    @IBAction func playerDown() {
        self.baseViewController.showFullPlayer(false)
    }
    
    @IBAction func didPressButton(_ sender:UIButton){
        
        if(sender == self.playButton){
            IAPlayer.sharedInstance.didTapPlayButton()
        } else if sender == self.forwardButton {
//            IAPlayer.sharedInstance.advancePlaylist()
        } else if sender == self.backwardButton {
//            IAPlayer.sharedInstance.reversePlaylist()
        } else if sender == self.randomButton {
            self.randomButton.isSelected = !self.randomButton.isSelected
        }
    }

    
    //MARK: Slider
    @IBAction func sliderTouchUp() {
        sliderIsTouched = false
        IAPlayer.sharedInstance.monitorPlayback()
    }
    
    @IBAction func sliderTouchDown() {
        sliderIsTouched = true
    }
    
    @IBAction func sliderValueChanged() {
        
        if let player = IAPlayer.sharedInstance.avPlayer {
            let duration = CMTimeGetSeconds((player.currentItem?.duration)!)
            let sec = duration * Float64(self.playingProgress.value)
            let seakTime:CMTime = CMTimeMakeWithSeconds(sec, 600)
            player.seek(to: seakTime)
            IAPlayer.sharedInstance.updatePlayerTimes()
        }
        
    }
    
}


class IAPlayer: NSObject {

    var avPlayer: AVPlayer?
    var controlsController : IAPlayerViewController?
    var observing = false
    fileprivate var observerContext = 0
    
    static let sharedInstance: IAPlayer = {
        return IAPlayer()
    }()

    var fileTitle: String?
    var fileIdentifierTitle: String?
    var fileIdentifier: String?
    
    func playFile(file:IAFileMappable, doc:IAArchiveDocMappable){
        
        if let player = avPlayer {
            player.pause()
            
            if(self.observing) {
                player.removeObserver(self, forKeyPath: "rate", context: &observerContext)
                self.observing = false
            }
            
            avPlayer = nil
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                
            }
        }
        
        self.fileTitle = file.title
        self.fileIdentifierTitle = doc.title
        self.fileIdentifier = doc.identifier
        
        if let controller = controlsController {
            controller.nowPlayingTitle.text = self.fileTitle
            controller.nowPlayingItemTitle.text = self.fileIdentifierTitle
        }
        
        let playUrl = doc.fileUrl(file: file)
        avPlayer = AVPlayer(url: playUrl as URL)
        
        avPlayer?.addObserver(self, forKeyPath: "rate", options:.new, context: &observerContext)
        self.observing = true
        
        avPlayer?.play()

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
        }
        
    }
    
    func didTapPlayButton() {

        if let player = avPlayer {
            if player.currentItem != nil && self.observing {
                player.pause()
            } else {
                player.play()
            }
        }
        
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let player = avPlayer, let controller = controlsController {
            
            if player == object as! AVPlayer && "rate" == keyPath {
                print("rate changed: \(player.rate)")
                
                if player.rate == 0 {
                    controller.playButton.setIAIcon(.iosPlayOutline, forState: UIControlState())
                } else {
                    controller.playButton.setIAIcon(.iosPauseOutline, forState: UIControlState())
                }
                
                
                if controller.activityIndicator != nil {
                    player.rate > 0.0 ? controller.activityIndicator.startAnimation() : controller.activityIndicator.stopAnimation()
                }
                
                var songInfo : [String : AnyObject] = [
                    MPNowPlayingInfoPropertyPlaybackRate : player.rate as AnyObject,
                    MPNowPlayingInfoPropertyElapsedPlaybackTime : NSNumber(value: Double(self.elapsedSeconds()) as Double),
                    MPMediaItemPropertyTitle : self.fileTitle! as AnyObject,
                    MPMediaItemPropertyAlbumTitle: self.fileIdentifierTitle! as AnyObject,
                    MPMediaItemPropertyPlaybackDuration : NSNumber(value: CMTimeGetSeconds((player.currentItem?.duration)!) as Double)
                ]
//                if self.mediaArtwork != nil {
//                    songInfo[MPMediaItemPropertyArtwork] = self.mediaArtwork
//                }
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
                
                self.monitorPlayback()
                
            }
            
        }
    }
    
    func elapsedSeconds()->Int {
        if let player = avPlayer {

            let calcTime = CMTimeGetSeconds((player.currentItem?.duration)!) - CMTimeGetSeconds(player.currentTime())
            if(!calcTime.isNaN) {
                let duration = CMTimeGetSeconds((player.currentItem?.duration)!)
                return Int(duration) - Int(calcTime)
            }
            return 0
        }
        
        return 0
    }
    
    
    func monitorPlayback() {
        
        if let player = avPlayer, let controller = controlsController {
            
            
            if(player.currentItem != nil) {
                
                let progress = CMTimeGetSeconds(player.currentTime()) / CMTimeGetSeconds((player.currentItem?.duration)!)
                
                if controller.playingProgress != nil {
                    controller.playingProgress.setValue(Float(progress), animated: false)
                    controller.topProgress.setProgress(Float(progress), animated: false)
                }
                
                updatePlayerTimes()
                
                if(player.rate != 0.0) {
                    let delay = 0.1 * Double(NSEC_PER_SEC)
                    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time) {
                        self.monitorPlayback()
                    }
                }
            }
            
            return
        }
    }
    
    func updatePlayerTimes() {
        
        if let player = avPlayer, let controller = controlsController {
            
            let calcTime = CMTimeGetSeconds((player.currentItem?.duration)!) - CMTimeGetSeconds(player.currentTime())
            
            if(!calcTime.isNaN) {
                if controller.minTime != nil {
                    controller.minTime.text = StringUtils.timeFormatted(self.elapsedSeconds())
                }
                if controller.maxTime != nil {
                    controller.maxTime.text = StringUtils.timeFormatted(Int(calcTime))
                }
            }
        }
    }
    
}


