//
//  Extensions.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 28.08.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {

	func saveAsPngWithPath(path: String) {
		var imageData = self.TIFFRepresentation
		var imageRep = NSBitmapImageRep(data: imageData!)
		imageData = imageRep!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: ["": ""])
		imageData!.writeToFile(path, atomically: false)
	}

//	func saveToPath(path: String) {
//		var cgRef = self.CGImageForProposedRect(nil, context: nil, hints: nil)
//		var newRep: NSBitmapImageRep = NSBitmapImageRep(CGImage: cgRef)
//		newRep.size = self.size
//		var pngData = newRep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: nil)
//		pngData.writeToFile(path, atomically: true)
////		newRep.autorelease()
//	}

	func resizeImage(newSize: NSSize) -> NSImage {
		var targetFrame = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		var targetImage = NSImage(size: newSize)
		targetImage.lockFocus()
		
		var imageHints = [NSImageHintInterpolation : NSImageInterpolation.High]
		NSGraphicsContext.currentContext()!.imageInterpolation = NSImageInterpolation.High
		self.drawInRect(targetFrame, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1.0, respectFlipped: true, hints: nil)

		targetImage.unlockFocus()
		return targetImage
	}

//- (NSImage*) resizeImage:(NSImage*)sourceImage size:(NSSize)size
//{
//    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
//    NSImage*  targetImage = [[NSImage alloc] initWithSize:size];
//
//    [targetImage lockFocus];
//
//    [sourceImage drawInRect:targetFrame
//                   fromRect:NSZeroRect       //portion of source image to draw
//                  operation:NSCompositeCopy  //compositing operation
//                   fraction:1.0              //alpha (transparency) value
//             respectFlipped:YES              //coordinate system
//                      hints:@{NSImageHintInterpolation:
//     [NSNumber numberWithInt:NSImageInterpolationLow]}];
//
//    [targetImage unlockFocus];
//
//    return targetImage;
//}

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