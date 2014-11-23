// Playground - noun: a place where people can play

import Cocoa
import Quartz

let glSize = NSRect(x: 0, y: 0, width: 100, height: 100)
let glPFAttributes = [
	NSOpenGLPixelFormatAttribute(0)
]
let glPixelFormat = NSOpenGLPixelFormat(attributes: glPFAttributes)
let openGLView = NSOpenGLView(frame: glSize, pixelFormat: glPixelFormat)

let qcComposition = QCComposition(file: "test")
var q2 = QCRenderer(openGLContext: openGLView!.openGLContext, pixelFormat: glPixelFormat, file: qcComposition)