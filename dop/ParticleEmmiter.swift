//
//  ParticleEmmiter.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/17/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import Foundation

class ParticleEmmiter: NSObject {
    
    class func confettiParticle(container: UIView) {
        
        let particle_emitter = CAEmitterLayer()
        let confetti_array = confettiArray()
        
        particle_emitter.emitterShape = kCAEmitterLayerLine
        particle_emitter.emitterSize = CGSize(width: container.frame.size.width, height: 1)
        particle_emitter.emitterPosition =
            CGPoint(x: (container.center.x - (particle_emitter.emitterSize.width / 2)), y: -120)
        particle_emitter.zPosition = -1
        particle_emitter.emitterCells = confetti_array

        container.layer.addSublayer(particle_emitter)
    }
    
    
    static func confettiArray() -> [CAEmitterCell] {
        var confetti_array: [CAEmitterCell] = [CAEmitterCell]()
        
        let pink_800 = UIColor(red: 173/255, green: 20/255, blue: 87/255, alpha: 1)
        let pink_400 = UIColor(red: 245/255, green: 0/255, blue: 87/255, alpha: 1)
        let amber_200 = UIColor(red: 251/255, green: 225/255, blue: 106/255, alpha: 1)
//        let amber_600 = UIColor(red: 255/255, green: 179/255, blue: 0/255, alpha: 1)
        let light_green_200 = UIColor(red: 178/255, green: 255/255, blue: 89/255, alpha: 1)
        let blue_200 = UIColor(red: 64/255, green: 196/255, blue: 255/255, alpha: 1)
        let purple_200 = UIColor(red: 179/255, green: 157/255, blue: 219/255, alpha: 1)
        
        let color_array: [UIColor] = [pink_800, pink_400, amber_200, light_green_200, blue_200, purple_200]
        
        for color in color_array {
            let confetti = CAEmitterCell()
            setEmitterCell(cell: confetti, image_content: "confetti", color: color)
            confetti_array.append(confetti)
            
            let popper = CAEmitterCell()
            setEmitterCell(cell: popper, image_content: "popper", color: color)
            confetti_array.append(popper)
            
            let star = CAEmitterCell()
            setEmitterCell(cell: star, image_content: "star", color: color)
            confetti_array.append(star)
        }
        
        return confetti_array
    }
    
    static func setEmitterCell(cell: CAEmitterCell, image_content: String, color: UIColor) {
        cell.birthRate = 2
        cell.lifetime = 5
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 150
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = -90
        cell.spin = 2
        cell.spinRange = 3
        cell.scale = 0.3
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.04
        cell.alphaRange = 0.4
        cell.contents = UIImage(named: image_content)?.cgImage
    }
    
}

