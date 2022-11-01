//
//  GameScene.swift
//  Spacial
//
//  Created by IYMM on 30/10/22.
//

import SpriteKit
import GameplayKit


var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    var lastUpdateTime : TimeInterval = 0.0
    var dt : TimeInterval = 0.0
   
    let scoreLabel = SKLabelNode(fontNamed : "Game-Font")
    
    var livesNumber = 3
    let liveslabel =  SKLabelNode(fontNamed: "Game-Font")
    
    var levelNumber = 0
    
    let player = SKSpriteNode(imageNamed: "PlayerShip")//jugador principal
    let bulletSound = SKAction.playSoundFileNamed("laser", waitForCompletion: false) // sonido de disparo
    let explosionSound = SKAction.playSoundFileNamed("explosion", waitForCompletion: false) // sonido explosion
    
    let tapToStartLabel = SKLabelNode(fontNamed: "Game-Font")
    
   var onGround = true
    var velocityY : CGFloat = 0.0
    
    enum gameState{
        case preGame // antes del juego
        case inGame // durante el juego
        case afterGame // despues del juego
        }
    var currentGameState = gameState.preGame
    
    
    //
    struct PhysicsCategories{
        static let None: UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Bullet :UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //4
    }
    //------ enemigos
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    //-----AREA DE JUEGO
    var gameArea : CGRect //Area de juego (margen)
    override init(size: CGSize){
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth)/2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //BAKGROUND
    
    override func didMove(to view: SKView) {
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self //
        for i in 0...1{
            let background = SKSpriteNode(imageNamed: "Background")//fondo
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2,
                                          y: self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
        }
        //   let player = SKSpriteNode(imageNamed: "PlayerShip")//jugador principal
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15 , y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        
        // los que se pasan sin matar
        liveslabel.text = "Lives: 3"
        liveslabel.fontSize = 70
        liveslabel.fontColor = SKColor.white
        liveslabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        liveslabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height + liveslabel.frame.size.height)
        liveslabel.zPosition  = 3
        self.addChild(liveslabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        liveslabel.run(moveOnToScreenAction)
        
        // para dar play
        
        tapToStartLabel.text = "PLAY"
        tapToStartLabel.fontSize = 250
        tapToStartLabel.fontColor = SKColor.yellow
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
    }
    
    var lastupdateTime: TimeInterval = 0
    var deltaFrameTime : TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
            self.enumerateChildNodes(withName: "Background"){background, stop in
                
                if self.currentGameState == gameState.inGame{
                    background.position.y -= amountToMoveBackground
                }
                if background.position.y < -self.size.height{
                    background.position.y += self.size.height*2
                }
            }
        }
        
    
        func startGame(){
            currentGameState = gameState.inGame
            let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
            let deleteAction = SKAction.removeFromParent()
            let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
            tapToStartLabel.run(deleteSequence)
            
            let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5 )
            let startLevelAction = SKAction.run(startNewLavel)
            let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
            player.run(startGameSequence)
        }
    
    func pause(){
        currentGameState = gameState.inGame
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.0)
        tapToStartLabel.run(fadeOutAction)
        
    }
    func panel(){
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.zPosition = 60.0
        panel.position = .zero
        self.addChild(panel)
        
        let resume = SKSpriteNode(imageNamed: "reanudar")
        resume.zPosition = 70.0
        resume.name = "reanudar"
        resume.setScale(0.7)
        resume.position = CGPoint(x: self.size.width/2 + resume.size.width+1.5, y: 0.0)
        panel.addChild(resume)
        
        let quit = SKSpriteNode(imageNamed: "Salir")
        quit.zPosition = 70.0
        quit.name = "quit"
        quit.setScale(0.7)
        quit.position = CGPoint(x: self.size.width/2 - quit.size.width*1.5, y:0.0)
        panel.addChild(quit)
        
    
    }
    
    //  de los que se quedan vivos
    func loseALife(){
        livesNumber -= 1
        liveslabel.text = "Lives: \(livesNumber)"


        let scaleUp  = SKAction.scale(by:1, duration: 0.2)
        let scaleDown = SKAction.scale(by: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        liveslabel.run(scaleSequence)
        
        if livesNumber == 0{
            runGameOver()
        }
        
    }
    
    func addScore(){
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLavel()
        }
    }
    func runGameOver(){
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 0.5)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    
    func changeScene(){
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.10)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            // si al jugador le pega el enemigo
            
            if body1.node != nil{
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            runGameOver()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height{
            addScore()
            //si la bala le pega al enemigo
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
          // runGameOver()
        }
    }
        
//EXPLOCION
        func spawnExplosion(spawnPosition: CGPoint){
            let explosion = SKSpriteNode(imageNamed: "Explosion")
            explosion.position = spawnPosition
            explosion.zPosition = 3
            explosion.setScale(1)
            self.addChild(explosion)
            
            let scaleIn = SKAction.scale(by: 1, duration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            let delete = SKAction.removeFromParent()
            
            let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
            explosion.run(explosionSequence)
            
        }
            
        
    //jsjsjs
    
    //FUNCION PARA JUGADOR ENEMIGO
    func startNewLavel(){
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber{
        case 1 : levelDuration = 1.2
        case 2 : levelDuration = 1
        case 3 : levelDuration = 0.8
        case 4 : levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("No se encontro el nivel")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSquence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSquence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    
    //funcion para las balas
    func fireBullet(){
        let bullet = SKSpriteNode(imageNamed: "Bullet")
        bullet.name = "Bullet"
        bullet.setScale(0.5)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    //--Personaje enemigo
    func spawnEnemy(){
        let randomXStart = random(min: CGRectGetMinX(gameArea),max: CGRectGetMaxX(gameArea))
        let randomXEnd = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "Enemigo")
        enemy.name = "Enemy"
        enemy.setScale(0.5)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.x - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
           startGame()
        }
        
        else if  currentGameState == gameState.inGame{
            fireBullet()
        }
        
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {return}
        let node = atPoint(touch.location(in:self))
        
        if node.name == "Pause"{
            if isPaused{return}
            panel()
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = true
        }else if node.name == "Reanudar"{
            self.removeFromParent()
            isPaused = false
        }else if node.name == "quit"{
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        }else{
            if !isPaused{
                if onGround{
                    onGround = false
                    velocityY = -25.0
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            
            if currentGameState == gameState.inGame{
            player.position.x += amountDragged
            }
            //----------- rango de juego (marco)
            if player.position.x > CGRectGetMaxX(gameArea) - player.size.width/2{
                player.position.x = CGRectGetMaxX(gameArea) - player.size.width/2
            }
            if player.position.x < CGRectGetMinX(gameArea) + player.size.width/2{
                player.position.x = CGRectGetMinX(gameArea) + player.size.width/2
            }
        }
    }
}

  
