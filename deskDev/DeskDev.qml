import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    minWidth: 300
    minHeight: 360
    property real defaultWidth: 360
    property real defaultHeight: 470

    readonly property color fg: "#f2f2f2"
    readonly property color muted: "#9a9a9a"
    readonly property color track: "#2a2d2a"
    readonly property color panel: Qt.rgba(0, 0, 0, 0.88)
    readonly property color accent: "#e0a36c"
    readonly property color water: "#8fb3d9"
    readonly property string fontFamily: "Inter"
    readonly property string monoFamily: "JetBrains Mono"

    property var info: ({ docker: [], vpn: {}, git: [], claude: {} })
    property date now: new Date()

    function shortUp(status) {
        const m = String(status).match(/^Up\s+(.*?)(\s*\(.*\))?$/);
        if (!m)
            return status;
        return m[1].replace(/About an? /, "").replace(/ hours?/, "h").replace(/ minutes?/, "min").replace(/ seconds?/, "s").replace(/ days?/, "d").replace(/ weeks?/, "sem");
    }

    function health(status) {
        if (/unhealthy/.test(status))
            return "unhealthy";
        if (/healthy/.test(status))
            return "healthy";
        if (/starting/.test(status))
            return "iniciando";
        return "";
    }

    readonly property var docker: info.docker || []

    Process {
        id: fetcher
        command: ["timeout", "40", Quickshell.env("HOME") + "/.config/DankMaterialShell/plugins/deskDev/dev-data.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.info = JSON.parse(text);
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.now = new Date();
            if (!fetcher.running)
                fetcher.running = true;
        }
    }


    component SectionLabel: Text {
        font.family: root.fontFamily
        font.pixelSize: 10
        font.weight: Font.Medium
        font.letterSpacing: 1.6
        color: root.muted
    }

    component Bar: Rectangle {
        property real pct: 0
        width: parent.width
        height: 3
        radius: 2
        color: root.track
        Rectangle {
            height: parent.height
            radius: 2
            color: root.fg
            width: parent.width * Math.max(0, Math.min(1, parent.pct))
            Behavior on width {
                NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: content.implicitHeight + 40
        radius: 18
        color: root.panel
    }

    Column {
        id: content
        x: 20
        y: 20
        width: parent.width - 40
        spacing: 16

        Item {
            width: parent.width
            height: 64

            Column {
                anchors.bottom: parent.bottom
                spacing: 2
                Row {
                    spacing: 4
                    Text {
                        text: "dev"
                        font.family: root.fontFamily
                        font.pixelSize: 30
                        font.weight: Font.ExtraLight
                        color: root.fg
                    }
                    Rectangle {
                        id: cursor
                        width: 8
                        height: 22
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 6
                        color: root.fg
                        SequentialAnimation {
                            running: true
                            loops: Animation.Infinite
                            OpacityAnimator { target: cursor; from: 1; to: 1; duration: 550 }
                            OpacityAnimator { target: cursor; from: 0; to: 0; duration: 550 }
                        }
                    }
                }
                Text {
                    text: Qt.formatTime(root.now, "HH:mm")
                    font.family: root.monoFamily
                    font.pixelSize: 11
                    color: "#8c8c8c"
                }
            }

            Item {
                anchors.right: parent.right
                width: 110
                height: 64
                scale: 0.85
                transformOrigin: Item.BottomRight

                Repeater {
                    model: 2
                    Rectangle {
                        id: spout
                        required property int index
                        width: 3.2 - index * 0.6
                        height: width
                        radius: width / 2
                        color: root.water
                        x: 20 + index * 4
                        y: 20
                        opacity: 0
                        ParallelAnimation {
                            id: spoutAnim
                            loops: Animation.Infinite
                            YAnimator { target: spout; from: 20; to: 6; duration: 1600; easing.type: Easing.OutQuad }
                            OpacityAnimator { target: spout; from: 1; to: 0; duration: 1600 }
                        }
                        Timer {
                            interval: spout.index * 560 + 1
                            running: true
                            onTriggered: spoutAnim.start()
                        }
                    }
                }

                Item {
                    id: whale
                    width: 120
                    height: 62
                    transformOrigin: Item.Bottom
                    SequentialAnimation {
                        running: true
                        loops: Animation.Infinite
                        ParallelAnimation {
                            YAnimator { target: whale; from: 0; to: -3; duration: 1500; easing.type: Easing.InOutSine }
                            RotationAnimator { target: whale; from: 0; to: -2; duration: 1500; easing.type: Easing.InOutSine }
                        }
                        ParallelAnimation {
                            YAnimator { target: whale; from: -3; to: 0; duration: 1500; easing.type: Easing.InOutSine }
                            RotationAnimator { target: whale; from: -2; to: 0; duration: 1500; easing.type: Easing.InOutSine }
                        }
                    }

                    Repeater {
                        model: [[30, 18], [44, 18], [58, 18], [44, 6]]
                        Rectangle {
                            required property var modelData
                            required property int index
                            visible: index < Math.min(4, root.docker.length)
                            x: modelData[0]
                            y: modelData[1]
                            width: 12
                            height: 10
                            radius: 1.5
                            color: "transparent"
                            border.color: root.fg
                            border.width: 1.6
                        }
                    }

                    Shape {
                        anchors.fill: parent
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            strokeColor: root.fg
                            strokeWidth: 1.6
                            fillColor: "#000000"
                            joinStyle: ShapePath.RoundJoin
                            capStyle: ShapePath.RoundCap
                            PathSvg { path: "M12 32 H88 C 88 48, 72 58, 48 58 C 26 58, 12 48, 12 32 Z" }
                        }
                        ShapePath {
                            strokeColor: root.fg
                            strokeWidth: 1.6
                            fillColor: "transparent"
                            joinStyle: ShapePath.RoundJoin
                            capStyle: ShapePath.RoundCap
                            PathSvg { path: "M86 40 C 94 38, 98 32, 100 26 C 102 32, 106 34, 109 34 C 102 39, 96 43, 87 45 M22 49 Q26 52 30 49" }
                        }
                    }

                    Rectangle {
                        x: 24
                        y: 40
                        width: 3.6
                        height: 3.6
                        radius: 1.8
                        color: root.fg
                    }
                }

                Item {
                    y: 58
                    width: 120
                    height: 14
                    clip: true
                    Shape {
                        id: waves
                        width: 168
                        height: 14
                        preferredRendererType: Shape.CurveRenderer
                        XAnimator on x {
                            from: 0
                            to: -24
                            duration: 2400
                            loops: Animation.Infinite
                        }
                        ShapePath {
                            strokeColor: "#5c6b7a"
                            strokeWidth: 1.6
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            PathSvg { path: "M0 7 q6 -6 12 0 t12 0 t12 0 t12 0 t12 0 t12 0 t12 0 t12 0 t12 0 t12 0 t12 0 t12 0 t12 0 t12 0" }
                        }
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8

            Item {
                width: parent.width
                height: 14
                SectionLabel { text: "DOCKER" }
                Text {
                    anchors.right: parent.right
                    text: root.docker.length + " rodando"
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    color: root.muted
                }
            }

            Text {
                visible: root.docker.length === 0
                text: "nenhum container rodando"
                font.family: root.fontFamily
                font.pixelSize: 12
                color: root.muted
            }

            Repeater {
                model: root.docker.slice(0, 5)
                Item {
                    required property var modelData
                    required property int index
                    readonly property string h: root.health(modelData.status)
                    width: parent.width
                    height: 16
                    Rectangle {
                        id: dockerDot
                        anchors.verticalCenter: parent.verticalCenter
                        width: 7
                        height: 7
                        radius: 3.5
                        color: h === "unhealthy" ? "#e06c6c" : root.fg
                        SequentialAnimation {
                            id: breathe
                            loops: Animation.Infinite
                            OpacityAnimator { target: dockerDot; from: 1; to: 0.3; duration: 1600; easing.type: Easing.InOutSine }
                            OpacityAnimator { target: dockerDot; from: 0.3; to: 1; duration: 1600; easing.type: Easing.InOutSine }
                        }
                        Timer {
                            interval: index * 600 + 1
                            running: true
                            onTriggered: breathe.start()
                        }
                    }
                    Text {
                        x: 17
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name
                        width: parent.width - 140
                        elide: Text.ElideRight
                        font.family: root.monoFamily
                        font.pixelSize: 12
                        color: root.fg
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.shortUp(modelData.status) + (h ? " · " + h : "")
                        font.family: root.fontFamily
                        font.pixelSize: 11
                        color: h === "unhealthy" ? "#e8a0a0" : root.muted
                    }
                }
            }
        }

        Item {
            readonly property bool on: !!root.info.vpn && !!root.info.vpn.name
            width: parent.width
            height: 16
            SectionLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: "VPN"
            }
            Rectangle {
                x: 40
                anchors.verticalCenter: parent.verticalCenter
                width: 7
                height: 7
                radius: 3.5
                color: parent.on ? root.fg : "transparent"
                border.color: parent.on ? root.fg : "#8c8c8c"
                border.width: 1.5
            }
            Text {
                x: 56
                anchors.verticalCenter: parent.verticalCenter
                text: parent.on ? root.info.vpn.name : "—"
                font.family: root.fontFamily
                font.pixelSize: 13
                color: root.fg
            }
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: parent.on ? "conectada" + (root.info.vpn.ip ? " · " + root.info.vpn.ip : "") : "desconectada"
                font.family: root.fontFamily
                font.pixelSize: 11
                color: root.muted
            }
        }

        Column {
            width: parent.width
            spacing: 8
            SectionLabel { text: "GIT" }
            Repeater {
                model: root.info.git || []
                Column {
                    required property var modelData
                    width: parent.width
                    spacing: 2
                    Item {
                        width: parent.width
                        height: 16
                        Text {
                            text: modelData.repo
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            color: root.fg
                        }
                        Text {
                            anchors.right: parent.right
                            text: modelData.changes > 0 ? modelData.changes + (modelData.changes === 1 ? " alteração" : " alterações") : "limpo"
                            font.family: root.fontFamily
                            font.pixelSize: 11
                            color: modelData.changes > 0 ? root.accent : root.muted
                        }
                    }
                    Text {
                        text: modelData.branch
                        width: parent.width
                        elide: Text.ElideRight
                        font.family: root.monoFamily
                        font.pixelSize: 11
                        color: "#8c8c8c"
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8
            SectionLabel { text: "CLAUDE CODE" }
            Repeater {
                model: [
                    { label: "5 horas", pct: root.info.claude ? root.info.claude.five : null, reset: root.info.claude ? root.info.claude.fiveReset : "" },
                    { label: "semana", pct: root.info.claude ? root.info.claude.week : null, reset: root.info.claude ? root.info.claude.weekReset : "" }
                ]
                Column {
                    required property var modelData
                    width: parent.width
                    spacing: 6
                    Item {
                        width: parent.width
                        height: 16
                        Text {
                            text: modelData.label
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            color: root.fg
                        }
                        Text {
                            anchors.right: parent.right
                            textFormat: Text.StyledText
                            text: (modelData.pct === null || modelData.pct === undefined ? "--" : modelData.pct + "%") + (modelData.reset ? "  <font color=\"#9a9a9a\">· reset " + modelData.reset + "</font>" : "")
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            color: root.fg
                        }
                    }
                    Bar {
                        pct: (modelData.pct || 0) / 100
                    }
                }
            }
        }
    }
}
