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

//make the strings into constant names to avoid typos
let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"

//set up physics categories
let BallCategory: UInt32 = 0x1 << 0
let BottomCategory: UInt32 = 0x1 << 1
let BlockCategory: UInt32 = 0x1 << 2
let PaddleCategory: UInt32 = 0x1 << 3
let BorderCategory: UInt32 = 0x1 << 4




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isFingerOnPaddle = false
    
  
  override func didMove(to view: SKView) {
    
    super.didMove(to: view)
    
    //set up a border & apply to self
    let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    
    borderBody.friction = 0
    
    self.physicsBody = borderBody
    
    //set no gravity to this scene/world
    physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    
    //set contact delegate to this instance
    physicsWorld.contactDelegate = self
    
    //define ball as a physics body & make it move
    let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
    ball.physicsBody?.applyImpulse(CGVector(dx: 2.0, dy: -2.0))
    
    //bottom edge so can detect when you miss the ball
     let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
    
    let bottom = SKNode()
    bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
    
    addChild(bottom)
    
    //assign physics categories to the objects on screen
    let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
    
    bottom.physicsBody?.categoryBitMask = BottomCategory
    ball.physicsBody?.categoryBitMask = BallCategory
    paddle.physicsBody?.categoryBitMask = PaddleCategory
    borderBody.categoryBitMask = BorderCategory
    
    //contact bit masks - ball needs to report contact with bottom
    ball.physicsBody?.contactTestBitMask = BottomCategory | BlockCategory
    
    
    //build the blocks
    
    let numberOfBlocks = 8
    let blockWidth = SKSpriteNode(imageNamed: "block").size.width
    let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
    
    let xOffset = (frame.width - totalBlocksWidth) / 2
    
    for i in 0..<numberOfBlocks {
        
        let block = SKSpriteNode(imageNamed: "block.png")
        block.position = CGPoint(x: xOffset + CGFloat(CGFloat(i) + 0.5) * blockWidth, y: frame.height * 0.8)
        
        block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
        block.physicsBody?.allowsRotation = false
        block.physicsBody?.friction = 0
        block.physicsBody?.restitution = 1
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.isDynamic = false
        block.name = BlockCategoryName
        block.physicsBody?.categoryBitMask = BlockCategory
        block.zPosition = 2
        addChild(block)
        
    }
    
    
  }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch?.location(in: self)
        
        if let body = physicsWorld.body(at: touchLocation!) {
            if body.node!.name == PaddleCategoryName {
                print("Began touch on paddle")
                isFingerOnPaddle = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isFingerOnPaddle {
            
            let touch = touches.first
            
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            
            let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
            
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            
            
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            
            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
            
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        isFingerOnPaddle = false
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        }
        
        else {
            
            firstBody = contact.bodyB
            secondBody = contact.bodyA
            
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
            
            print("Ball hits bottom")
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
            print("ball hits block")
        }
        

        
    }
  
}
