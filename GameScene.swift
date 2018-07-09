//
//  GameScene.swift
//  Bamboo Breakout
/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */ 

import SpriteKit
import GameplayKit


let EnemyCategoryName = "enemy"
let Enemy2CategoryName = "enemy2"
let HeartCategoryName = "heart"
let BigBoiCategoryName = "bigBoi"
let PlayerCategoryName = "player"
let HealthBarCategoryName = "healthBar"
let MonsterCategoryName = "monster"
let HealthCategoryName = "Health"
let EighteenPlusCategoryName = "Eighteenplus"
let GameMessageName = "gameMessage"


let PlayerCategory   : UInt32 = 0x1 << 0
let EnemyCategory : UInt32 = 0x1 << 1
let Enemy2Category : UInt32 = 0x1 << 1
let MonsterCategory : UInt32 = 0x1 << 2
let BigBoiCategory : UInt32 = 0x1 << 3
let HeartCategory : UInt32 = 0x1 << 4
let EighteenPlusCategory : UInt32 = 0x1 << 5

import AVFoundation



/**
 * Audio player that uses AVFoundation to play looping background music and
 * short sound effects. For when using SKActions just isn't good enough.
 */
public class SKTAudio {
    public var backgroundMusicPlayer: AVAudioPlayer?
    public var soundEffectPlayer: AVAudioPlayer?
    
    public class func sharedInstance() -> SKTAudio {
        return SKTAudioInstance
    }
    
    public func playBackgroundMusic(_ filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            backgroundMusicPlayer = nil
        }
        if let player = backgroundMusicPlayer {
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
    public func pauseBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if player.isPlaying {
                player.pause()
            }
        }
    }
    
    public func resumeBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if !player.isPlaying {
                player.play()
            }
        }
    }
    
    public func playSoundEffect(_ filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            soundEffectPlayer = nil
        }
        if let player = soundEffectPlayer {
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
}

private let SKTAudioInstance = SKTAudio()



class GameScene: SKScene, SKPhysicsContactDelegate {
    var overallTime = 0
    var invincibility_frame = false
    
    var alive = true

    var levelTimerLabel = SKLabelNode(fontNamed: "ArialMT")
    
