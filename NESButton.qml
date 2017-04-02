import QtQuick 2.3
import Ubuntu.Components 1.3

Item {
    id: root

    signal pressed
    signal released

    property int outlineWidth: units.gu(0.1)

    property color padColor: "#d1d1d1"
    property color btnOutlineColor: "black"
    property color btnColor:   "#303030"
    property color pressedButtonFill: Qt.darker(btnColor, 1.2)

    property real radius: units.gu(0.5)
    property alias text: label.text

    Rectangle {
        id: pad
        radius: root.radius
        anchors.fill: parent
        color: padColor
        Rectangle {
            id: button
            anchors.fill: parent
            anchors.margins: units.gu(1)
            border.color: btnOutlineColor
            border.width: units.gu(0.2)
            radius: height / 2
            color: btnColor
        }
    }

    Label {
        id: label
        font.bold: true
        anchors {
            top: pad.bottom
            topMargin: units.gu(1)
            horizontalCenter: pad.horizontalCenter
        }
        color: "#ab2a2a"
    }

    TouchSensor {
        anchors.fill: parent
        onPushed: {
            button.color = pressedButtonFill
            button.scale = 0.95
            root.pressed()
        }

        onUnpushed: {
            button.color = btnColor
            button.scale = 1
            root.released()
        }
    }
}
