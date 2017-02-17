//
//  IAPlayerViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/9/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import AVFoundation


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

    @IBOutlet weak var playerIcon: UIImageView!
    
    weak var baseViewController: IAHomeViewController!
    var sliderIsTouched : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonColors()
        
        self.activityIndicator.hidesWhenStopped = false
        self.activityIndicator.type = .lineScaleParty
        self.playButton.setIAIcon(.iosPlayOutline, forState: .normal)
        self.forwardButton.setIAIcon(.iosSkipforwardOutline, forState: .normal)
        self.backwardButton.setIAIcon(.iosSkipbackwardOutline, forState: .normal)
        
        self.randomButton.setTitle(IAFontMapping.RANDOM, for: .normal)
        self.randomButton.tintColor = UIColor.white
     
        self.airPlayPicker.showsRouteButton = true
        self.airPlayPicker.showsVolumeSlider = false
        
        IAPlayer.sharedInstance.controlsController = self

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
            print("Can't set category or active session")
        }
        
        self.view.backgroundColor = IAColors.fairyRed

    }

    func buttonColors() {
    
        for button in [self.playButton, self.forwardButton, self.backwardButton, self.randomButton] {
            button?.setTitleColor(IAColors.fairyCream, for: .normal)
        }
        
        minTime.textColor = IAColors.fairyCream
        maxTime.textColor = IAColors.fairyCream
        playingProgress.thumbTintColor = IAColors.fairyCream
        playingProgress.minimumTrackTintColor = IAColors.fairyCream
        topProgress.progressTintColor = IAColors.fairyCream
        
        self.activityIndicator.color = IAColors.fairyCream
        
        self.nowPlayingTitle.textColor = IAColors.fairyCream
        
        nowPlayingItemButton.setTitleColor(IAColors.fairyCream, for: .normal)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
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
    
    
    @IBAction func pushDoc(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushDoc"), object: nil)
    }

    
    
    //MARK: Remote
    override func remoteControlReceived(with event: UIEvent?) {
    print("----------->: revceived remote control event: \(event)")
    
        if IAPlayer.sharedInstance.avPlayer != nil {
            
            if (event!.type == UIEventType.remoteControl) {
                switch (event!.subtype) {
                case .remoteControlPause:
                    IAPlayer.sharedInstance.didTapPlayButton()
                    break;
                case .remoteControlPlay:
                    IAPlayer.sharedInstance.didTapPlayButton()
                    break;
                case .remoteControlStop:
                    IAPlayer.sharedInstance.didTapPlayButton()
                    break;
                case .remoteControlTogglePlayPause:
                    IAPlayer.sharedInstance.didTapPlayButton()
                    break;
                case .remoteControlPreviousTrack:
                    //                self.goToPreviousTrack()
                    break;
                case .remoteControlNextTrack:
                    //                self.goToNextTrack()
                    break;
                    
                default:
                    break;
                }
            }
        }
    }
    
}


class IAPlayer: NSObject {

    var avPlayer: AVPlayer?
    var controlsController : IAPlayerViewController?
    var observing = false
    var playing = false
    var playUrl: URL!
    
    fileprivate var observerContext = 0
    
    static let sharedInstance: IAPlayer = {
        return IAPlayer()
    }()

    var fileTitle: String?
    var fileIdentifierTitle: String?
    var fileIdentifier: String?
    
    var mediaArtwork : MPMediaItemArtwork?
    
    func playFile(file:IAFileMappable, doc:IAArchiveDocMappable){
        
        self.fileTitle = file.title
        self.fileIdentifierTitle = doc.title
        self.fileIdentifier = doc.identifier
        self.playUrl = doc.fileUrl(file: file)

        self.loadAndPlay()
    }
    
    func playFile(file:IAPlayerFile) {
        
        self.fileTitle = file.title.isEmpty ? file.name : file.title
        self.fileIdentifierTitle = file.archive?.identifierTitle
        self.fileIdentifier = file.archive?.identifier
        self.playUrl = URL(string: file.urlString)
        
        self.loadAndPlay()
    }
    
    
    private func loadAndPlay() {
        
        if let player = avPlayer {
            player.pause()
            
            if(self.observing) {
                player.removeObserver(self, forKeyPath: "rate", context: &observerContext)
                self.observing = false
            }
            
            self.setPlayingInfo(playing: false)
            avPlayer = nil
        }
        
        self.setActiveAudioSession()
        
        if let controller = controlsController {
            controller.nowPlayingTitle.text = self.fileTitle
            controller.nowPlayingItemButton.setTitle(self.fileIdentifierTitle, for: .normal)
        }
        
        avPlayer = AVPlayer(url: self.playUrl as URL)
        
        avPlayer?.addObserver(self, forKeyPath: "rate", options:.new, context: &observerContext)
        self.observing = true
        
        avPlayer?.play()
        self.setPlayingInfo(playing: true)
    }
    
    
    func didTapPlayButton() {

        if let player = avPlayer {
            if player.currentItem != nil && self.playing {
                player.pause()
                self.setPlayingInfo(playing: false)
            } else {
                player.play()
                self.setPlayingInfo(playing: true)
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
                
                self.playing  = player.rate > 0.0
                if controller.activityIndicator != nil {
                    player.rate > 0.0 ? controller.activityIndicator.startAnimation() : controller.activityIndicator.stopAnimation()
                }
                
                self.monitorPlayback()
            }
            
        }
    }
    
    
    func setPlayingInfo(playing:Bool) {
        
        if let identifier = self.fileIdentifier {
            
            let imageView = UIImageView()
            let url = IAMediaUtils.imageUrlFrom(identifier)
            
            if playing {
                UIApplication.shared.beginReceivingRemoteControlEvents()
                controlsController?.becomeFirstResponder()
            }
            
            imageView.af_setImage(
                withURL: url!,
                placeholderImage: nil,
                filter: nil,
                progress: nil,
                progressQueue: DispatchQueue.main,
                imageTransition: UIImageView.ImageTransition.noTransition,
                runImageTransitionIfCached: false) { (response) in
                    
                    switch response.result {
                    case .success(let image):
                        self.mediaArtwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                            image
                        })
                        
                        self.controlsController?.playerIcon.image = image
                        self.controlsController?.playerIcon.backgroundColor = UIColor.white
                        
                        let playBackRate = playing ? "1.0" : "0.0"
                        
                        var songInfo : [String : AnyObject] = [
                            MPNowPlayingInfoPropertyElapsedPlaybackTime : NSNumber(value: Double(self.elapsedSeconds()) as Double),
                            MPMediaItemPropertyAlbumTitle: self.fileIdentifierTitle! as AnyObject,
                            MPMediaItemPropertyPlaybackDuration : NSNumber(value: CMTimeGetSeconds((self.avPlayer?.currentItem?.duration)!) as Double),
                            MPNowPlayingInfoPropertyPlaybackRate: playBackRate as AnyObject
                        ]
                        
                        if let artwork = self.mediaArtwork {
                            songInfo[MPMediaItemPropertyArtwork] = artwork
                        }
                        
                            songInfo[MPMediaItemPropertyTitle] = self.fileTitle as AnyObject?
                        
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
                        
                        
                    case .failure(let error):
                        print("-----------> player couldn't get image: \(error)")
                        break
                    }
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
    
    func setActiveAudioSession(){
        let audioSession = AVAudioSession.sharedInstance()
        if(audioSession.category != AVAudioSessionCategoryPlayback)
        {
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try audioSession.setActive(true)
            }
            catch {
                fatalError("Failure to session: \(error)")
                
            }
        }
    }
    
}


