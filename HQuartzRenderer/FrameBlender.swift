//
//  FrameBlender.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 01.10.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

import Cocoa

class FrameBlender: NSObject {
//	private var acceptedFrameGap: Int //Number of frames to blend
	private var blendRate: Int //Number of frames to blend
	private var maxAcceptedFrame: Int
	
	var maxCacheCapacity: Int {
		return maxAcceptedFrame
	}
	
	var totalFramesProcessed = 0 //Number of motion blur frames, used for filename
	
	private var weighter: GaussianFrameWeighter!
	
	var currentFrame: NSImage!
	var frameAvailable: Bool = false
	
	var blendFraction: Float
	
	init(blendRate: Int, shutterAngle: Float, blendFraction: Float) {
		self.blendRate = blendRate
		let shutterFactor = shutterAngle / 360.0
		
		let maxFrame = ceil(Float(blendRate) * shutterFactor)
		
//		let frameGap = maxFrame - minFrame
		
		self.maxAcceptedFrame = Int(maxFrame)
		
		self.blendFraction = blendFraction
		
//		self.weighter = GaussianFrameWeighter(variance: 0.150)
		
		super.init()
	}
	
	func handleFrame(frameNumber: Int, frameData: NSImage) {
		let framePosition = frameNumber % self.blendRate
		
		//let frameWeightX = Double(framePosition - minAcceptedFrame) / Double(acceptedFrameGap)
		//let frameWeight = weighter.weight(frameWeightX) //this should probably return the fraction value for the call to compositeImage below
		
		switch framePosition {
		case 0:
			//First frame of sequence
			println("Handling Frame \(framePosition + 1) of \(self.maxAcceptedFrame): First motion blur frame for frame \(self.totalFramesProcessed + 1)")
			frameAvailable = false
			currentFrame = frameData
			
		case maxAcceptedFrame - 1:
			//Last frame of sequence
			totalFramesProcessed++
			println("Frame \(self.totalFramesProcessed) processed, marking it as available")
			frameAvailable = true
			
		case 0...maxAcceptedFrame - 1:
			//Some other frame
			//In theory, Swift not falling through switch cases should make this just work
			println("Handling Frame \(framePosition + 1) of \(self.maxAcceptedFrame)")
			currentFrame.compositeImage(frameData, fraction: blendFraction)
			
		default:
			println("Dropping frame \(framePosition + 1) of \(self.maxAcceptedFrame)")
			frameAvailable = false
		}
	}
	
	func handleFrames(numbers: [Int], frames: [NSImage]) {
		if numbers.count == frames.count && numbers.count == maxAcceptedFrame {
			for var i = 0; i < numbers.count; i++ {
				self.handleFrame(numbers[i], frameData: frames[i])
			}
		} else {
			NSException(name: "handleFrames", reason: "Array lengths are not equal", userInfo: nil).raise()
		}
	}
	
	func resetBlender() {
		frameAvailable = false
		currentFrame = nil
	}
	
	func shouldIgnoreFrame(frameNumber: Int) -> Bool {
		return (frameNumber % self.blendRate) >= maxAcceptedFrame
	}
}
