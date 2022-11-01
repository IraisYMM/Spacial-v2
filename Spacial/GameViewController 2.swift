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
        
        //        //let scene = GKScene(fileNamed: "GameScene"){
        //
        //            // Get the SKScene from the loaded GKScene
        //            if let sceneNode = scene.rootNode as! GameScene? {
        //
        //                // Copy gameplay related content over to the scene
        //                sceneNode.entities = scene.entities
        //                sceneNode.graphs = scene.graphs
        //
        //                // Set the scale mode to scale to fit the window
        //                sceneNode.scaleMode = .aspectFill
        //
        //                // Present the scene
        //                if let view = self.view as! SKView? {
        //                    view.presentScene(sceneNode)
        //
        //                    view.ignoresSiblingOrder = true
        //
        //                    view.showsFPS = true
        //                    view.showsNodeCount = true
        //                }
        //            }
        //        }
        //    }
        
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
