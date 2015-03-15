import Foundation

class GamePlay: CCNode, CCPhysicsCollisionDelegate {
    
    var _scrollSpeed : CGFloat = 80
    var _heroSpeed : CGFloat = 100
    
    var _hero : CCSprite!
    var _pnode1 : CCPhysicsNode!
    var _pnode2 : CCPhysicsBody!
    
    var _cloud1 : CCSprite!
    var _cloud2 : CCSprite!
    var _cloud3 : CCSprite!
    var _cloud4 : CCSprite!
    
    var _clouds : [CCSprite] = []
   
    var _bricks : [CCNode] = []
    let _firstBrickPosx : CGFloat = 69
    let _firstBrickPosy : CGFloat = 72
    
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
   // _sinceTouch += delta
    

    // Clamping hero's velocity
    /*
    let velocityY = clampf(Float(_hero.physicsBody.velocity.y), -Float(CGFloat.max), 500)
    _hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
    */

    
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
    if (_gameOver == false) {
    // Touch action .. Checks continuous touches
    if in_the_air == false {
    _hero.physicsBody.applyImpulse(ccp(600, 3000))
    _hero.physicsBody.applyAngularImpulse(50000)
    in_the_air = true
    }
   // _sinceTouch = 0
    
    }
    }

func spawnNewBrick() {
    
    //var brick_pos_x : CGFloat!
    //var brick_pos_y : CGFloat!

    
    var prevBrickPosx = _firstBrickPosx
    var prevBrickPosy = _firstBrickPosy
    if _bricks.count > 0 {
    prevBrickPosx = _bricks.last!.position.x
    prevBrickPosy = _bricks.last!.position.y
    }
    
    let brick = CCBReader.load("Brick")
    brick.scaleX = 0.45
    brick.scaleY = 0.45
    
    var brick_pos_x = prevBrickPosx + self.randomDistance()[0]
    var brick_pos_y = prevBrickPosy + self.randomDistance()[1]
    
    if brick_pos_y >= CGFloat(175) {
        brick_pos_y = brick_pos_y - 50
    }
    else if brick_pos_y <= 40 {
        brick_pos_y = brick_pos_y + 30
    }

    brick.position = ccp(brick_pos_x, brick_pos_y)
    _pnode1.addChild(brick)
    _bricks.append(brick)

    }
    

func randomDistance() -> [CGFloat]{
        
    var y_min = 0
    var y_max = 30
    var x_min = 150
    var x_max = 300
    
    var sign = CGFloat(arc4random_uniform(2) + 1)
    
    var result : [CGFloat] = []
    result.append (CGFloat(x_min + Int(arc4random_uniform(UInt32(x_max - x_min)))))
        if sign == 1 {
    result.append (CGFloat(y_min + Int(arc4random_uniform(UInt32(y_max - y_min)))))
        }
        else if sign == 2 {
    result.append (-CGFloat(y_min + Int(arc4random_uniform(UInt32(y_max - y_min)))))
        }
    
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
            _hero.rotation = 90
            _hero.physicsBody.allowsRotation = false
            
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
