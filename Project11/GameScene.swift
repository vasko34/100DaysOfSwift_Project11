import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    var ballsLeftLabel: SKLabelNode!
    var boxesLeftLabel: SKLabelNode!
    let colorsDictionary = [1: "Blue", 2: "Cyan", 3: "Green", 4: "Grey", 5: "Purple", 6: "Red", 7: "Yellow"]
    var boxes = [SKSpriteNode]()
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editingMode = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    var ballsLeft = 5 {
        didSet {
            ballsLeftLabel.text = "Balls Left: \(ballsLeft)"
        }
    }
    var boxesLeft = 0 {
        didSet {
            boxesLeftLabel.text = "Boxes Left: \(boxesLeft)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 710)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 710)
        addChild(editLabel)
        
        ballsLeftLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLeftLabel.text = "Balls Left: \(ballsLeft)"
        ballsLeftLabel.horizontalAlignmentMode = .right
        ballsLeftLabel.position = CGPoint(x: 980, y: 660)
        addChild(ballsLeftLabel)
        
        boxesLeftLabel = SKLabelNode(fontNamed: "Chalkduster")
        boxesLeftLabel.text = "Boxes Left: \(boxesLeft)"
        boxesLeftLabel.horizontalAlignmentMode = .right
        boxesLeftLabel.position = CGPoint(x: 980, y: 610)
        addChild(boxesLeftLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        let y = 0
        
        callSlut(at: CGPoint(x: 128, y: y), isGood: true)
        callSlut(at: CGPoint(x: 384, y: y), isGood: false)
        callSlut(at: CGPoint(x: 640, y: y), isGood: true)
        callSlut(at: CGPoint(x: 896, y: y), isGood: false)
        
        callBouncer(at: CGPoint(x: 0, y: y))
        callBouncer(at: CGPoint(x: 256, y: y))
        callBouncer(at: CGPoint(x: 512, y: y))
        callBouncer(at: CGPoint(x: 768, y: y))
        callBouncer(at: CGPoint(x: 1024, y: y))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        if objects.contains(editLabel) {
            if !editingMode {
                ballsLeft = 5
                score = 0
                for box in boxes {
                    box.removeFromParent()
                }
                boxesLeft = 0
            }
            editingMode.toggle()
        } else {
            if editingMode {
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = CGPoint(x: location.x, y: location.y > 600 ? 600 : location.y)
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.name = "box"
                addChild(box)
                boxesLeft += 1
                boxes.append(box)
            } else {
                if let color = colorsDictionary[Int.random(in: 1...7)] {
                    if ballsLeft > 0 {
                        let ball = SKSpriteNode(imageNamed: "ball\(color)")
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
                        ball.physicsBody?.restitution = 0.4
                        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                        ball.position = CGPoint(x: location.x, y: 600)
                        ball.name = "ball"
                        addChild(ball)
                        ballsLeft -= 1
                    }
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodaA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodaA.name == "ball" {
            collision(between: nodaA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodaA)
        }
    }
    
    func callBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func callSlut(at position: CGPoint, isGood: Bool) {
        var slutBase: SKSpriteNode
        var slutGlow: SKSpriteNode
        
        if isGood {
            slutBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slutGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slutBase.name = "good"
        } else {
            slutBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slutGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slutBase.name = "bad"
        }
        
        slutBase.position = position
        slutGlow.position = position
        slutBase.physicsBody = SKPhysicsBody(rectangleOf: slutBase.size)
        slutBase.physicsBody?.isDynamic = false
        addChild(slutGlow)
        addChild(slutBase)
        
        let aids = SKAction.rotate(byAngle: .pi, duration: 10)
        let aidsForever = SKAction.repeatForever(aids)
        slutGlow.run(aidsForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball)
            score += 1
            ballsLeft += 1
        } else if object.name == "bad" {
            destroy(ball)
            if score > 0 {
                score -= 1
            }
            if ballsLeft == 0 {
                let ac = UIAlertController(title: "Game Over", message: "You have no more balls left.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "New Game", style: .default) { [weak self] _ in
                    self?.ballsLeft = 5
                    self?.score = 0
                    if let boxes = self?.boxes {
                        for box in boxes {
                            box.removeFromParent()
                        }
                        self?.boxesLeft = 0
                    }
                })
                if let vc = self.view?.window?.rootViewController {
                    vc.present(ac, animated: true)
                }
            }
        } else if object.name == "box" {
            object.removeFromParent()
            boxesLeft -= 1
            if boxesLeft == 0 {
                let ac = UIAlertController(title: "You Won!", message: "You cleared all the boxes.\nScore: \(score)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "New Game", style: .default) { [weak self] _ in
                    self?.ballsLeft = 5
                    self?.score = 0
                    if let boxes = self?.boxes {
                        for box in boxes {
                            box.removeFromParent()
                        }
                        self?.boxesLeft = 0
                    }
                })
                if let vc = self.view?.window?.rootViewController {
                    vc.present(ac, animated: true)
                }
            }
        }
        
    }
    
    func destroy(_ object: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = object.position
            addChild(fireParticles)
        }
        
        object.removeFromParent()
    }
}
