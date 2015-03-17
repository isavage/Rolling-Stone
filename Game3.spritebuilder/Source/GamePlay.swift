import Foundation

class GamePlay: CCNode, CCPhysicsCollisionDelegate {
    
    var _scrollSpeed : CGFloat = 80
    var _heroSpeed : CGFloat = 120
    
    var _hero : CCSprite!
    var _pnode1 : CCPhysicsNode!
    var _pnode2 : CCPhysicsBody!
    
    var _cloud1 : CCSprite!
    var _cloud2 : CCSprite!
    var _cloud3 : CCSprite!
    var _cloud4 : CCSprite!
    
    var _clouds : [CCSprite] = []
   
    var _bricks : [CCNode] = []
    let _firstBrickPosx : CGFloat = 20
    let _firstBrickPosy : CGFloat = 60
    
    var _sinceTouch : CCTime = 0
    
    var _restart : CCButton!
    var _restartText : CCLabelTTF!
    var _gameOver = false
    
    var in_the_air : Bool!
    
    func didLoadFromCCB() {
    
    
    _clouds.append(_cloud1)
    _clouds.append(_cloud2)
    _clouds.append(_cloud3)
    _clouds.append(_cloud4)
    
    _pnode1.collisionDelegate = self
    self.userInteractionEnabled = true

    
    self.spawnNewBrick()
    self.spawnNewBrick()
    self.spawnNewBrick()
    self.spawnNewBrick()
    self.spawnNewBrick()
    
    
}
    

override func update(delta: CCTime) {
    
    //Code to smooth the speed
    /*
    CGFloat forwardVel = _hero.physicsBody.velocity.dx;
    forwardVel += 20.0;
    if (forwardVel > bMaxForwardVelocity) {
        forwardVel = bMaxForwardVelocity;
    }
    _ball.physicsBody.velocity = CGVectorMake(forwardVel, _ball.physicsBody.velocity.dy);
    }
    */
    
    
    //Move and rotate the coin
    _hero.physicsBody.velocity.x = _heroSpeed
    _hero.physicsBody.angularVelocity = _heroSpeed
    
    
    // Move coin and bricks to generate camera effect
    _pnode1.position = ccp(_pnode1.position.x - _scrollSpeed * CGFloat(delta), _pnode1.position.y)
    
    
    // Move clouds .. little slower than the camera
    for cloud in _clouds {
        cloud.position = ccp(cloud.position.x - (0.3 * _scrollSpeed * CGFloat(delta)), cloud.position.y)
    }
    
    // loop the clouds
    for cloud in _clouds {
        if cloud.position.x <= (-cloud.contentSize.width) {
            cloud.position = ccp(cloud.position.x + cloud.contentSize.width * 4, cloud.position.y)
        }
    }
    
    
    // Increase/Decrease scroll speed as per the hero
    if _scrollSpeed > _hero.physicsBody.velocity.x{
        _scrollSpeed = _scrollSpeed - 1
    }
    else if _scrollSpeed < _hero.physicsBody.velocity.x{
            _scrollSpeed = _scrollSpeed + 1
    }
    
    // Increase duration since touch to prevent touch action
    _sinceTouch += delta
    

    // Clamping hero's velocity
    

//    let velocityY = clampf(Float(_hero.physicsBody.velocity.y), -Float(CGFloat.max), 500)
  //  _hero.physicsBody.velocity.y = CGFloat(velocityY)
    
    // println(velocityY)

    
    for brick in _bricks.reverse() {
        let brickWorldPosition = _pnode1.convertToWorldSpace(brick.position)
        let brickScreenPosition = self.convertToNodeSpace(brickWorldPosition)
        
        // obstacle moved past left side of screen?
        if brickScreenPosition.x < (-brick.contentSize.width) {
            brick.removeFromParent()
            _bricks.removeAtIndex(find(_bricks, brick)!)
            
            // for each removed obstacle, add a new one
            self.spawnNewBrick()
            self.spawnNewBrick()
            self.spawnNewBrick()

            
        }
    }

    
    if _hero.position.y  < 0 {
    self.gameOver()
    }
    
    }

override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        _sinceTouch = 0
    }
    
override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        println(_sinceTouch)
        if (_gameOver == false) {
            // Touch action .. Checks continuous touches
            if in_the_air == false {
                _hero.physicsBody.applyImpulse(ccp(0, CGFloat(clampf(Float(CGFloat(_sinceTouch) * 1000 ),100,200))))
                _hero.physicsBody.applyAngularImpulse(10000)
                in_the_air = true
            }
            
        }
    }

func spawnNewBrick() {
    
    var prevBrickPosx : CGFloat!
    var prevBrickPosy : CGFloat!
    
    var size : CGSize = CCDirector.sharedDirector().viewSize()
    //println (size)
    
    var random_result = self.randomDistance()
    
    var brick_pos_x = _firstBrickPosx
    var brick_pos_y = _firstBrickPosy
    
    var nbr_bricks = 3
    
    if _bricks.count > 0 {
    prevBrickPosx = _bricks.last!.position.x
    prevBrickPosy = _bricks.last!.position.y
        
    brick_pos_x = prevBrickPosx + random_result.X
    brick_pos_y = prevBrickPosy + random_result.Y
        
    nbr_bricks = Int(random_result.Count)-1
    }
    
    var brick : [CCNode!] = []
    for i in 0...nbr_bricks {
    brick.append (CCBReader.load("Brick"))
    }
    
    var i : CGFloat = 0
    for sprite in brick{
    sprite.position = ccp(brick_pos_x + (sprite.contentSize.width * i), CGFloat(clampf(Float(brick_pos_y), 0, Float(size.height) * 0.6)))
    i++
    _pnode1.addChild(sprite)
    _bricks.append(sprite)
    }

    }
    

    func randomDistance() -> (X: CGFloat, Y : CGFloat, Sign : CGFloat, Count : CGFloat){
        
    var y_min = 0
    var y_max = 30
    var x_min = 100
    var x_max = 250
    
    var result : (X: CGFloat, Y : CGFloat, Sign : CGFloat, Count : CGFloat )
        
    result.Sign = 0
        
    var random_nbr = CGFloat(arc4random_uniform(1))
        if random_nbr == 0 {
        result.Sign = CGFloat(-1) }
        else if random_nbr == 1 {
        result.Sign = CGFloat(1) }
        
    result.Count = CGFloat(arc4random_uniform(2) + 2)
        
    result.X = CGFloat(x_min + Int(arc4random_uniform(UInt32(x_max - x_min))))
        
    result.Y = CGFloat(y_min + Int(arc4random_uniform(UInt32(y_max - y_min))))
      
    return result
    }

 
func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, brick: CCNode!) -> Bool {
    in_the_air = false
        return true
    }

 


    
func gameOver() {
        if (_gameOver == false) {
            _gameOver = true
            _restart.visible = true
            _restartText.visible = true
            _scrollSpeed = 0
            _heroSpeed = 0
         //   _hero.rotation = 90
          //  _hero.physicsBody.allowsRotation = false
            
            // just in case
            _hero.stopAllActions()
            
            var move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)))
            var moveBack = CCActionEaseBounceOut(action: move.reverse())
            var shakeSequence = CCActionSequence(array: [move, moveBack])
            self.runAction(shakeSequence)
        }
    }
    
func restart() {
        var scene = CCBReader.loadAsScene("GamePlay")
        CCDirector.sharedDirector().replaceScene(scene)
    }


}
