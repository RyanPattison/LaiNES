import QtQuick 2.3
import Ubuntu.Components 1.3

Item {
    id: root
    property color outlineColor: "white"
    property color color: "black"
    property color centerColor: "black"
    property color backColor: "black"

    property int realWidth: width - units.gu(2)
    property int wingSize: realWidth / 3
    property int centreSize: realWidth - 2 * wingSize
    property int dpad_line: units.gu(0.37)

    property var direction: null
    property real dead_zone: units.gu(0.2)

    property int displacement: units.gu(0.33)

    signal rightPressed
    signal leftPressed
    signal upPressed
    signal downPressed

    signal rightReleased
    signal leftReleased
    signal upReleased
    signal downReleased

    Rectangle {
        anchors.centerIn: parent
        width: xAxis.width + 2 * displacement
        height: centreSize + 2 * displacement
        color: backColor
        radius: xAxis.radius
    }

    Rectangle {
        anchors.centerIn: parent
        width: centreSize + 2 * displacement
        height: yAxis.height + 2 * displacement
        color: backColor
        radius: yAxis.radius
    }

    Rectangle {
        id: xAxis

        x: units.gu(1)
        y: wingSize + units.gu(1)

        width: wingSize * 2 + centreSize
        height: centreSize
        radius: dpad_line
        color: root.color
        border.color: root.outlineColor
        border.width: dpad_line
    }

    Rectangle {
        id: yAxis

        x: wingSize + units.gu(1)
        y: units.gu(1)

        width: centreSize
        height: wingSize * 2 + centreSize
        radius: dpad_line

        color: root.color
        border.color: root.outlineColor
        border.width: dpad_line
    }

    Rectangle {
        id: mid
        anchors.centerIn: xAxis
        width: (centreSize - 1.173 * dpad_line) * Math.sqrt(2)
        height: width
        radius: width / 2
        border.width: width * 0.25
        border.color: root.color
        color: centerColor
    }

    function vshift(v) {
        xAxis.y += v
        yAxis.y += v
        mid.y += v
    }

    function hshift(h) {
        xAxis.x += h
        yAxis.x += h
        mid.x += h
    }

    onLeftPressed: {
        hshift(-displacement)
    }

    onLeftReleased: {
        hshift(displacement)
    }

    onRightPressed: {
        hshift(displacement)
    }

    onRightReleased: {
        hshift(-displacement)
    }

    onDownPressed: {
        vshift(displacement)
    }

    onDownReleased: {
        vshift(-displacement)
    }

    onUpPressed: {
        vshift(-displacement)
    }

    onUpReleased: {
        vshift(displacement)
    }

    function release() {
        if (direction) {
            if (direction == "left") {
                leftReleased()
            } else if (direction == "right") {
                rightReleased()
            } else if (direction == "up") {
                upReleased()
            } else if (direction == "down") {
                downReleased()
            }
            direction = null
        }
    }

    function press(dir) {
        if (dir != direction) {
            release()
            direction = dir
            if (direction == "left") {
                leftPressed()
            } else if (direction == "right") {
                rightPressed()
            } else if (direction == "up") {
                upPressed()
            } else if (direction == "down") {
                downPressed()
            }
        }
    }

    MultiPointTouchArea {
        anchors.fill: parent

        onReleased: release()
        onCanceled: release()

        maximumTouchPoints: 1

        onTouchUpdated: {
            for (var i = 0; i < touchPoints.length; ++i) {
                var p = touchPoints[i]
                var dx = p.x - (width / 2)
                var dy = p.y - (height / 2)
                var xmag = dx * dx
                var ymag = dy * dy
                var deadmag = dead_zone * dead_zone

                if (xmag < deadmag && ymag < deadmag) {
                    release()
                    return
                }

                if (xmag > ymag) {
                    if (dx > 0) {
                        press("right")
                    } else {
                        press("left")
                    }
                } else {
                    if (dy > 0) {
                        press("down")
                    } else {
                        press("up")
                    }
                }
            }
        }
    }
}
