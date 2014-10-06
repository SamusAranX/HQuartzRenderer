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
		var shutterAngle = 180
		self.blendRate = blendRate
		self.maxAcceptedFrame = Int(ceil(Float((shutterAngle * self.blendRate) / 360)) - 1)
		if self.maxAcceptedFrame <= self.blendRate - 1 {
			self.maxAcceptedFrame++
			self.minAcceptedFrame = 1
		}
		self.acceptedFrameGap = Double(self.maxAcceptedFrame - self.minAcceptedFrame)
		
		self.weighter = GaussianFrameWeighter(variance: 0.150)
		
		super.init()
	}
	
	func shouldIgnoreFrame(frameNumber: Int) -> Bool {
		return false
	}
	
	
}
