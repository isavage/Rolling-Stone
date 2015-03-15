//
//  Mainscene.swift
//  Game3
//
//  Created by Varun Sharma on 3/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class MainScene : CCNode {
    
func start() {
    
    var scene : CCScene = CCBReader.loadAsScene("GamePlay")
    CCDirector.sharedDirector().replaceScene(scene)
    }
}
