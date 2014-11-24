//
//  FrameBlender.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 01.10.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

import Cocoa

class FrameBlender: NSObject {
	private var acceptedFrameGap: Int //Number of frames to blend
	private var blendRate: Int //Number of frames to blend
	private var minAcceptedFrame: Int
	private var maxAcceptedFrame: Int
	
	var totalFramesProcessed = 0 //Number of motion blur frames, used for filename
	
	private var weighter: GaussianFrameWeighter
	
	var currentFrame: NSImage!
	
	var blendFraction: Float = 1.0
	
	init(blendRate: Int, shutterAngle: Float, blendFraction: Float) {
		self.blendRate = blendRate
		let shutterAngle: Float = 180.0
		let shutterFactor = shutterAngle / 360.0
		
		let numFrames = Float(blendRate) * shutterFactor
		let frameDist = Float(blendRate) / 2 * shutterFactor
		
		let maxFrame = roundf(Float(blendRate) / 2 + frameDist)
		let minFrame = roundf(Float(blendRate) / 2 - frameDist)
		
//		let frameGap = maxFrame - minFrame
		
		self.maxAcceptedFrame = Int(maxFrame)
		self.minAcceptedFrame = Int(minFrame)
		self.acceptedFrameGap = self.maxAcceptedFrame - self.minAcceptedFrame
		
		self.blendFraction = blendFraction
		
		self.weighter = GaussianFrameWeighter(variance: 0.150)
		
		super.init()
	}
	
	private var frameCounter = 0
	func handleFrame(frameNumber: Int, frameData: NSImage) {
		if frameCounter < acceptedFrameGap {
			let framePosition = frameNumber % blendRate
			
//			let frameWeightX = Double(framePosition - minAcceptedFrame) / Double(acceptedFrameGap)
//			let frameWeight = weighter.weight(frameWeightX) //this should probably return the fraction value for the call to compositeImage below
			
			if framePosition >= self.minAcceptedFrame && framePosition < self.maxAcceptedFrame {
				if framePosition == minAcceptedFrame {
					//First frame of sequence
					currentFrame = frameData
				} else if framePosition == maxAcceptedFrame - 1 {
					//Last frame of sequence
					
					totalFramesProcessed++
				} else {
					//Some other frame
					currentFrame.compositeImage(frameData, fraction: blendFraction)
				}
				
				frameCounter++
			} else {
				println("Dropping frame \(frameNumber)")
			}
		} else {
			println("Tried to add too many frames!")
		}
	}
	
	func frameIsReady() -> Bool {
		return frameCounter == acceptedFrameGap
	}
	
	func resetFrame() {
		frameCounter = 0
		currentFrame = nil
	}
	
	func shouldIgnoreFrame(frameNumber: Int) -> Bool {
		let framePosition = frameNumber % blendRate
		return framePosition < minAcceptedFrame || framePosition > maxAcceptedFrame
	}
}
