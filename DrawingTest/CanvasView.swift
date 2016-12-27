//
//  CanvasView.swift
//  DrawingTest
//
//  Created by Christian Tietze on 27/12/16.
//  Copyright © 2016 Christian Tietze. All rights reserved.
//

import Cocoa

protocol CanvasDrawable {
    func draw()
}

@IBDesignable
class CanvasView: NSView {

    @IBInspectable
    var backgroundColor: NSColor = NSColor.white

    var paths: [Stroke] = []

    var crosshair: Crosshair? {
        didSet {
            if let oldValue = oldValue {
                self.setNeedsDisplay(oldValue.bounds)
            }

            if let newValue = crosshair {
                self.setNeedsDisplay(newValue.bounds)
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {

        backgroundColor.setFill()
        NSRectFill(dirtyRect)

        super.draw(dirtyRect)

        self.drawCrosshair()
        self.drawPaths()
    }

    func drawCrosshair() {

        guard let crosshair = crosshair else { return }

        crosshair.draw()
    }

    func drawPaths() {

        var allPaths = paths

        if let currentStroke = currentStroke {
            allPaths.append(currentStroke)
        }

        allPaths.forEach { $0.draw() }
    }

    func moveCrosshair(to location: NSPoint) {

        self.crosshair = Crosshair(location: location)
    }


    // MARK: -

    override func mouseMoved(with event: NSEvent) {

        let location = convert(event.locationInWindow, from: nil)
        moveCrosshair(to: location)
    }

    var currentStroke: Stroke?

    override func mouseDown(with event: NSEvent) {

        let location = convert(event.locationInWindow, from: nil)
        currentStroke = Stroke(startAt: location)
    }

    override func mouseUp(with event: NSEvent) {

        guard let currentStroke = currentStroke else { return }

        let location = convert(event.locationInWindow, from: nil)
        currentStroke.add(point: location)
        paths.append(currentStroke)

        self.currentStroke = nil
    }

    override func mouseDragged(with event: NSEvent) {

        let location = convert(event.locationInWindow, from: nil)
        moveCrosshair(to: location)

        guard let currentStroke = currentStroke else { return }

        currentStroke.add(point: location)
    }
}
