// Playground - noun: a place where people can play

import Cocoa
import Quartz

let shutterAngle: Float = 180.0
let shutterFactor = shutterAngle / 360.0
let blendRate: Float = 24

let numFrames = blendRate * shutterFactor
let frameGap = blendRate / 2 * shutterFactor

let maxFrame = blendRate / 2 + frameGap //no -1 because I check frame numbers with <, not <=
let minFrame = blendRate / 2 - frameGap

//if self.maxAcceptedFrame < self.blendRate - 1 {
//	self.maxAcceptedFrame++
//	self.minAcceptedFrame = 1
//}
