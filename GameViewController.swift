//
//  GameViewController.swift
//  Spacial
//
//  Created by IYMM on 30/10/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: CGSize(width: 1536, height: 2048))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
        func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return .allButUpsideDown
            } else{
                return .all
            }
        }
        
        var prefersStatusBarHidden: Bool {
            return true
        }
    }
}
