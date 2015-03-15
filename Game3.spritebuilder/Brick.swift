//
//  Brick.swift
//  Game3
//
//  Created by Varun Sharma on 3/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Brick : CCNode {
    
    var _brick : CCNode!
    
    var y_min = 0
    var y_max = 30
    var x_min = 150
    var x_max = 400
 
    
    func setupRandomPosition() {
        
        
        result.append (x_min + Int(arc4random_uniform(x_max - x_min)))
        result.append (y_min + Int(arc4random_uniform(y_max - y_min)))
        let _randomPrecision : UInt32 = 100
        let random = CGFloat(arc4random_uniform(_randomPrecision)) / CGFloat(_randomPrecision)
        let range = _bottomPipeMaximumPositionY - _pipeDistance - _topPipeMinimumPositionY
        _topPipe.position = ccp(_topPipe.position.x, _topPipeMinimumPositionY + (random * range));
        _bottomPipe.position = ccp(_bottomPipe.position.x, _topPipe.position.y + _pipeDistance);
        
        setupRandomPosition
    }
}