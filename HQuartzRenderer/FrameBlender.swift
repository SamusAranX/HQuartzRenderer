//
//  FrameBlender.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 01.10.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

import Cocoa

class FrameBlender: NSObject {
	var acceptedFrameGap: Double
	var blendRate: Int
	var minAcceptedFrame: Int = 0
	var maxAcceptedFrame: Int
	
	var weighter: GaussianFrameWeighter
	
	var currentFrame: NSImage?
	
	init(blendRate: Int) {
		let shutterAngle = 180
		self.blendRate = blendRate
		self.maxAcceptedFrame = Int(ceil(Float(shutterAngle * self.blendRate) / 360.0)) - 1
		if self.maxAcceptedFrame < self.blendRate - 1 {
			self.maxAcceptedFrame++
			self.minAcceptedFrame = 1
		}
		self.acceptedFrameGap = Double(self.maxAcceptedFrame - self.minAcceptedFrame)
		
		self.weighter = GaussianFrameWeighter(variance: 0.150)
		
		super.init()
	}
	
	func handleFrame(frameNumber: Int, frameData: NSImage) {
		let framePosition = frameNumber % blendRate
		let frameWeightX = Double(framePosition - minAcceptedFrame) / acceptedFrameGap
		let frameWeight = weighter.weight(frameWeightX)
		
		if framePosition == minAcceptedFrame {
			//First frame of sequence, set currentFrame
			
		}
		
		if framePosition == maxAcceptedFrame {
			//Last frame of sequence, fuck this fucking shit
		}
	}
	
	func shouldIgnoreFrame(frameNumber: Int) -> Bool {
		let framePosition = frameNumber % blendRate
		return framePosition < minAcceptedFrame || framePosition > maxAcceptedFrame
	}
	
	
}
