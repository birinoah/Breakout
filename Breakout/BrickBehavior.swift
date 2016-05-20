//
//  BrickBehavior.swift
//  Breakout
//
//  Created by Noah Safian on 5/17/16.
//  Copyright © 2016 Noah Safian. All rights reserved.
//

import Foundation
import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    
    var collisionDelegate: UICollisionBehaviorDelegate? {
        didSet {
            collider.collisionDelegate = collisionDelegate
        }
    }
    
    override init() {
        super.init()
        addChildBehavior(collider)
    }
    
    lazy var collider: UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        lazyCollider.translatesReferenceBoundsIntoBoundary = true
        return lazyCollider
    }()

    
    func addItem(item: UIDynamicItem) {
        collider.addItem(item)
    }
    
    func addBoundaryWithIdentifier(identifier: NSCopying, forPath path: UIBezierPath)
    {
        collider.addBoundaryWithIdentifier(identifier, forPath: path)
    }
    
    func removeBoundaryWithIdenfier(identifier: NSCopying)
    {
        collider.removeBoundaryWithIdentifier(identifier)
    }
    
    func removeItem(item: UIDynamicItem) {
        collider.removeItem(item)
    }
    
    func resetColliderBoundaries() {
        collider.removeAllBoundaries()
    }
    
}