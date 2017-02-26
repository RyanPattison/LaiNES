import QtQuick 2.3
import Ubuntu.Components 1.3

Item {
    id: root

    signal pressed
    signal released

    property color btnOutlineColor: "green"
    property int outlineWidth: units.gu(0.2)

    property color btnColor: "white"
    property color pressedButtonFill: Qt.darker(btnColor, 1.1)
    property real outlinePressed: units.gu(0.4)

    property real radius: width / 2

    Rectangle {
        id: button
        radius: root.radius
        border.color: btnOutlineColor
        anchors.fill: parent
        border.width: outlineWidth
        color: btnColor
    }

    TouchSensor {
        anchors.fill: parent
        onPushed: {
            button.border.width = outlinePressed
            button.color = pressedButtonFill
            root.pressed()
        }

        onUnpushed: {
            button.border.width = outlineWidth
            button.color = btnColor
            root.released()
        }
    }
}
