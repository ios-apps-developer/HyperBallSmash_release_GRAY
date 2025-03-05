import SpriteKit
import SwiftUI

class GameSceneHBS: SKScene, SKPhysicsContactDelegate {
    var gameDelegate: GameSceneDelegateHBS?
    var gameManager: GameManagerHBS?
    var shopManager: ShopManagerHBS?
    private var score = 0 { didSet { gameDelegate?.didUpdateScoreHBS(score) } }
    private var livesHBS = 3 { didSet { gameDelegate?.didUpdateLivesHBS(livesHBS) } }
    private var level: Int = 1
    private var paddleHBS: SKSpriteNode!
    private var ballHBS: SKSpriteNode!
    private var initialBallPositionHBS: CGPoint!
    private var isBallInPlayHBS = false
    private let ballCategoryHBS: UInt32 = 0x1 << 0
    private let paddleCategoryHBS: UInt32 = 0x1 << 1
    private let blockCategoryHBS: UInt32 = 0x1 << 2
    private let borderCategoryHBS: UInt32 = 0x1 << 3
    private var bonusEffectTimerHBS: Timer?
    private var isFlippedHBS = false
    private var lastPaddleVelocityHBS: CGVector = .zero
    private var lastTouchTimeHBS: TimeInterval = 0
    private var lastTouchPositionHBS: CGPoint?
    private var extraBallsHBS: [SKSpriteNode] = []
    private let minBallSpeedHBS: CGFloat = 400
    private let maxBallSpeedHBS: CGFloat = 800
    private var lastBallPositionHBS: CGPoint?
    private var stuckCheckCounterHBS: Int = 0
    
