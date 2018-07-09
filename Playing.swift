//
//  Playing.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Michael Briscoe on 1/16/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class Playing: GKState {
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
    func randomDirection() -> CGFloat {
        let speedFactor: CGFloat = 2.0
        if scene.randomFloat(from: 0.0, to: 100.0) >= 50 {
            return -speedFactor
        } else {
            return speedFactor
        }
    }
  override func didEnter(from previousState: GKState?) {
    if previousState is WaitingForTap {
        let enemy = scene.childNode(withName: EnemyCategoryName) as! SKSpriteNode
        let enemy2 = scene.childNode(withName: EnemyCategoryName) as! SKSpriteNode

        enemy.physicsBody!.applyImpulse(CGVector(dx: randomDirection(), dy: randomDirection()))
        enemy2.physicsBody!.applyImpulse(CGVector(dx: randomDirection(), dy: randomDirection()))

        
    }

  }
  
  override func update(deltaTime seconds: TimeInterval) {
    var enemy = scene.childNode(withName: EnemyCategoryName) as! SKSpriteNode
    var maxSpeed: CGFloat = 380

    var xSpeed = sqrt(enemy.physicsBody!.velocity.dx * enemy.physicsBody!.velocity.dx)
    var ySpeed = sqrt(enemy.physicsBody!.velocity.dy * enemy.physicsBody!.velocity.dy)
    
    var speed = sqrt(enemy.physicsBody!.velocity.dx * enemy.physicsBody!.velocity.dx + enemy.physicsBody!.velocity.dy * enemy.physicsBody!.velocity.dy)

    if xSpeed <= 20.0 {
        enemy.physicsBody!.applyImpulse(CGVector(dx: randomDirection() + 15, dy: 0.0 + 15))
    }
    if ySpeed <= 20.0 {
        enemy.physicsBody!.applyImpulse(CGVector(dx: 0.0 + 15, dy: randomDirection() + 15))
    }
    if speed > maxSpeed {
        enemy.physicsBody!.linearDamping = 0.45
    } else {
        enemy.physicsBody!.linearDamping = 0.0
    }
    
    enemy = scene.childNode(withName: Enemy2CategoryName) as! SKSpriteNode
    
     xSpeed = sqrt(enemy.physicsBody!.velocity.dx * enemy.physicsBody!.velocity.dx)
     ySpeed = sqrt(enemy.physicsBody!.velocity.dy * enemy.physicsBody!.velocity.dy)
    
     speed = sqrt(enemy.physicsBody!.velocity.dx * enemy.physicsBody!.velocity.dx + enemy.physicsBody!.velocity.dy * enemy.physicsBody!.velocity.dy)
    
    if xSpeed <= 20.0 {
        enemy.physicsBody!.applyImpulse(CGVector(dx: randomDirection() + 15, dy: 0.0 + 15))
    }
    if ySpeed <= 20.0 {
        enemy.physicsBody!.applyImpulse(CGVector(dx: 0.0 + 15, dy: randomDirection() + 15))
    }
    if speed > maxSpeed {
        enemy.physicsBody!.linearDamping = 0.45
    } else {
        enemy.physicsBody!.linearDamping = 0.0
    }
    
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is GameOver.Type
  }

}