    //Immediately after leveTimerValue variable is set, update label's text
    var levelTimerValue: Int = 0 {
        didSet {
            levelTimerLabel.text = "Current Score: \(levelTimerValue)"
        }
    }
    var player = SKSpriteNode(imageNamed: "player")

    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    var highScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highScore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "highScore")
        }
    }
 
    
    
    func addMonster() {
            let monster = SKSpriteNode(imageNamed: "monster.png")
            let choixDeCote = arc4random() % 4 + 1
            monster.size.width = 35
            monster.size.height = 35
            var SpawnX = 0
            var SpawnY = 0
            var directionX = 0
            var directionY = 0
            switch choixDeCote {
                
            case 1 : //Haut
                let MinValue = self.size.width / 8
                let MaxValue = self.size.width - 200
                let SpawnX0 = UInt32(MaxValue - MinValue)
                SpawnX = Int(arc4random_uniform(SpawnX0))
                SpawnY = Int(UInt32(self.size.height))
                directionX = Int(arc4random()) % Int(self.frame.size.width)
                directionY = 0
                break
                
            case 2 ://Bas
                let MinValue = self.size.width / 8
                let MaxValue = self.size.width - 200
                let SpawnX0 = UInt32(MaxValue - MinValue)
                SpawnX = Int(arc4random_uniform(SpawnX0))
                SpawnY = 0
                directionX = Int(arc4random()) % Int(self.frame.size.width)
                directionY = Int(self.frame.size.height)
                break
    
            case 3 : //Gauche
                let MinValue = self.size.height / 8
                let MaxValue = self.size.height - 200
                SpawnX = 0
                
                
                let SpawnY0 = UInt32(MaxValue - MinValue)
                SpawnY = Int(arc4random_uniform(SpawnY0))
                directionY = Int(arc4random()) % Int(self.frame.size.height)
                directionX = Int(self.frame.size.width)
                break
                
            case 4 ://Droite
                let MinValue = self.size.height / 8
                let MaxValue = self.size.height - 200
                SpawnX = Int(UInt32(self.size.width))
                let SpawnY0 = UInt32(MaxValue - MinValue)
                SpawnY = Int(arc4random_uniform(SpawnY0))
                directionY = Int(arc4random()) % Int(self.frame.size.height)
                directionX = 0
                break
                
            default :
                break
            }
            
        
            monster.position = CGPoint(x: CGFloat(SpawnX), y: CGFloat(SpawnY))
        
        
        
        // Add the monster to the scene
        addChild(monster)
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.categoryBitMask = MonsterCategory // 3
        monster.physicsBody?.contactTestBitMask = PlayerCategory // 4
        monster.physicsBody?.collisionBitMask = 0 // 5
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.friction = 0
        monster.physicsBody?.restitution = 0
        monster.physicsBody?.linearDamping = 0
        monster.physicsBody?.angularDamping = 0
        monster.physicsBody?.allowsRotation = false
        
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(5.0))
        
        // Create the actions
        
        let action = SKAction.move(to: CGPoint(x: CGFloat(directionX),y: CGFloat(directionY)),duration: TimeInterval(actualDuration))

        let actionMoveDone = SKAction.removeFromParent()
        monster.run(SKAction.sequence([action, actionMoveDone]))
        
        
    }

    
    func addEighteenPlus() {
        if (levelTimerValue > 30){

        let eighteenPlus = SKSpriteNode(imageNamed: "eighteenPlus.png")
        eighteenPlus.size.width = 50
        eighteenPlus.size.height = 50
        
        
        
        eighteenPlus.position = CGPoint(x: CGFloat(CGFloat(drand48()) * self.size.width), y: CGFloat(CGFloat(drand48())*self.size.height))
        
        
        // Add the heart to the scene
        addChild(eighteenPlus)
        eighteenPlus.physicsBody = SKPhysicsBody(rectangleOf: eighteenPlus.size) // 1
        eighteenPlus.physicsBody?.categoryBitMask = EighteenPlusCategory // 3
        eighteenPlus.physicsBody?.contactTestBitMask = PlayerCategory // 4
        eighteenPlus.physicsBody?.collisionBitMask = 0 // 5
        eighteenPlus.physicsBody?.affectedByGravity = false
        eighteenPlus.physicsBody?.isDynamic = true
        eighteenPlus.physicsBody?.friction = 0
        eighteenPlus.physicsBody?.restitution = 0
        eighteenPlus.physicsBody?.linearDamping = 0
        eighteenPlus.physicsBody?.angularDamping = 0
        eighteenPlus.physicsBody?.allowsRotation = false
        let change1 = SKAction.customAction(withDuration: 0) {_,_ in
            eighteenPlus.size.height = eighteenPlus.size.height+30
            eighteenPlus.size.width = eighteenPlus.size.width+30
        }
        
        let change2 = SKAction.customAction(withDuration: 0) {_,_ in
            eighteenPlus.size.height = eighteenPlus.size.height-30
            eighteenPlus.size.width = eighteenPlus.size.width-30
        }
        
        let wait = SKAction.wait(forDuration: 0.5)
        let actionMoveDone = SKAction.removeFromParent()
        eighteenPlus.run(SKAction.sequence([change1, wait, change2, wait, change1, wait, change2, wait, change1, wait, change2, wait, change1, actionMoveDone]))
        }
    }
    
    
    func addHeart() {
        let heart = SKSpriteNode(imageNamed: "heart.png")
        let choixDeCote = arc4random() % 4 + 1
        heart.size.width = 60
        heart.size.height = 60
        
        var SpawnX = 0
        var SpawnY = 0
        var directionX = 0
        var directionY = 0
        switch choixDeCote {
            
        case 1 : //Haut
            let MinValue = self.size.width / 8
            let MaxValue = self.size.width - 200
            let SpawnX0 = UInt32(MaxValue - MinValue)
            SpawnX = Int(arc4random_uniform(SpawnX0))
            SpawnY = Int(UInt32(self.size.height))
            directionX = Int(arc4random()) % Int(self.frame.size.width)
            directionY = 0
            break
            
        case 2 ://Bas
            let MinValue = self.size.width / 8
            let MaxValue = self.size.width - 200
            let SpawnX0 = UInt32(MaxValue - MinValue)
            SpawnX = Int(arc4random_uniform(SpawnX0))
            SpawnY = 0
            directionX = Int(arc4random()) % Int(self.frame.size.width)
            directionY = Int(self.frame.size.height)
            break
            
        case 3 : //Gauche
            let MinValue = self.size.height / 8
            let MaxValue = self.size.height - 200
            SpawnX = 0
            
            
            let SpawnY0 = UInt32(MaxValue - MinValue)
            SpawnY = Int(arc4random_uniform(SpawnY0))
            directionY = Int(arc4random()) % Int(self.frame.size.height)
            directionX = Int(self.frame.size.width)
            break
            
        case 4 ://Droite
            let MinValue = self.size.height / 8
            let MaxValue = self.size.height - 200
            SpawnX = Int(UInt32(self.size.width))
            let SpawnY0 = UInt32(MaxValue - MinValue)
            SpawnY = Int(arc4random_uniform(SpawnY0))
            directionY = Int(arc4random()) % Int(self.frame.size.height)
            directionX = 0
            break
            
        default :
            break
        }
        
        
        heart.position = CGPoint(x: CGFloat(SpawnX), y: CGFloat(SpawnY))
        
        
        
        // Add the heart to the scene
        addChild(heart)
        heart.physicsBody = SKPhysicsBody(rectangleOf: heart.size) // 1
        heart.physicsBody?.categoryBitMask = HeartCategory // 3
        heart.physicsBody?.contactTestBitMask = PlayerCategory // 4
        heart.physicsBody?.collisionBitMask = 0 // 5
        heart.physicsBody?.affectedByGravity = false
        heart.physicsBody?.isDynamic = true
        heart.physicsBody?.friction = 0
        heart.physicsBody?.restitution = 0
        heart.physicsBody?.linearDamping = 0
        heart.physicsBody?.angularDamping = 0
        heart.physicsBody?.allowsRotation = false
        
        
        // Determine speed of the heart
        let actualDuration = random(min: CGFloat(1.5), max: CGFloat(3.5))
        
        // Create the actions
        
        // 1
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        // 2
        let trail = SKEmitterNode(fileNamed: "BallTrail")!
        // 3
        trail.targetNode = trailNode
        // 4
        heart.addChild(trail)
        
        
        let action = SKAction.move(to: CGPoint(x: CGFloat(directionX),y: CGFloat(directionY)),duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        heart.run(SKAction.sequence([action, actionMoveDone]))
        
        
    }

    
    var gameWon : Bool = false {
        didSet {
            let gameOver = childNode(withName: GameMessageName) as! SKSpriteNode
            let textureName = gameWon ? "YouWon" : "GameOver"
            let texture = SKTexture(imageNamed: textureName)
            let actionSequence = SKAction.sequence([SKAction.setTexture(texture),
                                                    SKAction.scale(to: 1.0, duration: 0.25)])
            
            gameOver.run(actionSequence)
        }
    }
    
    var numberofHits = 0
 
    var isFingerOnPlayer = false
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
        WaitingForTap(scene: self),
        Playing(scene: self),
        GameOver(scene: self)])
    
    func isGameWon() -> Bool {
        let wait = SKAction.wait(forDuration:2.5)
        let action = SKAction.run {
            // your code here ...
        }
        run(SKAction.sequence([wait,action]))
        return false
    }

  override func didMove(to view: SKView) {
    physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    physicsWorld.contactDelegate = self
    self.size.height = 1334
    self.size.width = 750

    let enemy = childNode(withName: EnemyCategoryName) as! SKSpriteNode
    let enemy2 = childNode(withName: Enemy2CategoryName) as! SKSpriteNode

    super.didMove(to: view)
    // 1
    let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    // 2
    borderBody.friction = 0
    // 3
    self.physicsBody = borderBody
    let player = childNode(withName: PlayerCategoryName) as! SKSpriteNode

    player.physicsBody!.categoryBitMask = PlayerCategory
    enemy.physicsBody!.categoryBitMask = EnemyCategory
    enemy2.physicsBody!.categoryBitMask = Enemy2Category

    player.physicsBody!.contactTestBitMask = EnemyCategory
    player.physicsBody!.contactTestBitMask = Enemy2Category
    
    let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
    gameMessage.name = GameMessageName
    gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
    gameMessage.zPosition = 4
    gameMessage.setScale(0.0)
    addChild(gameMessage)
    
    gameState.enter(WaitingForTap.self)
    
  }
  
    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let healthBar = childNode(withName: HealthBarCategoryName) as! SKSpriteNode
        let player = childNode(withName: PlayerCategoryName) as! SKSpriteNode
        let hp = self.size.width
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        // 2
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        // 3
        if (firstBody.categoryBitMask == PlayerCategory && secondBody.categoryBitMask == EighteenPlusCategory){
            levelTimerValue += 18
        }
        else if (numberofHits > 0 && firstBody.categoryBitMask == PlayerCategory && secondBody.categoryBitMask == HeartCategory){
            let hitPoint = hp/8
            if (healthBar.size.width < hitPoint){
                healthBar.size.width = 0
            }
            else{
                healthBar.size.width = healthBar.size.width + hitPoint
            }
            numberofHits -= 1
        }
        else if (firstBody.categoryBitMask == PlayerCategory && invincibility_frame == false && (secondBody.categoryBitMask == MonsterCategory || secondBody.categoryBitMask == BigBoiCategory || secondBody.categoryBitMask == EnemyCategory || secondBody.categoryBitMask == Enemy2Category)){
            
            if (numberofHits <= 8 && secondBody.categoryBitMask == MonsterCategory){
                let hitPoint = hp/8
                if (healthBar.size.width < hitPoint){
                    healthBar.size.width = 0
                }
                else{
                    healthBar.size.width = healthBar.size.width - hitPoint
                }
                numberofHits += 1
            }
            else if (numberofHits <= 8 && (secondBody.categoryBitMask == EnemyCategory || secondBody.categoryBitMask == Enemy2Category)){
                let hitPoint = hp/4
                if (healthBar.size.width < hitPoint){
                    healthBar.size.width = 0
                }
                else{
                    healthBar.size.width = healthBar.size.width - hitPoint
                }
                numberofHits += 2
            }
            else if (numberofHits <= 8 && secondBody.categoryBitMask == BigBoiCategory){
                let hitPoint = hp/2
                if (healthBar.size.width < hitPoint){
                    healthBar.size.width = 0
                }
                else{
                    healthBar.size.width = healthBar.size.width - hitPoint
                }
                numberofHits += 4
            }
            
            let invTrue = SKAction.customAction(withDuration: 0) {_,_ in
                self.invincibility_frame=true
            }
            let change1 = SKAction.customAction(withDuration: 0) {_,_ in
                player.texture = SKTexture(imageNamed: "blurRocket")
            }
            let wait = SKAction.wait(forDuration: 5)
            let change2 = SKAction.customAction(withDuration: 0) {_,_ in
                player.texture = SKTexture(imageNamed: "redRocket")
            }
            let invFalse = SKAction.customAction(withDuration: 0.1) {_,_ in
                self.invincibility_frame=false
            }
            if (numberofHits<8){
                let sequence = SKAction.sequence([invTrue,change1,wait,change2,invFalse])
                player.run(sequence)

            }
                if numberofHits >= 8 && alive == true{
                SKTAudio.sharedInstance().pauseBackgroundMusic()
                alive = false
                overallTime = levelTimerValue
                levelTimerLabel.fontColor = SKColor.white
                let actionMoveDone = SKAction.removeFromParent()
                levelTimerLabel.run(SKAction.sequence([actionMoveDone]))
                let FinalTime = SKLabelNode(fontNamed: "ArialMT")
                FinalTime.fontColor = SKColor.white
                FinalTime.fontSize = 40
                FinalTime.position = CGPoint(x: self.size.width/2, y: self.size.width - FinalTime.fontSize*1.5 )
                FinalTime.text = "Your Final Score: \(overallTime)"
                if overallTime > highScore{
                    let HS = SKLabelNode(fontNamed: "ArialMT")
                    HS.fontColor = SKColor.red
                    HS.fontSize = 50
                    HS.position = CGPoint(x: 170, y: 200)
                    FinalTime.text = "HighScore!"
                    highScore = overallTime
                }
                player.texture = SKTexture(imageNamed: "blackRocket")
                let bigBoi = childNode(withName: BigBoiCategoryName) as! SKSpriteNode
                bigBoi.texture = SKTexture(imageNamed: "Transparent_Troll_Face")
                addChild(FinalTime)
                gameState.enter(GameOver.self)
                gameWon = false
            }
        }
    }
    
    func movebigBoi(){
        let player = childNode(withName: PlayerCategoryName) as! SKSpriteNode
        let bigBoi = childNode(withName: BigBoiCategoryName) as! SKSpriteNode
        if (levelTimerValue >= 31 ){
        let action = SKAction.move(to: CGPoint(x: CGFloat(player.position.x),y: CGFloat(player.position.y)),duration: TimeInterval(3.0))
        bigBoi.run(action)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState.currentState {
        case is WaitingForTap:
            
            SKTAudio.sharedInstance().playBackgroundMusic("Nyeh.mp3")
            gameState.enter(Playing.self)
            isFingerOnPlayer = true
            levelTimerLabel.fontColor = SKColor.white
            levelTimerLabel.fontSize = 40
            levelTimerLabel.position = CGPoint(x: self.size.width/2, y: self.size.height - levelTimerLabel.fontSize * 1.5)
            levelTimerLabel.text = "Score: \(levelTimerValue)"
            addChild(levelTimerLabel)
            
            let hs = SKLabelNode(fontNamed: "ArialMT")
            hs.fontColor = SKColor.white
            hs.fontSize = 20
            hs.position = CGPoint(x: self.size.width - hs.fontSize*3.5, y: self.size.height - hs.fontSize)
            hs.text = "Highscore: \(highScore)"
            addChild(hs)
            
            let wait = SKAction.wait(forDuration: 1) //change countdown speed here
            let block = SKAction.run({
                [unowned self] in
                
                
                self.levelTimerValue += 1
                
            })
            let sequence = SKAction.sequence([wait,block])
            run(SKAction.repeatForever(sequence), withKey: "countdown")
            
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(addMonster),
                    SKAction.wait(forDuration: 0.8)
                    ])
            ))
            
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(addHeart),
                    SKAction.wait(forDuration: 40 * drand48()+10)
                    ])
            ))
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.wait(forDuration: (30 * drand48())+10),
                    SKAction.run(addEighteenPlus),
                    SKAction.wait(forDuration: 3),
                    SKAction.run(addEighteenPlus),
                    SKAction.wait(forDuration: 3),
                    SKAction.run(addEighteenPlus)

                    ])
            ))

            
            let bigBoi = childNode(withName: BigBoiCategoryName) as! SKSpriteNode
            bigBoi.physicsBody?.categoryBitMask = BigBoiCategory // 3
            bigBoi.physicsBody?.contactTestBitMask = PlayerCategory // 4
            
            bigBoi.physicsBody?.collisionBitMask = PlayerCategory
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(movebigBoi),
                    SKAction.wait(forDuration: 0.8)
                    ])
            ))
            
        case is Playing:
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            
            if let body = physicsWorld.body(at: touchLocation) {
                if body.node!.name == PlayerCategoryName {
                    isFingerOnPlayer = true
                }
            }
            
        case is GameOver:
            let newScene = GameScene(fileNamed:"GameScene")
            newScene!.scaleMode = .aspectFit
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
            
        default:
            break
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1
        if isFingerOnPlayer {
            // 2
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            // 3
            let player = childNode(withName: PlayerCategoryName) as! SKSpriteNode
            // 4
            var playerX = player.position.x + (touchLocation.x - previousLocation.x)
            var playerY = player.position.y + (touchLocation.y - previousLocation.y)

            // 5
            playerX = max(playerX, player.size.width/2)
            playerX = min(playerX, size.width - player.size.width/2)
            playerY = max(playerY, player.size.height/2)
            playerY = min(playerY, size.height - player.size.height/2)

            // 6
            player.position = CGPoint(x: playerX, y: playerY)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        gameState.update(deltaTime: currentTime)
    }
  
}
