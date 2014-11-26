//
//  Extensions.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 28.08.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

import AppKit
import Foundation
import Cocoa

extension NSImage {

	func saveAsPngWithPath(path: String) -> Bool {
		var imageData = self.TIFFRepresentation
		var imageRep = NSBitmapImageRep(data: imageData!)
		imageData = imageRep!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: ["": ""])
		return imageData!.writeToFile(path, atomically: false)
	}

	func resizeImage(newSize: NSSize) -> NSImage {
		var targetFrame = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		var targetImage = NSImage(size: newSize)
		targetImage.lockFocus()
		
		NSGraphicsContext.currentContext()!.imageInterpolation = NSImageInterpolation.High
		self.drawInRect(targetFrame, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1.0, respectFlipped: true, hints: nil)

		targetImage.unlockFocus()
		return targetImage
	}

	func compositeImage(secondImage: NSImage, fraction: Float) {
		self.lockFocus()
		secondImage.drawAtPoint(NSZeroPoint, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: CGFloat(fraction))
		self.unlockFocus()
	}
}

extension Int {
    func format(f: String) -> String {
        return NSString(format: "%\(f)d", self)
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}