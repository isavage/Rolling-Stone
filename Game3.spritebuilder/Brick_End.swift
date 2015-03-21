//
//  Brick_End.swift
//  Game3
//
//  Created by Varun Sharma on 3/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Brick_End: CCNode
{
    func didLoadFromCCB() {
        self.physicsBody.sensor = true;
    }
}