    init(level: Int, shopManager: ShopManagerHBS) {
        self.level = level
        self.shopManager = shopManager
        super.init(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        setupBackground()
        setupBorders()
        setupPaddle()
        setupBall()
        createLevel()
        score = 0
        livesHBS = 3
        gameDelegate?.didUpdateScoreHBS(score)
        gameDelegate?.didUpdateLivesHBS(livesHBS)
    }

    private func createLevel() {
        let blockColors = ["block_blueHBS", "block_greenHBS", "block_pinkHBS", "block_yellowHBS", "block_bonusHBS"]
        let blockWidth: CGFloat = 80
        let blockHeight: CGFloat = 55
        let horizontalPadding: CGFloat = 5
        let verticalPadding: CGFloat = 5
        let startY = size.height - 150
        
        switch level {
        case 1:
            createBasicPattern(blockWidth: blockWidth, blockHeight: blockHeight,
                              hPadding: horizontalPadding, vPadding: verticalPadding,
                              startY: startY, colors: blockColors)
        default:
            createRandomPattern(blockWidth: blockWidth, blockHeight: blockHeight,
                              hPadding: horizontalPadding, vPadding: verticalPadding,
                              startY: startY, colors: blockColors)
        }
    }

    private func createBasicPattern(blockWidth: CGFloat, blockHeight: CGFloat,
                                    hPadding: CGFloat, vPadding: CGFloat,
                                    startY: CGFloat, colors: [String])
    {
        let columnsCount = Int((size.width + hPadding)/(blockWidth + hPadding))
        let startX = (size.width - (CGFloat(columnsCount) * (blockWidth + hPadding) - hPadding))/2
        
        for row in 0..<6 {
            for column in 0..<columnsCount {
                let x = startX + blockWidth/2 + CGFloat(column) * (blockWidth + hPadding)
                let y = startY - CGFloat(row) * (blockHeight + vPadding)
                let randomValue = Int.random(in: 1...100)
                let color = if randomValue <= 10 {
                    "block_bonusHBS"
                } else {
                    colors[row % (colors.count - 1)]
                }
                
                let block = createBlock(at: CGPoint(x: x, y: y), color: color)
                addChild(block)
            }
        }
    }

    private func createPyramidPattern(blockWidth: CGFloat, blockHeight: CGFloat,
                                      hPadding: CGFloat, vPadding: CGFloat,
                                      startY: CGFloat, colors: [String])
    {
        let maxRows = 6
        let maxColumns = 11
        let centerX = size.width/2
        
        for row in 0..<maxRows {
            let blocksInRow = maxColumns - (row * 2)
            let rowWidth = CGFloat(blocksInRow) * (blockWidth + hPadding) - hPadding
            let startX = centerX - rowWidth/2 + blockWidth/2
            
            for column in 0..<blocksInRow {
                let x = startX + CGFloat(column) * (blockWidth + hPadding)
                let y = startY - CGFloat(row) * (blockHeight + vPadding)
                
                let randomValue = Int.random(in: 1...100)
                let color = if randomValue <= 10 {
                    "block_bonusHBS"
                } else {
                    colors[row % (colors.count - 1)]
                }
                
                let block = createBlock(at: CGPoint(x: x, y: y), color: color)
                addChild(block)
            }
        }
    }

    private func createDiamondPattern(blockWidth: CGFloat, blockHeight: CGFloat,
                                      hPadding: CGFloat, vPadding: CGFloat,
                                      startY: CGFloat, colors: [String])
    {
        let maxRows = 7
        let maxColumns = 7
        let centerX = size.width/2
        let middleRow = maxRows/2
        
        for row in 0..<maxRows {
            let distanceFromMiddle = abs(row - middleRow)
            let blocksInRow = maxColumns - (distanceFromMiddle * 2)
            let rowWidth = CGFloat(blocksInRow) * (blockWidth + hPadding) - hPadding
            let startX = centerX - rowWidth/2 + blockWidth/2
            
            for column in 0..<blocksInRow {
                let x = startX + CGFloat(column) * (blockWidth + hPadding)
                let y = startY - CGFloat(row) * (blockHeight + vPadding)
                
                let randomValue = Int.random(in: 1...100)
                let color = if randomValue <= 10 {
                    "block_bonusHBS"
                } else {
                    colors[row % (colors.count - 1)]
                }
                
                let block = createBlock(at: CGPoint(x: x, y: y), color: color)
                addChild(block)
            }
        }
    }

    private func createRandomPattern(blockWidth: CGFloat, blockHeight: CGFloat,
                                     hPadding: CGFloat, vPadding: CGFloat,
                                     startY: CGFloat, colors: [String])
    {
        let columnsCount = Int((size.width + hPadding)/(blockWidth + hPadding))
        let rowsCount = 6
        let startX = (size.width - (CGFloat(columnsCount) * (blockWidth + hPadding) - hPadding))/2
        
        for row in 0..<rowsCount {
            for column in 0..<columnsCount {
                if Int.random(in: 1...100) <= 70 {
                    let x = startX + blockWidth/2 + CGFloat(column) * (blockWidth + hPadding)
                    let y = startY - CGFloat(row) * (blockHeight + vPadding)
                    
                    let randomValue = Int.random(in: 1...100)
                    let color = if randomValue <= 10 {
                        "block_bonusHBS"
                    } else {
                        colors[Int.random(in: 0...(colors.count - 2))]
                    }
                    
                    let block = createBlock(at: CGPoint(x: x, y: y), color: color)
                    addChild(block)
                }
            }
        }
    }

    private func createBlock(at position: CGPoint, color: String) -> SKSpriteNode {
        let block = SKSpriteNode(imageNamed: color)
        block.size = CGSize(width: 80, height: 55)
        block.position = position
        block.zPosition = 1
        block.name = color
        
        block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
        block.physicsBody?.isDynamic = false
        block.physicsBody?.categoryBitMask = blockCategoryHBS
        block.physicsBody?.contactTestBitMask = ballCategoryHBS
        
        return block
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isBallInPlayHBS {
            launchBall()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        var newX = paddleHBS.position.x + (location.x - previousLocation.x)
        newX = max(paddleHBS.size.width/2, min(size.width - paddleHBS.size.width/2, newX))
        paddleHBS.position.x = newX
        if !isBallInPlayHBS {
            ballHBS.position = CGPoint(x: newX, y: paddleHBS.position.y + paddleHBS.size.height/2 + ballHBS.size.height/2 + 5)
        }
    }

    private func launchBall() {
        guard !isBallInPlayHBS else { return }
        ballHBS.physicsBody?.isDynamic = true
        isBallInPlayHBS = true
        
        let speed: CGFloat = 600
        
        let angle = CGFloat.random(in: -CGFloat.pi/4...CGFloat.pi/4)
        let dx = speed * sin(angle)
        let dy = speed * cos(angle)
        if ballHBS.position.y < paddleHBS.position.y + paddleHBS.size.height {
            resetBallPosition()
        }
        
        ballHBS.physicsBody?.velocity = CGVector(dx: dx, dy: abs(dy))
    }

    private func resetBallPosition() {
        ballHBS.physicsBody?.isDynamic = false
        let ballStartY = paddleHBS.position.y + paddleHBS.size.height/2 + ballHBS.size.height/2 + 5
        ballHBS.position = CGPoint(x: paddleHBS.position.x, y: ballStartY)
        ballHBS.physicsBody?.velocity = .zero
        ballHBS.physicsBody?.angularVelocity = 0
        
        isBallInPlayHBS = false
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == ballCategoryHBS | paddleCategoryHBS {
            let ball = (contact.bodyA.categoryBitMask == ballCategoryHBS) ? contact.bodyA.node : contact.bodyB.node
            if let ballPhysics = ball?.physicsBody {
                let currentVelocity = ballPhysics.velocity
                let speed = sqrt(currentVelocity.dx * currentVelocity.dx + currentVelocity.dy * currentVelocity.dy)
                
                let newDx = currentVelocity.dx + (lastPaddleVelocityHBS.dx * 0.8)
                let newDy = abs(currentVelocity.dy)
                let newSpeed = sqrt(newDx * newDx + newDy * newDy)
                let speedFactor = speed/newSpeed
                
                ballPhysics.velocity = CGVector(
                    dx: newDx * speedFactor,
                    dy: newDy * speedFactor
                )
            }
        }
        
        if collision == ballCategoryHBS | blockCategoryHBS {
            let block = contact.bodyA.categoryBitMask == blockCategoryHBS ?
                contact.bodyA.node : contact.bodyB.node
            if let blockName = block?.name {
                print("Block hit: \(blockName)")
                let points = calculatePoints(for: blockName)
                score += points
                showPointsLabel(points: points, at: block?.position ?? .zero)
                
                if blockName == "block_bonusHBS" {
                    activateRandomBonus()
                }
            }
            
            block?.removeFromParent()
            
            print("Checking remaining blocks...")
            let remainingBlocks = children.filter { node in
                if let physicsBody = node.physicsBody {
                    return physicsBody.categoryBitMask == blockCategoryHBS
                }
                return false
            }
            print("Remaining blocks count: \(remainingBlocks.count)")
            print("Block names: \(remainingBlocks.compactMap { $0.name })")
            
            if remainingBlocks.isEmpty {
                print("Level completed! Triggering win condition")
                gameManager?.levelStatesHBS[level] = .completed
                if level < 20 {
                    gameManager?.levelStatesHBS[level + 1] = .inProgress
                }
                DispatchQueue.main.async { [weak self] in
                    self?.gameDelegate?.didEndGameHBS(winHBS: true)
                }
            }
        }
        
        if collision == ballCategoryHBS | borderCategoryHBS {
            if ballHBS.position.y < paddleHBS.position.y {
                livesHBS -= 1
                if livesHBS > 0 {
                    resetBallPosition()
                } else {
                    gameDelegate?.didEndGameHBS(winHBS: false)
                }
            }
            guard let ballPhysics = ballHBS.physicsBody else { return }
            
            let currentSpeed = sqrt(
                ballPhysics.velocity.dx * ballPhysics.velocity.dx +
                    ballPhysics.velocity.dy * ballPhysics.velocity.dy
            )
            let randomFactor = CGFloat.random(in: -0.1...0.1)
            ballPhysics.velocity = CGVector(
                dx: ballPhysics.velocity.dx * (1 + randomFactor),
                dy: ballPhysics.velocity.dy * (1 + randomFactor)
            )
            let newSpeed = sqrt(
                ballPhysics.velocity.dx * ballPhysics.velocity.dx +
                    ballPhysics.velocity.dy * ballPhysics.velocity.dy
            )
            let speedFactor = currentSpeed/newSpeed
            
            ballPhysics.velocity = CGVector(
                dx: ballPhysics.velocity.dx * speedFactor,
                dy: ballPhysics.velocity.dy * speedFactor
            )
        }
    }

    private func activateRandomBonus() {
        let randomBonus = Int.random(in: 0...5)
        
        switch randomBonus {
        case 0:
            createSecondBall()
        case 1:
            flipPaddleControl()
        case 2:
            enlargePaddle()
        case 3:
            enlargeBall()
        case 4:
            shrinkPaddle()
        case 5:
            speedUpBall()
        default:
            break
        }
        showBonusLabel()
    }

    private func createSecondBall() {
        let newBall = SKSpriteNode(imageNamed: UserDefaults.standard.string(forKey: "selectedBallHBS") ?? "ball1HBS")
        newBall.size = ballHBS.size
        newBall.position = ballHBS.position
        newBall.zPosition = 1
        
        newBall.physicsBody = SKPhysicsBody(circleOfRadius: newBall.size.width/2)
        newBall.physicsBody?.categoryBitMask = ballCategoryHBS
        newBall.physicsBody?.contactTestBitMask = paddleCategoryHBS | blockCategoryHBS | borderCategoryHBS
        newBall.physicsBody?.collisionBitMask = paddleCategoryHBS | blockCategoryHBS | borderCategoryHBS
        newBall.physicsBody?.restitution = 1.0
        newBall.physicsBody?.linearDamping = 0
        newBall.physicsBody?.angularDamping = 0
        newBall.physicsBody?.friction = 0
        newBall.physicsBody?.allowsRotation = false
        newBall.physicsBody?.isDynamic = true
        newBall.physicsBody?.affectedByGravity = false
        let speed: CGFloat = 600
        let angle = CGFloat.random(in: -CGFloat.pi/4...CGFloat.pi/4)
        let dx = speed * sin(angle)
        let dy = abs(speed * cos(angle))
        newBall.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
        
        addChild(newBall)
        extraBallsHBS.append(newBall)
    }

    private func flipPaddleControl() {
        isFlippedHBS = true
        let flipAction = SKAction.scaleX(to: -1, duration: 0.3)
        paddleHBS.run(flipAction)
        bonusEffectTimerHBS?.invalidate()
        bonusEffectTimerHBS = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.isFlippedHBS = false
            self?.paddleHBS.run(SKAction.scaleX(to: 1, duration: 0.3))
        }
    }

    private func enlargePaddle() {
        let scaleAction = SKAction.scale(to: 1.5, duration: 0.3)
        paddleHBS.run(scaleAction)
        bonusEffectTimerHBS?.invalidate()
        bonusEffectTimerHBS = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.paddleHBS.run(SKAction.scale(to: 1.0, duration: 0.3))
        }
    }

