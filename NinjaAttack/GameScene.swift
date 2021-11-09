import SpriteKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

struct PhysicsCategory {
  static let none: UInt32 = 0
  static let all: UInt32 = UInt32.max
  static let monster: UInt32 = 0b1       // 1
  static let projectile: UInt32 = 0b10   // 2
}

class GameScene: SKScene {
  //1
  let player = SKSpriteNode(imageNamed: "ninja")
  
  override func didMove(to view: SKView) {
    backgroundColor = .white
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    addChild(player)
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run(addMonster),
        SKAction.wait(forDuration: 1.0)
      ])
    ))
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random() / 0xFFFFFFFF))
  }

  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }
  
  func addMonster() {
    let monster = SKSpriteNode(imageNamed: "monster")
    
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
    monster.physicsBody?.isDynamic = true
    monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
    monster.physicsBody?.collisionBitMask = PhysicsCategory.none
    
      // Position the monster slightly off-screen along the right edge,
      // and along a random position along the Y axis as calculated above
//      monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
    monster.position = CGPoint(x: size.width, y: CGFloat.random(in: 0...size.height))
      
      // Add the monster to the scene
      addChild(monster)
      
      // Determine speed of the monster
    let actualDuration = CGFloat.random(in: 2.0...4.0)
  
      // Create the actions
    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: CGFloat.random(in: 0...size.height)),
                                     duration: TimeInterval(actualDuration))
      let actionMoveDone = SKAction.removeFromParent()
      monster.run(SKAction.sequence([actionMove, actionMoveDone]))
   }
  
  func flyBalloon() {
    let balloon = SKSpriteNode(imageNamed: Color.allCases.randomElement()?.rawValue ?? Color.red.rawValue)
    
//    balloon.position = CGPoint(x: size.width / 2, y: 0) //position centred
    balloon.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: 0) //random
    addChild(balloon)
    
    let actualDuration = CGFloat.random(in: 4.0...6.0)
    
    ///move straight up
//    let actualMove = SKAction.move(to: CGPoint(x: size.width/2, y: size.height), duration: TimeInterval(actualDuration)) //move straight up
    
    ///move up more towards left
    //let min = size.height/2
//    let max = size.height - size.height/2
    //let actualMove = SKAction.move(to: CGPoint(x: CGFloat.random(in: min...max), y: size.height), duration: TimeInterval(actualDuration))
    
    ///move both the sides distributed
    let max = size.width
    let actualMove = SKAction.move(to: CGPoint(x: CGFloat.random(in: 0...max), y: size.height), duration: TimeInterval(actualDuration))
    
    let actionMoveDone = SKAction.removeFromParent()
    balloon.run(SKAction.sequence([actualMove, actionMoveDone]))
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    
    let touchLocation = touch.location(in: self)
    
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position
    
    let offset = touchLocation - projectile.position
    
    if offset.x < 0 { return }
    addChild(projectile)
    
    let direction = offset.normalized()
    
    let shootAmount = direction * 1000
    
    let realDestination = shootAmount + projectile.position
    
    let actionMove = SKAction.move(to: realDestination, duration: 2.0)
    let actionMoveDone = SKAction.removeFromParent()
    projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
}

extension GameScene: SKPhysicsContactDelegate {
  
}

public enum Color: String, CaseIterable {
  case blue = "balloon_blue"
  case brown = "balloon_brown"
  case cyan = "balloon_cyan"
  case green = "balloon_green"
  case lime = "balloon_lime"
  case olive = "balloon_olive"
  case orange = "balloon_orange"
  case pink = "balloon_pink"
  case purple = "balloon_purple"
  case red = "balloon_red"
  case yellow = "balloon_yellow"
}


