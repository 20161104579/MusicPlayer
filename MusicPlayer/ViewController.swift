//
//  ViewController.swift
//  MusicPlayer
//
//  Created by chenrui on 2019/1/6.
//  Copyright © 2019年 Andy Chen. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var playbackSlider: UISlider!
    
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let url = URL(string: "http://www.kuwo.cn/yinyue/666715/")
        playerItem = AVPlayerItem(url:url!)
        player = AVPlayer(playerItem: playerItem!)
        
        let duration :CMTime = playerItem!.asset.duration
        let seconds : Float32 = Float32(CMTimeGetSeconds(duration))
        playbackSlider!.minimumValue = 0
        playbackSlider!.maximumValue = Float(seconds)
        playbackSlider!.isContinuous = false
        
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1),
                                        queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
            //更新进度条进度值
            let currentTime = CMTimeGetSeconds(self.player!.currentTime())
            self.playbackSlider!.value = Float(currentTime)
                                                
            //一个小算法，来实现00：00这种格式的播放时间
            let all:Int=Int(currentTime)
            let m:Int=all % 60
            let f:Int=Int(all/60)
            var time:String=""
            if f<10 {
                time="0\(f):"
            }else {
                time="\(f)"
            }
            if m<10{
                time+="0\(m)"
            }else {
                time+="\(m)"
            }
            //更新播放时间
            self.playTime!.text=time
            }
        }
    }
    
    @IBAction func playButtonTap(_ sender: Any) {
        if player?.rate == 0 {
            player!.play()
            playButton.setTitle("暂停", for: .normal)
        } else {
            player!.pause()
            playButton.setTitle("播放", for: .normal)
        }
    }
    
    @IBAction func playbackSliderValueChange(_ sender: Any) {
        let seconds : Int32 = Int32(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: Int64(Int32(seconds)), timescale: 1)
        //播放器定位到对应的位置
        player!.seek(to: targetTime)
        //如果当前时暂停状态，则自动播放
        if player!.rate == 0
        {
            player?.play()
            playButton.setTitle("暂停", for: .normal)
        }
    }
    //拖动进度条改变值时触发
    //页面显示时添加歌曲播放结束通知监听
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(finishedPlaying),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    //页面消失时取消歌曲播放结束通知监听
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //歌曲播放完毕
    @objc func finishedPlaying(myNotification:NSNotification) {
        print("播放完毕!")
        let stopedPlayerItem = myNotification.object as! AVPlayerItem
        stopedPlayerItem.seek(to: CMTime.zero, completionHandler: nil)
        playButton.setTitle("播放", for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

