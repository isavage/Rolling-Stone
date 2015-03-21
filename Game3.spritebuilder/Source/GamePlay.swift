import Foundation

class GamePlay: CCNode, CCPhysicsCollisionDelegate {
    
    var _scrollSpeed : CGFloat = 80
    var _heroSpeed : CGFloat = 150
    
    var _hero : CCSprite!
    //var _brick_end : CCNode!
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
    var _score :CCLabelTTF!
    var _points : Int = 0
    var _congrats : CCLabelTTF!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var highscore : Int!
    var congrats_off : Bool = true
    var _time : CCTime = 0
    
    var _new_high : Bool = false
    
    
    
func didLoadFromCCB() {
    
    
   // _clouds.append(_cloud1)
   // _clouds.append(_cloud2)
   // _clouds.append(_cloud3)
   // _clouds.append(_cloud4)
    
    _pnode1.collisionDelegate = self
    self.userInteractionEnabled = true
    
    highscore = prefs.integerForKey("highscore")
    println("Latest High Score" + String(highscore))
   
    
    //_brick_end.physicsBody.sensor = true
    
    
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
    _hero.physicsBody.angularVelocity = -10
    
    // Move coin and bricks to generate camera effect
    _pnode1.position = ccp(_pnode1.position.x - _scrollSpeed * CGFloat(delta), _pnode1.position.y)
    
    
//    // Move clouds .. little slower than the camera
//    for cloud in _clouds {
//        cloud.position = ccp(cloud.position.x - (0.3 * _scrollSpeed * CGFloat(delta)), cloud.position.y)
//    }
//    
//    // loop the clouds
//    for cloud in _clouds {
//        if cloud.position.x <= (-cloud.contentSize.width) {
//            cloud.position = ccp(cloud.position.x + cloud.contentSize.width * 4, cloud.position.y)
//        }
//    }
    
    
    // Increase/Decrease scroll speed as per the hero
    if _scrollSpeed > _hero.physicsBody.velocity.x{
        _scrollSpeed = _scrollSpeed - 1
    }
    else if _scrollSpeed < _hero.physicsBody.velocity.x{
            _scrollSpeed = _scrollSpeed + 2
    }
    
    // Increase duration since touch to prevent touch action
    _sinceTouch += delta
    

    // Clamping hero's velocity

   let velocityY = clampf(Float(_hero.physicsBody.velocity.y), -Float(CGFloat.max), 300)
    _hero.physicsBody.velocity.y = CGFloat(velocityY)
    

    
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
    
     _points += Int(_hero.physicsBody.velocity.x/100)
    _score.string = String(_points)
    println(_score)
    
    
    
    if !(_new_high){
    if _points > highscore  {
        println("New High")
       self.congrats("begin")
        _new_high = true
    }
    }
    
    
    if !(congrats_off) {
        if (_time < 2 ) {
         _congrats.fontSize =  CGFloat(Int(_congrats.fontSize) + 1)
            _time += delta }
        else {
            congrats_off = true
            self.congrats("end")
        }
    }

    
    if _hero.position.y  < 0 {
    self.gameOver()
    }
    
    }

override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
    println("touch")
        _sinceTouch = 0
    }
    
override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        println(_sinceTouch)
            println( in_the_air)
        if (_gameOver == false) {
            // Touch action .. Checks continuous touches
            if in_the_air == false {
                
                _hero.physicsBody.applyImpulse(ccp(0, CGFloat(clampf(Float(CGFloat(_sinceTouch) * 1000 ),100,200))))
                println(clampf(Float(CGFloat(_sinceTouch) * 1000),100,200))
                _hero.physicsBody.applyAngularImpulse(10000)
                in_the_air = true
            }
            
        }
    }

func spawnNewBrick() {
    
    var prevBrickPosx : CGFloat!
    var prevBrickPosy : CGFloat!
    
    var size : CGSize = CCDirector.sharedDirector().viewSize()
    
    var random_result = self.randomDistance()
    
    var brick_pos_x = _firstBrickPosx
    var brick_pos_y = _firstBrickPosy
    
    var nbr_bricks = 3
    
    if _bricks.count > 0 {
    prevBrickPosx = _bricks.last!.position.x
    prevBrickPosy = _bricks.last!.position.y
        
    brick_pos_x = prevBrickPosx + random_result.X
    brick_pos_y = CGFloat(clampf(Float(prevBrickPosy + random_result.Y), 0, Float(size.height) * 0.6))
        
    nbr_bricks = Int(random_result.Count)-1
    }
    
    var brick_grp : [CCNode!] = []
    for i in 0...nbr_bricks {
    brick_grp.append (CCBReader.load("Brick"))
    }
    
    var i : CGFloat = 0
    for sprite in brick_grp{
    sprite.position = ccp(brick_pos_x + ( 0.9 * sprite.contentSize.width * i), brick_pos_y)
    i++
    _pnode1.addChild(sprite)
    _bricks.append(sprite)
    }
    
    var brick_end : CCNode! = CCBReader.load("Brick_end")
    
    brick_end.position = ccp(_bricks.last!.position.x + ( _bricks.last!.contentSize.width), _bricks.last!.position.y)
    _pnode1.addChild(brick_end)
    _bricks.append(brick_end)

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
    println (in_the_air)
        return true
    }

    func ccPhysicsCollisionSeparate(pair: CCPhysicsCollisionPair!, hero: CCNode!, end: CCNode!) -> Bool {
        in_the_air = true
    println (in_the_air)
        return true
    }

 


    
func gameOver() {
        if (_gameOver == false) {
            _gameOver = true
            _restart.visible = true
            _restartText.visible = true
            _scrollSpeed = 0
            _heroSpeed = 0

            
            // just in case
            _hero.stopAllActions()
            
          //  var userDefaults = NSUserDefaults.standardUserDefaults()
            
            if _points > highscore {
            prefs.setValue(_points, forKey: "highscore")
            prefs.synchronize() // don't forget this!!!!
            }
            
            //prefs.setValue(200, forKey: "highscore")
            
            println(highscore)
            
            var move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)))
            var moveBack = CCActionEaseBounceOut(action: move.reverse())
            var shakeSequence = CCActionSequence(array: [move, moveBack])
            self.runAction(shakeSequence)
        }
    }
    
    func congrats(show : String) {
        println ("congrats")
        
        if (show == "begin" ) {
            _congrats.visible = true
            congrats_off = false
            _time = 0
        }
        else if (show == "end" ) {
        _congrats.visible = false
        }
    }
    
func restart() {
        var scene = CCBReader.loadAsScene("GamePlay")
        CCDirector.sharedDirector().replaceScene(scene)
    }


}
