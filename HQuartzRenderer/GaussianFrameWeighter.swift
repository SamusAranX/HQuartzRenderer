//
//  GaussianFrameWeighter.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 01.10.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//
//  More or less ported from SrcDemo2's FrameBlender class. I have no idea what I'm doing


import Cocoa

class GaussianFrameWeighter: NSObject {
	private var weightResolution = 1024.0
	private var mean: Double = 0
	private var stdDev: Double = 0
	private var variance: Double = 0
	
	init(variance: Double) {
		//mean remains zero
		//variance gets set
		//stdDev is sqrt(variance)
		self.variance = variance
		self.stdDev = sqrt(variance)
	}
	
	func weight(framePosition: Double) -> Int {
		var x = framePosition * 2 - 1
		
		var framePosX = exp(-(pow(x - mean, 2) / (variance * 2))) //-1 to 1
		var standardDeviation = 1 / (stdDev * sqrt(2 * M_PI))
		return (Int)(weightResolution * pow(framePosX, standardDeviation))
	}
}
