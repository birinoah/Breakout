//
//  ViewController.swift
//  Breakout
//
//  Created by Noah Safian on 5/17/16.
//  Copyright © 2016 Noah Safian. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UICollisionBehaviorDelegate {

    let defaults = NSUserDefaults.standardUserDefaults()
    
    // DEAL WITH LANDSCAPE
    @IBOutlet weak var gameView: UIView! {
        didSet {
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handlePan:"))
        }
    }
    
    var numRows = 4
    
    var rowDensity = 6
    
    var percentBricks: CGFloat = 0.34
    
    var bricks = Dictionary<String, UIView>()
    
    var gameOver = false
    
    var beginnerMode = false
    
    var brickColor = UIColor.orangeColor()
    
    var ballAccelScale: CGFloat = 0.5
    
    var brickSize: CGSize {
        get {
            let height = gameView.bounds.height * percentBricks / CGFloat(numRows)
            let width = gameView.bounds.width / CGFloat(rowDensity)
            return CGSize(width: width, height: height)
        }
    }
    
    var paddleSize: CGSize {
        get {
            let height = gameView.bounds.height / CGFloat(20)
            let width = gameView.bounds.width / CGFloat(4)
            return CGSize(width: width, height: height)
        }
    }
    
    var paddleCenter: CGPoint {
        get {
            return CGPoint(x: gameView.center.x, y: gameView.bounds.height - gameView.bounds.height * 0.15)
        }
    }
    
    var ballCenter: CGPoint {
        get {
            return CGPoint(x: paddleCenter.x, y: paddleCenter.y - paddleSize.height / 2.0)
        }
    }
    
    var ballSize: CGSize {
        let measure = min(gameView.bounds.width, gameView.bounds.height)
        let diameter = measure / CGFloat(8)
        return CGSize(width: diameter, height: diameter)
    }
    
    var paddle: UIView = UIView()
    var ball = UIView()
    
    private static let brickBorderWidth: CGFloat = 1
    private static let ballBorderWidth: CGFloat = 2
    
    lazy var animator: UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return lazyAnimator
    }()
    
    private static func createBallBehavior() -> UIDynamicItemBehavior {
        let behavior = UIDynamicItemBehavior()
        behavior.friction = 0
        behavior.resistance = 0
        behavior.allowsRotation = false
        behavior.elasticity = 1
        return behavior
    }
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        return BreakoutViewController.createBallBehavior()
    }()
    
    private static func createBreakoutBehavior() -> BreakoutBehavior {
        let brickBehavior = BreakoutBehavior()
        return brickBehavior
    }
    
    lazy var breakoutBehavior: BreakoutBehavior = {
        return BreakoutViewController.createBreakoutBehavior()
        }()
    
    private static func createPushBehavior() -> UIPushBehavior {
        let pushBehavior = UIPushBehavior(items: [], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = 0.35
        pushBehavior.active = false
        return pushBehavior
    }
    
    lazy var pushOnTapBehavior: UIPushBehavior = {
        return BreakoutViewController.createPushBehavior()
    }()
    
    func removeBrick(row: Int, col: Int, id: String) {
        if let brick = bricks[id] {
            UIView.animateWithDuration(0.5,
                                       animations: { brick.backgroundColor = UIColor.blackColor() },
                                       completion: { if $0 { brick.removeFromSuperview() }
            })
            
//            brick.removeFromSuperview()
            
            breakoutBehavior.removeBoundaryWithIdenfier(id)
            gameView.setNeedsDisplay()
            
            bricks.removeValueForKey(id)
            
            if bricks.count == 0 {
                endGame(true)
            }
        }
        

    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        
        if let id = identifier as? String {
            let regex = try! NSRegularExpression(pattern: "^[0-9]+ [0-9]+$", options: [])
            let results: [NSTextCheckingResult] = regex.matchesInString(id, options: [], range: NSString(string: id).rangeOfString(id))
            
            if results.count == 1 {
                let numRegex = try! NSRegularExpression(pattern: "[0-9]+", options: [])
                let numResults = numRegex.matchesInString(id, options: [], range: NSString(string: id).rangeOfString(id))
                let nsString = id as NSString
                
                let row = Int(nsString.substringWithRange(numResults[0].range))!
                let col = Int(nsString.substringWithRange(numResults[1].range))!
                removeBrick(row, col: col, id: id)
            }
            
        } else if p.y >= gameView.bounds.height-10 {
            if !gameOver && !beginnerMode {
                let attachmentBehavior = UIAttachmentBehavior(item: ball, attachedToAnchor: CGPoint(x: p.x - ball.frame.size.width/2.0, y: p.y - ball.frame.size.height/2.0))
                attachmentBehavior.length = 0
                animator.addBehavior(attachmentBehavior)
                breakoutBehavior.removeItem(ball)
                ballBehavior.removeItem(ball)
                endGame(false)
            }
        }
        
    }
    
    func endGame(won: Bool) {
        gameOver = true
        
        var resultText = ""
        
        if won {
            resultText = "won"
        } else {
            resultText = "lost"
        }
        let alertVC = UIAlertController(title: "You \(resultText)!", message: "Click Okay to play again", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            self.setupGame()
            self.gameView.setNeedsDisplay()
        }
        
        alertVC.addAction(okAction)
        
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .Ended:
            pushOnTapBehavior.angle = CGFloat(Double(arc4random()) % (2 * M_PI))
            pushOnTapBehavior.active = true
            
        default:
            break
        }
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            let translation = recognizer.translationInView(gameView)
            
            self.tryMovePaddle(translation.x)
            
            // reset translation
            recognizer.setTranslation(CGPointZero, inView: gameView)
            
        default:
            break
        }
    }
    
    func createBall() -> UIView {
        let origin = CGPoint(x: ballCenter.x - ballSize.height/CGFloat(2), y: ballCenter.y - ballSize.height/CGFloat(2))
        let ball = UIView(frame: CGRect(origin: origin, size: ballSize))
        ball.layer.cornerRadius = ball.frame.size.width/2
        ball.clipsToBounds = true
        
        ball.layer.borderWidth = BreakoutViewController.ballBorderWidth
        ball.layer.borderColor = UIColor.whiteColor().CGColor
        return ball
    }
    
    func setupBall() {
        ball = createBall()
        gameView.addSubview(ball)
        ballBehavior.addItem(ball)
        breakoutBehavior.addItem(ball)
        pushOnTapBehavior.addItem(ball)
    }
    
    func createPaddle() -> UIView {
        let origin = CGPoint(x: paddleCenter.x - paddleSize.width/CGFloat(2), y: paddleCenter.y - paddleSize.height/CGFloat(2))
        let frame = CGRect(origin: origin, size: paddleSize)
        let paddle = UIView(frame: frame)
        
        paddle.backgroundColor = UIColor.whiteColor()
        
        return paddle
    }
    
    private var paddleBoundaryIdentifier = "paddle"
    
    func tryMovePaddle(dx: CGFloat) {
        breakoutBehavior.removeBoundaryWithIdenfier(paddleBoundaryIdentifier)
        
        let size = paddleSize
        
        var newOriginX = paddle.frame.origin.x + dx
        
        if newOriginX + size.width > gameView.bounds.width {
            newOriginX = gameView.bounds.width - size.width
        }
        
        if newOriginX < 0 {
            newOriginX = 0
        }
        
        paddle.frame = CGRect(origin: CGPoint(x: newOriginX, y: paddle.frame.origin.y), size: size)
        
        breakoutBehavior.addBoundaryWithIdentifier(paddleBoundaryIdentifier, forPath: UIBezierPath(rect: paddle.frame))
    }
    
    func setupPaddle() {
        paddle = createPaddle()
        let boundary = UIBezierPath(rect: paddle.frame)
        
        gameView.addSubview(paddle)
        breakoutBehavior.addBoundaryWithIdentifier(paddleBoundaryIdentifier, forPath: boundary)
    }
    
    func setupBehaviors() {
        breakoutBehavior.collisionDelegate = self
        animator.addBehavior(breakoutBehavior)
        animator.addBehavior(ballBehavior)
        animator.addBehavior(pushOnTapBehavior)
    }
    
    func resetGame() {
        animator = UIDynamicAnimator(referenceView: gameView)
        pushOnTapBehavior.removeItem(ball)
        pushOnTapBehavior.magnitude = ballAccelScale * ballSize.height * ballSize.height / 750.0
        breakoutBehavior = BreakoutBehavior()
        ballBehavior = BreakoutViewController.createBallBehavior()
        gameView.removeAllSubviews()
        gameOver = false
    }
    
    func updateSettings() {
        numRows = defaults.integerForKey(SettingsKeys.numRowsKey)
        rowDensity = defaults.integerForKey(SettingsKeys.numColsKey)
        ballAccelScale = CGFloat(defaults.doubleForKey(SettingsKeys.tapStrengthKey))
        
        if let newColor = defaults.colorForKey(SettingsKeys.brickColorKey){
            brickColor = newColor
        }
        beginnerMode = defaults.boolForKey(SettingsKeys.beginnerModeKey)
    }
    
    private func setupGame() {
        resetGame()
        
        updateSettings()
        
        let size = brickSize
        for i in 0..<numRows {
//            var row = [UIView]()
            for j in 0..<rowDensity {
                let frame = CGRect(origin: CGPoint(x: size.width * CGFloat(j), y: size.height * CGFloat(i)), size: size)
                let view = UIView(frame: frame)
                view.backgroundColor = brickColor
                view.layer.borderWidth = BreakoutViewController.brickBorderWidth
                view.layer.borderColor = UIColor.blackColor().CGColor
                gameView.addSubview(view)
                
                let id = "\(i) \(j)"
                
                bricks[id] = view
                
                let boundary = UIBezierPath(rect: frame)
                breakoutBehavior.addBoundaryWithIdentifier("\(i) \(j)", forPath: boundary)
            }
//            bricks.append(row)
        }
        
        setupBall()
        setupPaddle()
        setupBehaviors()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults.registerDefaults({
            var dic = Dictionary<String,AnyObject>()
            dic[SettingsKeys.beginnerModeKey] = beginnerMode
            dic[SettingsKeys.numColsKey] = rowDensity
            dic[SettingsKeys.numRowsKey] = numRows
            dic[SettingsKeys.tapStrengthKey] = ballAccelScale
            
            let colorData = NSKeyedArchiver.archivedDataWithRootObject(brickColor)
            dic[SettingsKeys.brickColorKey] = colorData
            
            return dic
        }() )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGame()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        resetGame()
    }


}

extension UIView {
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}

private extension UIColor {
    class var random: UIColor {
        switch arc4random() % 5 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        default: return UIColor.blackColor()
        }
    }
}

