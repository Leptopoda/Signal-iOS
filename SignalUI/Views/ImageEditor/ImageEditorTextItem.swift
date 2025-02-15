//
//  Copyright (c) 2022 Open Whisper Systems. All rights reserved.
//

import UIKit

class ImageEditorTextItem: ImageEditorItem {

    let text: String

    let color: ImageEditorColor

    let font: UIFont

    enum Style: Int {
        case regular = 0
        case inverted
        case underline
        case outline
    }
    let style: Style

    // In order to render the text at a consistent size
    // in very differently sized contexts (canvas in
    // portrait, landscape, in the crop tool, before and
    // after cropping, while rendering output),
    // we need to scale the font size to reflect the
    // view width.
    //
    // We use the image's rendering width as the reference value,
    // since we want to be consistent with regard to the image's
    // content.
    let fontReferenceImageWidth: CGFloat

    let unitCenter: ImageEditorSample

    // Leave some margins against the edge of the image.
    static let kDefaultUnitWidth: CGFloat = 0.9

    // The max width of the text as a fraction of the image width.
    //
    // This provides continuity of text layout before/after cropping.
    //
    // NOTE: When you scale the text with with a pinch gesture, that
    // affects _scaling_, not the _unit width_, since we don't want
    // to change how the text wraps when scaling.
    let unitWidth: CGFloat

    // 0 = no rotation.
    // CGFloat.pi * 0.5 = rotation 90 degrees clockwise.
    let rotationRadians: CGFloat

    static let kMaxScaling: CGFloat = 4.0

    static let kMinScaling: CGFloat = 0.5

    let scaling: CGFloat

    init(text: String,
         color: ImageEditorColor,
         font: UIFont,
         style: Style = .regular,
         fontReferenceImageWidth: CGFloat,
         unitCenter: ImageEditorSample = ImageEditorSample(x: 0.5, y: 0.5),
         unitWidth: CGFloat = ImageEditorTextItem.kDefaultUnitWidth,
         rotationRadians: CGFloat = 0.0,
         scaling: CGFloat = 1.0) {
        self.text = text
        self.color = color
        self.font = font
        self.style = style
        self.fontReferenceImageWidth = fontReferenceImageWidth
        self.unitCenter = unitCenter
        self.unitWidth = unitWidth
        self.rotationRadians = rotationRadians
        self.scaling = scaling

        super.init(itemType: .text)
    }

    private init(itemId: String,
                 text: String,
                 color: ImageEditorColor,
                 font: UIFont,
                 style: Style,
                 fontReferenceImageWidth: CGFloat,
                 unitCenter: ImageEditorSample,
                 unitWidth: CGFloat,
                 rotationRadians: CGFloat,
                 scaling: CGFloat) {
        self.text = text
        self.color = color
        self.font = font
        self.style = style
        self.fontReferenceImageWidth = fontReferenceImageWidth
        self.unitCenter = unitCenter
        self.unitWidth = unitWidth
        self.rotationRadians = rotationRadians
        self.scaling = scaling

        super.init(itemId: itemId, itemType: .text)
    }

    class func empty(withColor color: ImageEditorColor,
                     style: Style,
                     unitWidth: CGFloat,
                     fontReferenceImageWidth: CGFloat,
                     scaling: CGFloat,
                     rotationRadians: CGFloat) -> ImageEditorTextItem {
        // TODO: Tune the default font size.
        let font = UIFont.boldSystemFont(ofSize: 36)
        return ImageEditorTextItem(text: "",
                                   color: color,
                                   font: font,
                                   style: style,
                                   fontReferenceImageWidth: fontReferenceImageWidth,
                                   unitWidth: unitWidth,
                                   rotationRadians: rotationRadians,
                                   scaling: scaling)
    }

    func copy(withText newText: String, color newColor: ImageEditorColor) -> ImageEditorTextItem {
        return ImageEditorTextItem(itemId: itemId,
                                   text: newText,
                                   color: newColor,
                                   font: font,
                                   style: style,
                                   fontReferenceImageWidth: fontReferenceImageWidth,
                                   unitCenter: unitCenter,
                                   unitWidth: unitWidth,
                                   rotationRadians: rotationRadians,
                                   scaling: scaling)
    }

    func copy(unitCenter: CGPoint) -> ImageEditorTextItem {
        return ImageEditorTextItem(itemId: itemId,
                                   text: text,
                                   color: color,
                                   font: font,
                                   style: style,
                                   fontReferenceImageWidth: fontReferenceImageWidth,
                                   unitCenter: unitCenter,
                                   unitWidth: unitWidth,
                                   rotationRadians: rotationRadians,
                                   scaling: scaling)
    }

    func copy(scaling: CGFloat, rotationRadians: CGFloat) -> ImageEditorTextItem {
        return ImageEditorTextItem(itemId: itemId,
                                   text: text,
                                   color: color,
                                   font: font,
                                   style: style,
                                   fontReferenceImageWidth: fontReferenceImageWidth,
                                   unitCenter: unitCenter,
                                   unitWidth: unitWidth,
                                   rotationRadians: rotationRadians,
                                   scaling: scaling)
    }

    func copy(unitWidth: CGFloat) -> ImageEditorTextItem {
        return ImageEditorTextItem(itemId: itemId,
                                   text: text,
                                   color: color,
                                   font: font,
                                   style: style,
                                   fontReferenceImageWidth: fontReferenceImageWidth,
                                   unitCenter: unitCenter,
                                   unitWidth: unitWidth,
                                   rotationRadians: rotationRadians,
                                   scaling: scaling)
    }

    func copy(font: UIFont) -> ImageEditorTextItem {
        return ImageEditorTextItem(itemId: itemId,
                                   text: text,
                                   color: color,
                                   font: font,
                                   style: style,
                                   fontReferenceImageWidth: fontReferenceImageWidth,
                                   unitCenter: unitCenter,
                                   unitWidth: unitWidth,
                                   rotationRadians: rotationRadians,
                                   scaling: scaling)
    }

    func copy(color: ImageEditorColor) -> ImageEditorTextItem {
        return ImageEditorTextItem(itemId: itemId,
                                   text: text,
                                   color: color,
                                   font: font,
                                   style: style,
                                   fontReferenceImageWidth: fontReferenceImageWidth,
                                   unitCenter: unitCenter,
                                   unitWidth: unitWidth,
                                   rotationRadians: rotationRadians,
                                   scaling: scaling)
    }

    func copy(style: Style) -> ImageEditorTextItem {
        return ImageEditorTextItem(itemId: itemId,
                                   text: text,
                                   color: color,
                                   font: font,
                                   style: style,
                                   fontReferenceImageWidth: fontReferenceImageWidth,
                                   unitCenter: unitCenter,
                                   unitWidth: unitWidth,
                                   rotationRadians: rotationRadians,
                                   scaling: scaling)
    }

    override func outputScale() -> CGFloat {
        return scaling
    }

    static func == (left: ImageEditorTextItem, right: ImageEditorTextItem) -> Bool {
        return (left.text == right.text &&
                left.color == right.color &&
                left.font.fontName == right.font.fontName &&
                left.style == right.style &&
                left.font.pointSize.fuzzyEquals(right.font.pointSize) &&
                left.fontReferenceImageWidth.fuzzyEquals(right.fontReferenceImageWidth) &&
                left.unitCenter.fuzzyEquals(right.unitCenter) &&
                left.unitWidth.fuzzyEquals(right.unitWidth) &&
                left.rotationRadians.fuzzyEquals(right.rotationRadians) &&
                left.scaling.fuzzyEquals(right.scaling))
    }
}
