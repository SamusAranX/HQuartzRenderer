//
//  DeepColorRenderer.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 30.10.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

import Foundation
import Cocoa
import Quartz

class DeepColorRenderer: NSObject {
	
	var cglContext: CGLContextObj?
	var qcRenderer: QCRenderer?
	var needsRebuild = true
	
	init(compositionPath: String, pixelsWide: Int, pixelsHigh: Int) {
		let glPFAttributes:[NSOpenGLPixelFormatAttribute] = [
			UInt32(NSOpenGLPFAAccelerated),
			UInt32(NSOpenGLPFANoRecovery),
			UInt32(NSOpenGLPFAColorFloat),
			UInt32(NSOpenGLPFAColorSize), UInt32(48),
			UInt32(NSOpenGLPFADepthSize), UInt32(16),
			UInt32(0)
		]
		let glPixelFormat = NSOpenGLPixelFormat(attributes: glPFAttributes)
		if glPixelFormat == nil {
			println("Pixel Format is nil")
			return
		}
		
		if compositionPath.isEmpty || pixelsWide < 16 || pixelsHigh < 16 {
			println("DeepColorRenderer init: nope!")
			return
		}
	}
	
	func bitmapImageForTime(time: Double) -> NSBitmapImageRep {
		let bitmapRep = NSBitmapImageRep()
		
		return bitmapRep
	}
	
}