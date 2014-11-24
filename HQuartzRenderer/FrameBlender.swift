//
//  FrameBlender.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 01.10.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

import Cocoa

class FrameBlender: NSObject {
	private var acceptedFrameGap: Double //Number of frames to drop
	private var blendRate: Int //Number of frames to blend
	private var minAcceptedFrame: Int = 0
	private var maxAcceptedFrame: Int
	
	private var totalFrameNumber = 0 //Number of motion blur frames, used for filename
	
	private var weighter: GaussianFrameWeighter
	
	private var currentFrame: NSImage!
	private var padZeroLength: Int!
	
	var blendFraction: Float = 0.0
	
	init(blendRate: Int, shutterAngle: Float, frameName: String, framePath: String, paddedZeros: Int) {
		self.blendRate = blendRate
		let shutterFactor = (360.0 - shutterAngle) / 360.0
		
		self.minAcceptedFrame = Int(roundf(shutterFactor * Float(blendRate) - (shutterFactor / 2.0 * Float(blendRate))))
		
		if self.maxAcceptedFrame < self.blendRate - 1 {
			self.maxAcceptedFrame++
			self.minAcceptedFrame = 1
		}
		
		self.acceptedFrameGap = Double(self.maxAcceptedFrame - self.minAcceptedFrame)
		
		self.weighter = GaussianFrameWeighter(variance: 0.150)
		
		self.padZeroLength = paddedZeros
		
		super.init()
	}
	
	func handleFrame(frameNumber: Int, frameData: NSImage) {
		let framePosition = frameNumber % blendRate
		let frameWeightX = Double(framePosition - minAcceptedFrame) / acceptedFrameGap
		let frameWeight = weighter.weight(frameWeightX)
		
		if framePosition == minAcceptedFrame {
			//First frame of sequence
			currentFrame = frameData
		} else if framePosition == maxAcceptedFrame {
			//Last frame of sequence
			
			totalFrameNumber++
		} else {
			//Some other frame
			currentFrame.compositeImage(frameData, fraction: blendFraction)
		}
	}
	
	func shouldIgnoreFrame(frameNumber: Int) -> Bool {
		let framePosition = frameNumber % blendRate
		return framePosition < minAcceptedFrame || framePosition > maxAcceptedFrame
	}
	
	func blendedFrame() -> NSImage {
		return currentFrame
	}
}
