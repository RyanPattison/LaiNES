import QtQuick 2.3
import LaiNES 1.0
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.Components.Popups 1.3
import Qt.labs.settings 1.0

MainView {
    id: root
    height: units.gu(80)
    width: units.gu(45)

    applicationName: "laines.rpattison"

    property color nes_back: "#1E2126"
    property color nes_red: "#DB1B16"
    property color nes_red_accent: "#EC423D"
    property color nes_white: "#DFDCD5"
    property color nes_white_accent: "#F7F7F5"
    property color nes_black: Qt.darker("#141A1A", 1.2)
    property color nes_black_accent: "#2B2B2B"
    property color nes_gray: "#8D8D8D"
    property color nes_gray_accent: "#A8A8A8"

    property real outline: units.gu(0.25)
    property real thin_outline: units.gu(0.25)

    property var activeTransfer: null
    property bool muted: false
    property bool haptics: true

    onMutedChanged: {
        emu.mute(muted)
    }

    function click() {
        if (root.haptics) {
            Haptics.play()
        }
    }

    ContentPeerModel {
        id: model
        contentType: ContentType.Documents
        handler: ContentHandler.Source
    }

    Connections {
        target: ContentHub
        onImportRequested: {
            root.importItems(transfer.items)
        }
    }

    NESEmulator {
        id: emu
        color: nes_back
    }

    function importItems(items) {
        load(items[0].url)
    }

    function load(url) {
        var path = url.toString().replace("file://", "")
        console.log("importing...")
        console.log(path)
        if (path) {
            if (emu.loadRom(path)) {
                help.visible = false
                emu.play()
            } else {
                help.text = i18n.tr("ROM failed to load")
                help.visible = true
            }
        }
    }

    function requestROM() {
        emu.pause()
        var peer = null
        for (var i = 0; i < model.peers.length; ++i) {
            var p = model.peers[i]
            var s = p.appId
            if (s.indexOf("filemanager") != -1) {
                peer = p
            }
        }
        if (peer == null) {
            picker.visible
                    = true /* didn't find ubuntu's file manager, maybe they have another app */
        } else {
            root.activeTransfer = peer.request()
        }
    }

    Component.onCompleted: {
        btns.aPressed.connect(emu.aPressed)
        btns.aReleased.connect(emu.aReleased)

        btns.bPressed.connect(emu.bPressed)
        btns.bReleased.connect(emu.bReleased)

        select.pressed.connect(emu.selectPressed)
        select.released.connect(emu.selectReleased)

        start.pressed.connect(emu.startPressed)
        start.released.connect(emu.startReleased)

        dpad.upPressed.connect(emu.upPressed)
        dpad.upReleased.connect(emu.upReleased)

        dpad.downPressed.connect(emu.downPressed)
        dpad.downReleased.connect(emu.downReleased)

        dpad.leftPressed.connect(emu.leftPressed)
        dpad.leftReleased.connect(emu.leftReleased)

        dpad.rightPressed.connect(emu.rightPressed)
        dpad.rightReleased.connect(emu.rightReleased)
    }

    Component.onDestruction: {
        emu.pause()
        emu.stop()
    }

    Label {
        id: help
        text: i18n.tr("Open ROM…")
        fontSize: "x-large"
        color: nes_black
        anchors.centerIn: loaderArea
        font.bold: true
    }

    MouseArea {
        id: loaderArea
        width: emu.rect.width
        height: emu.rect.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        onClicked: requestROM()
    }

    Item {
        id: lefthand
        width: units.gu(19)
        height: units.gu(38)

        anchors.left: parent.left
        anchors.bottom: parent.bottom

        DirectionalPad {
            id: dpad
            x: units.gu(1)
            y: 0
            width: units.gu(19)
            height: width
            color: nes_black
            centerColor: nes_black_accent
            outlineColor: nes_white_accent

            onLeftPressed: click()
            onRightPressed: click()
            onUpPressed: click()
            onDownPressed: click()
        }

        NESButton {
            id: select
            y: units.gu(28)

            anchors.right: parent.right
            anchors.rightMargin: units.gu(1)

            width: units.gu(9)
            height: units.gu(2.5)

            btnColor: nes_gray
            btnOutlineColor: nes_gray_accent
            radius: height / 3
            onPressed: click()
        }
    }

    Item {
        id: righthand
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: units.gu(20)
        height: units.gu(38)

        NESButton {
            id: start
            y: select.y

            anchors.left: parent.left
            anchors.leftMargin: units.gu(1)

            width: select.width
            height: select.height

            btnColor: nes_gray
            btnOutlineColor: nes_gray_accent
            radius: height / 3
            onPressed: click()
        }

        ButtonPad {
            y: 0
            x: units.gu(0.5)
            width: parent.width
            height: units.gu(18)
            id: btns

            onAPressed: click()
            onBPressed: click()

            padColor: nes_white_accent
            padOutlineColor: nes_white
            btnColor: nes_red
            btnOutlineColor: nes_black
        }
    }

    Rectangle {
        id: picker
        anchors.fill: parent
        visible: false

        ContentPeerPicker {
            id: peerPicker
            visible: parent.visible
            handler: ContentHandler.Source
            contentType: ContentType.Documents

            onPeerSelected: {
                peer.contentType = ContentType.Documents
                peer.selectionType = ContentTransfer.Single
                root.activeTransfer = peer.request()
                picker.visible = false
            }

            onCancelPressed: {
                console.log("load canceled")
                picker.visible = false
                emu.play()
            }
        }
    }

    Connections {
        target: root.activeTransfer
        onStateChanged: {
            if (root.activeTransfer.state === ContentTransfer.Charged) {
                root.importItems(root.activeTransfer.items)
            } else if (root.activeTransfer.state == ContentTransfer.Aborted) {
                emu.play()
                picker.visible = false
                console.log("aborted transfer")
            }
        }
    }

    Rectangle {
        id: shaded_corner
        width: units.gu(16)
        height: units.gu(28)
        color: Qt.darker(nes_black, 1.05)
        rotation: 50

        anchors {
            verticalCenter: parent.bottom
            horizontalCenter: parent.right
        }
    }

    Settings {
        id: gameSettings
        property bool vibrate: root.haptics
        property bool sound: !root.muted
        onSoundChanged: {
            root.muted = !sound
        }
        onVibrateChanged: {
            root.haptics = vibrate
        }
    }

    Icon {
        name: gameSettings.sound ? "speaker" : "speaker-mute"
        color: nes_gray
        width: units.gu(4)
        height: units.gu(4)
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: units.gu(1.5)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                click()
                gameSettings.sound = !gameSettings.sound
            }
        }
    }
}
