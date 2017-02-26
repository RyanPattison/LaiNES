import QtQuick 2.0

MultiPointTouchArea {
    anchors.fill: parent
    property bool isDown: false

    signal pushed
    signal unpushed

    function release() {
        if (isDown) {
            isDown = false
            unpushed()
        }
    }

    function press() {
        if (!isDown) {
            isDown = true
            pushed()
        }
    }

    onReleased: {
        release()
    }

    onCanceled: {
        release()
    }

    onPressed: {
        press()
    }

    onTouchUpdated: {
        for (var i = 0; i < touchPoints.length; ++i) {
            var pt = touchPoints[i]
            if (pt.x < x || pt.x > x + width || pt.y < y || pt.y > y + height) {
                release()
            } else {
                press()
            }
        }
    }
}
