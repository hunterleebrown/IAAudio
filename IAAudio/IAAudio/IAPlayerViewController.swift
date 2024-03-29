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
import AVKit
import RealmSwift
import NVActivityIndicatorView
import iaAPI

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
    
    @IBOutlet weak var airPlayButton: UIView!

    @IBOutlet weak var playerIcon: UIImageView!
    
    @IBOutlet weak var nowPlayingTable: UITableView!
    @IBOutlet weak var nowPlayingBanner: UIView!
    @IBOutlet weak var nowPlayingBannerLabel: UILabel!
    
    weak var baseViewController: IAHomeViewController!
    var sliderIsTouched : Bool = false
    
    var playerTableFiles: List<IAPlayerFile>!
    
    var notificationToken: NotificationToken? = nil
    
    var playList: IAList?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonColors()
        
        self.playButton.setIAIcon(.iosPlayOutline, forState: .normal)
        self.forwardButton.setIAIcon(.iosSkipforwardOutline, forState: .normal)
        self.backwardButton.setIAIcon(.iosSkipbackwardOutline, forState: .normal)
        
        self.randomButton.setTitle(IAFontMapping.RANDOM, for: .normal)
        self.randomButton.tintColor = UIColor.white

        let routePicker = AVRoutePickerView(frame: self.airPlayButton.frame)
        self.view.addSubview(routePicker)
        routePicker.tintColor = .fairyCreamAlpha
        routePicker.activeTintColor = .black

        routePicker.translatesAutoresizingMaskIntoConstraints = false
        routePicker.centerYAnchor.constraint(equalTo: self.airPlayButton.centerYAnchor).isActive = true
        routePicker.centerXAnchor.constraint(equalTo: self.airPlayButton.centerXAnchor).isActive = true

        IAPlayer.sharedInstance.controlsController = self
        
        self.playerIcon.layer.cornerRadius = 3.0
        

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
            print("Can't set category or active session")
        }
        
        self.view.backgroundColor = UIColor.fairyRed
        
        self.nowPlayingTable.sectionFooterHeight = 0.0
        self.nowPlayingTable.backgroundColor = UIColor.darkGray
        
        self.nowPlayingBannerLabel.textColor = UIColor.fairyCream
        self.nowPlayingBanner.backgroundColor = UIColor.fairyRed
        
        
        playList = RealmManager.realm.objects(IAList.self).filter("title = '\(RealmManager.NOWPLAYING)'").first
        
        if let list = playList {
            playerTableFiles = list.files
            
            notificationToken = playerTableFiles.observe{ change in
                switch change {
                case .initial( _):
                    self.nowPlayingTable.reloadData()
                case .update( _, let deletions, let insertions, let modifications):
                    
                    self.nowPlayingTable.beginUpdates()
                    self.nowPlayingTable.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self.nowPlayingTable.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self.nowPlayingTable.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self.nowPlayingTable.endUpdates()
                    
                    break
                case .error( _):
                    break;
                }
            }
            
        }

        self.hideTitles(hide: true)

        
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
        

        //        if let routeButton = airPlayPicker.subviews.last as? UIButton,
        //            let routeButtonTemplateImage  = routeButton.currentImage?.withRenderingMode(.alwaysTemplate)
        //        {
        ////            airPlayPicker.setRouteButtonImage(routeButtonTemplateImage, for: .normal)
        //        }

    }

    func hideTitles(hide:Bool) {
        if self.nowPlayingItemButton != nil && self.nowPlayingTitle != nil {
            self.nowPlayingItemButton.isHidden = hide
            self.nowPlayingTitle.isHidden = hide
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }

    @IBAction func expandPlayer() {
        self.baseViewController.playerMove()
        self.hideTitles(hide: self.baseViewController.playerIsExpanded)
    }

    @IBAction func playerUp() {
        self.baseViewController.showFullPlayer(true)
        self.hideTitles(hide: true)
    }

    @IBAction func playerDown() {
        self.baseViewController.showFullPlayer(false)
        self.hideTitles(hide: false)
    }
    
    @IBAction func didPressButton(_ sender:UIButton){
        
        if(sender == self.playButton){
            IAPlayer.sharedInstance.didTapPlayButton()
        } else if sender == self.forwardButton {
            IAPlayer.sharedInstance.advancePlaylist()
        } else if sender == self.backwardButton {
            IAPlayer.sharedInstance.reversePlaylist()
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
            let seakTime:CMTime = CMTimeMakeWithSeconds(sec, preferredTimescale: 600)
            player.seek(to: seakTime)
            IAPlayer.sharedInstance.updatePlayerTimes()
        }
    }
    
    
    @IBAction func pushDoc(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushDoc"), object: nil)
    }
    
    
    //MARK: Remote
    override func remoteControlReceived(with event: UIEvent?) {
        print("----------->: revceived remote control event: \(String(describing: event))")

        if IAPlayer.sharedInstance.avPlayer != nil {
            
            if (event!.type == UIEvent.EventType.remoteControl) {
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
    
    func displayNowPlayingTitle(message:String) {
        
        nowPlayingBannerLabel.text = message
        
        UIView.animate(withDuration: 0.33, animations: {
            self.nowPlayingBanner.alpha = 1.0
        }) { (complete) in
            
            UIView.animate(withDuration: 0.33, delay: 2.0, options: [], animations: {
                self.nowPlayingBanner.alpha = 0.0
            }, completion: nil)
        }
        
    }
    
    
}

extension IAPlayerViewController: UITableViewDelegate, UITableViewDataSource {

    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playerTableFiles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nowPlayingCell", for: indexPath) as! NowPlayingTableViewCell
        
        let file = playerTableFiles[indexPath.row]
        cell.titleLabel.text = file.displayTitle
        cell.subTitleLabel.text = file.archiveTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Player.playPlaylist(list: playList!, start: indexPath.row)
    }
    
    
}

let Player = IAPlayer.sharedInstance

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
    
    typealias PlaylistWithIndex = (list:IAList, index:Int)
    var playingPlaylistWithIndex: PlaylistWithIndex?
    
    func playFile(file:IAFile, doc:IAArchiveDoc){
        
        self.fileTitle = file.title ?? file.name
        self.fileIdentifierTitle = doc.title
        self.fileIdentifier = doc.identifier
        self.playUrl = doc.fileUrl(file: file)

        self.loadAndPlay()
    }
    
    func playFile(file:IAPlayerFile, playListWithIndex:PlaylistWithIndex? = nil) {
        
        let archive = RealmManager.archives(identifier: file.archiveIdentifier).first
        
        self.fileTitle = file.displayTitle
        self.fileIdentifierTitle = archive?.title
        self.fileIdentifier = file.archiveIdentifier
        
        var playerUrl:URL?
        
        if file.downloaded {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileUrl = documentsURL.appendingPathComponent(file.urlString)
            playerUrl = fileUrl
        } else {
            
            if let escapedString = file.urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                playerUrl = URL(string:escapedString)
            }
        }
        
        if let url = playerUrl {
            print("--------> playerUrl: \(url.absoluteString)")
            self.playUrl = url
            self.loadAndPlay(playListWithIndex: playListWithIndex)
        }
    }
    
    func playPlaylist(list:IAList, start:Int) {
        
        RealmManager.syncPlaylist(files: Array(list.files), list: RealmManager.nowPlayingList())
        
        let startFile =  list.files[start] //RealmManager.nowPlayingList().files.filter("playlistOrder == \(start)").first?.file
        self.playFile(file: startFile, playListWithIndex: (list:RealmManager.nowPlayingList(), index:start))
    }
    

    
    private func loadAndPlay(playListWithIndex:PlaylistWithIndex? = nil) {
        
        if playUrl.absoluteString.contains("http") {
            guard IAReachability.isConnectedToNetwork() else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "networkAlert"), object: nil)
                return
            }
        }
        
        if let player = avPlayer {
            player.pause()
            
            if(self.observing) {
                player.removeObserver(self, forKeyPath: "rate", context: &observerContext)
                self.observing = false
            }
            
            if let controller = self.controlsController, controller.playingProgress != nil {
                controller.playingProgress.setValue(Float(0), animated: false)
            }
            
            self.setPlayingInfo(playing: false)
            avPlayer = nil
        }
        
        self.setActiveAudioSession()
        
        if let controller = controlsController {
            controller.nowPlayingTitle.text = self.fileTitle
            controller.nowPlayingItemButton.setTitle(self.fileIdentifierTitle, for: .normal)
            controller.displayNowPlayingTitle(message: self.fileTitle!)
        }

        avPlayer = AVPlayer(url: self.playUrl as URL)
        
        avPlayer?.addObserver(self, forKeyPath: "rate", options:.new, context: &observerContext)
        self.observing = true
        
        avPlayer?.play()
        self.setPlayingInfo(playing: true)
        
        if let pI = playListWithIndex {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            self.controlsController?.playList = pI.list
            self.playingPlaylistWithIndex = pI
            
            NotificationCenter.default.addObserver(self, selector: #selector(IAPlayer.continuePlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
    }
    
    @objc func continuePlaying() {
        advancePlaylist()
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

    func advancePlaylist() {
        if let pI = playingPlaylistWithIndex {
            let nextIndex = pI.index + 1
            if nextIndex < pI.list.files.count {
                Player.playPlaylist(list: pI.list, start: nextIndex)
            }
        }
    }
    
    func reversePlaylist() {
        if let pI = playingPlaylistWithIndex {
            let previousIndex = pI.index - 1
            if previousIndex >= 0 {
                Player.playPlaylist(list: pI.list, start: previousIndex)
            }
        }
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let player = avPlayer, let controller = controlsController {
            
            if player == object as! AVPlayer && "rate" == keyPath {
                print("rate changed: \(player.rate)")
                
                if player.rate == 0 {
                    controller.playButton.setIAIcon(.iosPlayOutline, forState: UIControl.State())
                } else {
                    controller.playButton.setIAIcon(.iosPauseOutline, forState: UIControl.State())
                }
                
                self.playing  = player.rate > 0.0
                if controller.activityIndicator != nil {
                    player.rate > 0.0 ? controller.activityIndicator.startAnimating() : controller.activityIndicator.stopAnimating()
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
            
            imageView.af.setImage(
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
                    controller.minTime.text = IAStringUtils.timeFormatted(self.elapsedSeconds())
                }
                if controller.maxTime != nil {
                    controller.maxTime.text = IAStringUtils.timeFormatted(Int(calcTime))
                }
            }
        }
    }
    
    func setActiveAudioSession(){
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        }
        catch {
            fatalError("Failure to session: \(error)")
        }
    }
    
}
