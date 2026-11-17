import QtQuick
import QtQuick.Shapes
import qs.Commons
import "Battery.js" as Battery

// Horizontal battery. The terminal sticks out of the left side. The shell is
// an outline at 75% opacity. The inside fills from the right by the charge,
// at 35% opacity, so the empty part is on the left. The number is the outline color.
Item {
  id: mark

  property real barSize: 26
  property real fraction: 0
  property string levelText: ""
  property bool showLevel: true
  property color color: "white"
  property color urgent: "transparent"
  property bool low: false
  property bool charging: false
  property bool holding: false
  property string fontFamily: ""
  property real pressScale: 1

  readonly property real dpr: Math.max(1, Screen.devicePixelRatio)
  readonly property var shape: Battery.metrics(barSize, dpr)
  readonly property color baseColor: low && urgent.a > 0 ? urgent : color
  // At the charge threshold, use the normal dim battery color everywhere:
  // shell, fill, number, and bolt are one coherent glyph rather than a
  // bright outline with a separate accent marker.
  readonly property color fillColor: holding ? Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.35) : baseColor
  readonly property color outlineColor: holding ? fillColor : Qt.rgba(fillColor.r, fillColor.g, fillColor.b, 0.75)
  readonly property color interiorColor: holding ? fillColor : Qt.rgba(fillColor.r, fillColor.g, fillColor.b, 0.35)
  readonly property bool showBolt: charging || holding
  readonly property color boltColor: holding ? fillColor : outlineColor
  readonly property real charge: Math.max(0, Math.min(1, fraction))
  readonly property real sidePad: shape.pad
  readonly property real textWidth: showLevel ? level.implicitWidth : 0
  readonly property real bodyWidth: Math.max(shape.bodyWidth, textWidth + shape.pad)

  implicitWidth: shape.tipWidth + bodyWidth - shape.stroke
  implicitHeight: shape.bodyHeight
  transformOrigin: Item.Center
  scale: pressScale

  Item {
    id: body
    x: mark.shape.tipWidth - mark.shape.stroke
    y: 0
    width: mark.bodyWidth
    height: mark.shape.bodyHeight

    Rectangle {
      id: bodyFill
      y: mark.shape.stroke
      height: Math.max(0, parent.height - mark.shape.stroke * 2)
      width: Math.max(0, (parent.width - mark.shape.stroke * 2) * mark.charge)
      x: parent.width - mark.shape.stroke - width
      color: mark.interiorColor
      readonly property real cap: Math.max(0, mark.shape.radius - mark.shape.stroke)
      topRightRadius: Math.min(cap, height / 2)
      bottomRightRadius: topRightRadius
      topLeftRadius: width >= parent.width - mark.shape.stroke * 2 - 0.5 ? cap : 0
      bottomLeftRadius: topLeftRadius

      Behavior on width { NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
      Behavior on color { ColorAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
    }

    Shape {
      id: chargeBolt
      visible: mark.showBolt
      // The shell's outline items follow this declaration; lift the bolt so
      // their strokes cannot cut across the foreground glyph.
      z: 1
      // Keep the glyph inside the battery's inner area. The former fixed
      // 10 × 15px bolt spilled over the compact bar mark and its dark stroke
      // made the corners look ragged at normal panel scale.
      x: parent.width - width + Style.space(4)
      y: (parent.height - height) / 2
      width: Battery.snap(Math.min(Style.space(10), Math.max(Style.space(7), parent.height * 0.64) + Style.space(1)), mark.dpr)
      // Deliberately overlap the shell by one stroke above and below so the
      // charge symbol reads as a foreground glyph rather than an inlay.
      height: Battery.snap(parent.height + mark.shape.stroke * 2, mark.dpr)

      ShapePath {
        // Holding uses the same dim battery color everywhere; active charging
        // keeps the neutral outline color.
        fillColor: mark.boltColor
        // A single solid, six-point bolt stays crisp at both bar and hero
        // sizes. Its wider upper and lower facets read clearly without an
        // outline fighting the battery's own stroke.
        startX: chargeBolt.width * 0.62
        startY: 0
        PathLine { x: chargeBolt.width * 0.08; y: chargeBolt.height * 0.55 }
        PathLine { x: chargeBolt.width * 0.42; y: chargeBolt.height * 0.55 }
        PathLine { x: chargeBolt.width * 0.29; y: chargeBolt.height }
        PathLine { x: chargeBolt.width * 0.94; y: chargeBolt.height * 0.38 }
        PathLine { x: chargeBolt.width * 0.58; y: chargeBolt.height * 0.38 }
        PathLine { x: chargeBolt.width * 0.62; y: 0 }
      }
    }

    // The left stroke stays open where the stud meets the body.
    Item {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      height: Math.max(0, tip.y)
      clip: true
      Rectangle {
        width: body.width
        height: body.height
        color: "transparent"
        radius: mark.shape.radius
        border.width: mark.shape.stroke
        border.color: mark.outlineColor
        Behavior on border.color { ColorAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
      }
    }
    Item {
      id: outlineBottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: Math.max(0, body.height - tip.y - tip.height)
      clip: true
      Rectangle {
        width: body.width
        height: body.height
        y: outlineBottom.height - body.height
        color: "transparent"
        radius: mark.shape.radius
        border.width: mark.shape.stroke
        border.color: mark.outlineColor
        Behavior on border.color { ColorAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
      }
    }
    Item {
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: mark.shape.stroke
      clip: true
      Rectangle {
        width: body.width
        height: body.height
        x: parent.width - body.width
        color: "transparent"
        radius: mark.shape.radius
        border.width: mark.shape.stroke
        border.color: mark.outlineColor
        Behavior on border.color { ColorAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
      }
    }
  }

  // Stud on the left. Its right edge is open so it joins the body fill.
  Item {
    id: tip
    x: 0
    y: (mark.shape.bodyHeight - height) / 2
    width: mark.shape.tipWidth
    height: mark.shape.tipHeight

    Item {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: Math.max(0, parent.width - mark.shape.stroke)
      clip: true
      Rectangle {
        width: tip.width
        height: tip.height
        color: "transparent"
        border.width: mark.shape.stroke
        border.color: mark.outlineColor
        topLeftRadius: height / 2
        bottomLeftRadius: height / 2
        Behavior on border.color { ColorAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
      }
    }
  }

  Text {
    id: level
    visible: mark.showLevel && mark.levelText !== ""
    anchors.horizontalCenter: body.horizontalCenter
    anchors.horizontalCenterOffset: mark.charging || mark.holding ? -Style.space(1) : 0
    anchors.verticalCenter: body.verticalCenter
    // The metric box centers the line, and native drawing paints the digits
    // about 1px below that. Pull them back up so the ink sits in the body.
    anchors.verticalCenterOffset: (figure.descent - figure.ascent + figure.tightBoundingRect(mark.levelText !== "" ? mark.levelText : "0").height) / 2 - 1
    textFormat: Text.PlainText
    text: mark.levelText
    color: mark.fillColor
    font.family: mark.fontFamily !== "" ? mark.fontFamily : "sans-serif"
    font.pixelSize: mark.shape.fontSize
    font.weight: Font.Black
    renderType: Text.NativeRendering

    Behavior on color { ColorAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
  }

  FontMetrics {
    id: figure
    font: level.font
  }
}
