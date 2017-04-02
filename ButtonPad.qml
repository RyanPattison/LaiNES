import QtQuick 2.3
import Ubuntu.Components 1.3

MultiPointTouchArea {
    id: root
    property int bsize: width / 2.2

    property color padColor: "#d1d1d1"
    property color padOutlineColor: "#ececec"
    property color btnOutlineColor: "#db413f"
    property int outlineWidth: units.gu(0.2)

    property color btnColor: "#bc0e0c"
    property color pressedButtonFill: Qt.darker(btnColor, 1.1)
    property color pressedOutlineColor: Qt.darker(btnOutlineColor, 1.1)
    property real margin: units.gu(1)
    property real btngap: units.gu(0.1)
    property real radius: width / 2
    property color textColor: "#ab2a2a"

    Label {
        text: "B"
        color: textColor
        anchors {
            bottom: b.top
            right: b.right
            bottomMargin: units.gu(0.5)
        }
        font.bold: true
        fontSize: "large"
    }

    Label {
        text: "A"
        color: textColor
        anchors {
            bottom: a.top
            right: a.right
            bottomMargin: units.gu(0.5)
        }
        font.bold: true
        fontSize: "large"
    }

    Rectangle {
        id: b
        width: bsize
        height: bsize
        radius: units.gu(0.5)
        color: padColor
        anchors.verticalCenter: root.verticalCenter

        Rectangle {
            Rectangle {
                id: bbutton
                radius: root.radius
                border.color: btnOutlineColor
                anchors.fill: parent
                anchors.margins: btngap
                border.width: outlineWidth * 2
                color: btnColor
            }
            anchors.fill: parent
            anchors.margins: root.margin
            radius: root.radius
            color: "black"
        }
    }

    Rectangle {
        id: a
        width: bsize
        height: bsize
        radius: units.gu(0.5)
        anchors.left: b.right
        anchors.leftMargin: units.gu(1)
        color: padColor
        anchors.verticalCenter: root.verticalCenter

        Rectangle {
            Rectangle {
                id: abutton
                radius: root.radius
                border.color: btnOutlineColor
                anchors.fill: parent
                anchors.margins: btngap
                border.width: outlineWidth * 2
                color: btnColor
            }
            anchors.fill: parent
            anchors.margins: root.margin
            radius: root.radius
            color: "black"
        }
    }

    property bool aIsDown: false
    property bool bIsDown: false

    signal aPressed
    signal bPressed
    signal aReleased
    signal bReleased

    onAPressed: {
        abutton.color = pressedButtonFill
        abutton.border.color = pressedOutlineColor
        abutton.scale = 0.97
    }

    onAReleased: {
        abutton.color = btnColor
        abutton.border.color = btnOutlineColor
        abutton.scale = 1
    }

    onBPressed: {
        bbutton.color = pressedButtonFill
        bbutton.scale = 0.97
        bbutton.border.color = pressedOutlineColor
    }

    onBReleased: {
        bbutton.color = btnColor
        bbutton.scale = 1
        bbutton.border.color = btnOutlineColor
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
