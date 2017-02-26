import QtQuick 2.3
import Ubuntu.Components 1.3

MultiPointTouchArea {
    id: root
    property int bsize: width / 2.2

    property color padColor: "white"
    property color padOutlineColor: "white"
    property color btnOutlineColor: "green"
    property int outlineWidth: units.gu(0.2)

    property color btnColor: "white"
    property color pressedButtonFill: Qt.darker(btnColor, 1.1)
    property real outlinePressed: units.gu(0.4)
    property real margin: units.gu(0.5)

    property real radius: width / 2

    Rectangle {
        id: b
        width: bsize
        height: bsize
        border.width: outlineWidth
        radius: outlineWidth * 3
        color: padColor
        anchors.verticalCenter: root.verticalCenter

        Rectangle {
            id: bbutton
            radius: root.radius
            border.color: btnOutlineColor
            anchors.fill: parent
            anchors.margins: root.margin
            border.width: outlineWidth
            color: btnColor
        }
    }

    Rectangle {
        id: a
        width: bsize
        height: bsize
        border.width: outlineWidth
        radius: outlineWidth * 3
        anchors.left: b.right
        anchors.rightMargin: root.width * 0.1
        color: padColor
        anchors.verticalCenter: root.verticalCenter

        Rectangle {
            id: abutton
            radius: root.radius
            border.color: btnOutlineColor
            anchors.fill: parent
            anchors.margins: root.margin
            border.width: outlineWidth
            color: btnColor
        }
    }

    property bool aIsDown: false
    property bool bIsDown: false

    signal aPressed
    signal bPressed
    signal aReleased
    signal bReleased

    onAPressed: {
        abutton.border.width = outlinePressed
        abutton.color = pressedButtonFill
    }

    onAReleased: {
        abutton.border.width = outlineWidth
        abutton.color = btnColor
    }

    onBPressed: {
        bbutton.border.width = outlinePressed
        bbutton.color = pressedButtonFill
    }

    onBReleased: {
        bbutton.border.width = outlineWidth
        bbutton.color = btnColor
    }

    onTouchUpdated: {
        var r = bsize / 2 + units.gu(1.5) // some extra space for edge presses
        var ax = a.x + r
        var bx = b.x + r
        var by = b.y + r
        var ay = a.y + r
        var r2 = r * r

        var aDown = false
        var bDown = false

        for (var i in touchPoints) {
            var pt = touchPoints[i]
            if (pt.pressed) {
                var dax = ax - pt.x
                var day = ay - pt.y
                var dbx = bx - pt.x
                var dby = by - pt.y

                if (dax * dax + day * day <= r2) {
                    aDown = true
                }

                if (dbx * dbx + dby * dby <= r2) {
                    bDown = true
                }
            }
        }

        if (aDown != aIsDown) {
            if (!aDown) {
                aReleased()
            } else if (!aIsDown) {
                aPressed()
            }
            aIsDown = aDown
        }

        if (bDown != bIsDown) {
            if (!bDown) {
                bReleased()
            } else if (!bIsDown) {
                bPressed()
            }
            bIsDown = bDown
        }
    }
}