    private func enlargeBall() {
        let scaleAction = SKAction.scale(to: 2.0, duration: 0.3)
        ballHBS.run(scaleAction)
        
        bonusEffectTimerHBS?.invalidate()
        bonusEffectTimerHBS = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.ballHBS.run(SKAction.scale(to: 1.0, duration: 0.3))
        }
    }

    private func shrinkPaddle() {
        let scaleAction = SKAction.scale(to: 0.5, duration: 0.3)
        paddleHBS.run(scaleAction)
        
        bonusEffectTimerHBS?.invalidate()
        bonusEffectTimerHBS = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { [weak self] _ in
            self?.paddleHBS.run(SKAction.scale(to: 1.0, duration: 0.3))
        }
    }

    private func speedUpBall() {
        let currentVelocity = ballHBS.physicsBody?.velocity
        let speed: CGFloat = 800
        if let velocity = currentVelocity {
            let currentSpeed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
            let multiplier = speed/currentSpeed
            ballHBS.physicsBody?.velocity = CGVector(
                dx: velocity.dx * multiplier,
                dy: velocity.dy * multiplier
            )
        }
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.15)
        ])
        ballHBS.run(pulseAction)
        
        bonusEffectTimerHBS?.invalidate()
        bonusEffectTimerHBS = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            if let velocity = self?.ballHBS.physicsBody?.velocity {
                let currentSpeed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
                let multiplier = 600/currentSpeed
                self?.ballHBS.physicsBody?.velocity = CGVector(
                    dx: velocity.dx * multiplier,
                    dy: velocity.dy * multiplier
                )
            }
        }
    }

    private func calculatePoints(for blockType: String) -> Int {
        switch blockType {
        case "block_bonusHBS":
            return Int.random(in: 15...25)
        case "block_blueHBS":
            return Int.random(in: 5...10)
        case "block_greenHBS":
            return Int.random(in: 7...12)
        case "block_pinkHBS":
            return Int.random(in: 8...15)
        case "block_yellowHBS":
            return Int.random(in: 10...20)
        default:
            return 5
        }
    }

    private func showPointsLabel(points: Int, at position: CGPoint) {
        let pointsLabel = SKLabelNode(text: "+\(points)")
        pointsLabel.fontName = "Arial-Bold"
        pointsLabel.fontSize = 24
        pointsLabel.fontColor = .white
        pointsLabel.position = position
        pointsLabel.zPosition = 3
        addChild(pointsLabel)
        
        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 0.8)
        let fade = SKAction.fadeOut(withDuration: 0.8)
        let group = SKAction.group([moveUp, fade])
        let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
        pointsLabel.run(sequence)
    }

    private func showBonusLabel() {
        let bonusLabel = SKLabelNode(fontNamed: "Arial-Bold")
        bonusLabel.fontSize = 36
        bonusLabel.fontColor = .yellow
        bonusLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        bonusLabel.zPosition = 100
        addChild(bonusLabel)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, remove])
        bonusLabel.run(sequence)
    }

    deinit {
        bonusEffectTimerHBS?.invalidate()
    }

    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "bg_onbHBS")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.size = size
        background.zPosition = -1
        addChild(background)
    }

    private func setupBorders() {
        let borderBody = SKPhysicsBody(edgeLoopFrom: frame)
        borderBody.friction = 0
        borderBody.restitution = 1
        borderBody.categoryBitMask = borderCategoryHBS
        borderBody.contactTestBitMask = ballCategoryHBS
        physicsBody = borderBody
    }

    private func setupPaddle() {
        paddleHBS = SKSpriteNode(imageNamed: "block_splHBS")
        paddleHBS.size = CGSize(width: 80, height: 20)
        paddleHBS.position = CGPoint(x: size.width/2, y: 100)
        paddleHBS.zPosition = 1
        
        paddleHBS.physicsBody = SKPhysicsBody(rectangleOf: paddleHBS.size)
        paddleHBS.physicsBody?.isDynamic = false
        paddleHBS.physicsBody?.categoryBitMask = paddleCategoryHBS
        paddleHBS.physicsBody?.contactTestBitMask = ballCategoryHBS
        paddleHBS.physicsBody?.collisionBitMask = ballCategoryHBS
        paddleHBS.physicsBody?.restitution = 1.0
        
        addChild(paddleHBS)
    }

    private func setupBall() {
        let selectedBall = UserDefaults.standard.string(forKey: "selectedBallHBS") ?? "ball1HBS"
        ballHBS = SKSpriteNode(imageNamed: selectedBall)
        ballHBS.size = CGSize(width: 20, height: 20)
        ballHBS.zPosition = 1
        
        ballHBS.physicsBody = SKPhysicsBody(circleOfRadius: ballHBS.size.width/2)
        ballHBS.physicsBody?.categoryBitMask = ballCategoryHBS
        ballHBS.physicsBody?.contactTestBitMask = paddleCategoryHBS | blockCategoryHBS | borderCategoryHBS
        ballHBS.physicsBody?.collisionBitMask = paddleCategoryHBS | blockCategoryHBS | borderCategoryHBS
        ballHBS.physicsBody?.restitution = 1.0
        ballHBS.physicsBody?.linearDamping = 0
        ballHBS.physicsBody?.angularDamping = 0
        ballHBS.physicsBody?.friction = 0
        ballHBS.physicsBody?.allowsRotation = false
        ballHBS.physicsBody?.isDynamic = false
        ballHBS.physicsBody?.affectedByGravity = false
        
        addChild(ballHBS)
        resetBallPosition()
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        checkBallState()
        if let lastPosition = lastTouchPositionHBS {
            let currentPosition = paddleHBS.position
            lastPaddleVelocityHBS = CGVector(
                dx: (currentPosition.x - lastPosition.x) * 60,
                dy: 0
            )
            lastTouchPositionHBS = currentPosition
        }
        extraBallsHBS.forEach { ball in
            if ball.position.y < 0 {
                ball.removeFromParent()
                if let index = extraBallsHBS.firstIndex(of: ball) {
                    extraBallsHBS.remove(at: index)
                }
            }
        }
    }

    private func checkBallState() {
        guard let ballPhysics = ballHBS.physicsBody else { return }
        let currentSpeed = sqrt(
            ballPhysics.velocity.dx * ballPhysics.velocity.dx +
                ballPhysics.velocity.dy * ballPhysics.velocity.dy
        )
        
        if let lastPosition = lastBallPositionHBS {
            let distance = hypot(
                ballHBS.position.x - lastPosition.x,
                ballHBS.position.y - lastPosition.y
            )
            
            if distance < 1.0 {
                stuckCheckCounterHBS += 1
                if stuckCheckCounterHBS > 60 {
                    resetBallDirection()
                    stuckCheckCounterHBS = 0
                }
            } else {
                stuckCheckCounterHBS = 0
            }
        }
        
        if currentSpeed < minBallSpeedHBS || currentSpeed > maxBallSpeedHBS {
            let normalizedSpeed = min(max(currentSpeed, minBallSpeedHBS), maxBallSpeedHBS)
            let speedFactor = normalizedSpeed/currentSpeed
            
            ballPhysics.velocity = CGVector(
                dx: ballPhysics.velocity.dx * speedFactor,
                dy: ballPhysics.velocity.dy * speedFactor
            )
        }
        
        let horizontalRatio = abs(ballPhysics.velocity.dx/ballPhysics.velocity.dy)
        if horizontalRatio > 3.0 {
            adjustBallAngle()
        }
        
        lastBallPositionHBS = ballHBS.position
    }
    
    private func resetBallDirection() {
        guard let ballPhysics = ballHBS.physicsBody else { return }
        
        let speed: CGFloat = 600
        let randomAngle = CGFloat.random(in: -CGFloat.pi/4...CGFloat.pi/4)
        let directionY: CGFloat = ballHBS.position.y > size.height/2 ? -1 : 1
        
        ballPhysics.velocity = CGVector(
            dx: speed * sin(randomAngle),
            dy: speed * cos(randomAngle) * directionY
        )
    }
    
    private func adjustBallAngle() {
        guard let ballPhysics = ballHBS.physicsBody else { return }
        
        let currentSpeed = sqrt(
            ballPhysics.velocity.dx * ballPhysics.velocity.dx +
                ballPhysics.velocity.dy * ballPhysics.velocity.dy
        )
        let newDx = ballPhysics.velocity.dx * 0.7
        let signY = ballPhysics.velocity.dy > 0 ? 1.0 : -1.0
        let newDy = signY * sqrt(currentSpeed * currentSpeed - newDx * newDx)
        
        ballPhysics.velocity = CGVector(dx: newDx, dy: newDy)
    }

    func resetLevel() {
        extraBallsHBS.forEach { $0.removeFromParent() }
        extraBallsHBS.removeAll()
        children.forEach { node in
            if node.physicsBody?.categoryBitMask == blockCategoryHBS {
                node.removeFromParent()
            }
        }
        
        bonusEffectTimerHBS?.invalidate()
        paddleHBS.setScale(1.0)
        isFlippedHBS = false
        resetBallPosition()
        createLevel()
        score = 0
        livesHBS = 3
        gameDelegate?.didUpdateScoreHBS(score)
        gameDelegate?.didUpdateLivesHBS(livesHBS)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let gameManager = GameManagerHBS()
        gameManager.currentLevelHBS = 2

        return GameViewHBS()
            .environmentObject(ShopManagerHBS())
            .environmentObject(gameManager)
            .environmentObject(MusicManagerHBS())
    }
}
