// Playground - noun: a place where people can play

import Cocoa

let shutterAngle: Float = 180.0
let shutterFactor = shutterAngle / 360.0
let blendRate: Float = 30

let numFrames = blendRate * shutterFactor
let frameDist = blendRate / 2 * shutterFactor

let maxFrame = roundf(blendRate / 2 + frameDist)
let minFrame = roundf(blendRate / 2 - frameDist)

let frameGap = maxFrame - minFrame

println(String(format: "%04d", 451)) //a bomb