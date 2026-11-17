// Sizes and charge text for the horizontal bar battery. The tip sits on the
// left of the body; the charge is a whole number with no percent sign.

function snap(px, dpr) {
  var d = Number(dpr)
  if (!isFinite(d) || d < 1) d = 1
  return Math.round(Number(px) * d) / d
}

function level(fraction) {
  var f = Number(fraction)
  if (!isFinite(f)) return 0
  return Math.max(0, Math.min(100, Math.round(f * 100)))
}

function plain(value) {
  return String(value == null ? "" : value).replace(/[<>&]/g, "")
}

// barSize is the bar's thickness. The body is 2px shorter than the compact
// mark, and a little wider than the number. Every edge is on a device pixel.
function metrics(barSize, dpr) {
  var size = Number(barSize)
  if (!isFinite(size) || size < 16) size = 26
  var fullHeight = Math.min(size - 2, Math.max(14, size - 4))
  var bodyHeight = snap(Math.max(8, fullHeight * 0.67 - 2), dpr)
  var overlap = snap(1, dpr)
  var bodyWidth = snap(bodyHeight * 2.3 - 3, dpr)
  var tipWidth = snap(Math.max(2, bodyHeight * 0.2) + 1, dpr)
  var tipHeight = snap(bodyHeight * 0.46, dpr)
  var radius = snap(Math.min(bodyHeight / 2, Math.max(2, bodyHeight * 0.22)), dpr)
  var fontSize = Math.max(8, Math.min(Math.floor(bodyHeight - 1), Math.round(bodyHeight * 0.92)))
  var pad = snap(2, dpr)
  var width = snap(tipWidth + bodyWidth - overlap, dpr)
  return {
    bodyWidth: bodyWidth,
    bodyHeight: bodyHeight,
    stroke: overlap,
    tipWidth: tipWidth,
    tipHeight: tipHeight,
    radius: radius,
    fontSize: fontSize,
    pad: pad,
    width: width,
    height: bodyHeight
  }
}

// The outline switches when the machine is unplugged and the charge is low.
function isLow(fraction, discharging) {
  return !!discharging && level(fraction) <= 15
}

if (typeof module !== "undefined") {
  module.exports = {
    snap: snap,
    level: level,
    plain: plain,
    metrics: metrics,
    isLow: isLow
  }
}
