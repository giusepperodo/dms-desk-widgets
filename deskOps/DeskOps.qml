import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    minWidth: 300
    minHeight: 400
    property real defaultWidth: 360
    property real defaultHeight: 540

    readonly property color fg: "#f2f2f2"
    readonly property color muted: "#9a9a9a"
    readonly property color track: "#2a2d2a"
    readonly property color panel: Qt.rgba(0, 0, 0, 0.88)
    readonly property color accent: "#e0a36c"
    readonly property color danger: "#e06c6c"
    readonly property string fontFamily: "Inter"
    readonly property string monoFamily: "JetBrains Mono"
    readonly property string ecgPath: "M0 15 H110 L118 15 L124 5 L132 27 L140 1 L148 22 L154 15 H320"

    property var info: ({ prs: [], reviewCount: 0, runs: [], linear: null, signoz: null })

    readonly property var errored: (info.signoz || []).filter(s => s.errors > 0)
    readonly property var healthy: (info.signoz || []).filter(s => s.errors === 0)
    readonly property bool hasSignoz: info.signoz !== null && info.signoz !== undefined
    readonly property bool hasLinear: info.linear !== null && info.linear !== undefined
    readonly property bool alert: errored.length > 0

    function fmtPct(v) {
        return (v >= 10 ? Math.round(v) : v.toFixed(1)).toString().replace(".", ",") + "%";
    }

    Process {
        id: fetcher
        command: ["timeout", "60", Quickshell.env("HOME") + "/.config/DankMaterialShell/plugins/deskOps/ops-data.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.info = JSON.parse(text);
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 120000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
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

    component Hint: Text {
        font.family: root.fontFamily
        font.pixelSize: 11
        color: "#8c8c8c"
        wrapMode: Text.WordWrap
    }

    component Header: Item {
        property string label
        property string rightText
        property color rightColor: root.muted
        width: parent.width
        height: 14
        SectionLabel { text: parent.label }
        Text {
            anchors.right: parent.right
            text: parent.rightText
            font.family: root.fontFamily
            font.pixelSize: 11
            color: parent.rightColor
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
            height: 62

            Column {
                anchors.bottom: parent.bottom
                spacing: 2
                Text {
                    text: "ops"
                    font.family: root.fontFamily
                    font.pixelSize: 30
                    font.weight: Font.ExtraLight
                    color: root.fg
                }
                Text {
                    text: !root.hasSignoz ? "sem dados de produção" : root.alert ? root.errored.length + (root.errored.length === 1 ? " serviço com erro" : " serviços com erro") : "tudo tranquilo por aqui"
                    font.family: root.fontFamily
                    font.pixelSize: 12
                    color: root.muted
                }
            }

            Item {
                anchors.right: parent.right
                width: 76
                height: 66
                scale: 0.9
                transformOrigin: Item.BottomRight

                Item {
                    id: tail
                    x: 16
                    y: 22
                    width: 60
                    height: 60
                    SequentialAnimation {
                        running: true
                        loops: Animation.Infinite
                        RotationAnimator { target: tail; from: 0; to: -14; duration: 1200; easing.type: Easing.InOutSine }
                        RotationAnimator { target: tail; from: -14; to: 0; duration: 1200; easing.type: Easing.InOutSine }
                    }
                    Shape {
                        x: -16
                        y: -22
                        width: 76
                        height: 66
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            strokeColor: root.fg
                            strokeWidth: 1.6
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            joinStyle: ShapePath.RoundJoin
                            PathSvg { path: "M44 56 C 58 60, 70 50, 64 36 C 62 46, 54 52, 46 51" }
                        }
                    }
                }

                Shape {
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeColor: root.fg
                        strokeWidth: 1.6
                        fillColor: "#000000"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin
                        PathSvg { path: "M22 60 C 18 46, 22 34, 30 30 L 40 30 C 46 34, 48 46, 44 60 Z" }
                    }
                    ShapePath {
                        strokeColor: root.fg
                        strokeWidth: 1.6
                        fillColor: "#000000"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin
                        PathSvg { path: "M26 32 L 21 12 L 31 21 L 39 21 L 49 12 L 44 32 L 35 39 Z" }
                    }
                    ShapePath {
                        strokeColor: root.fg
                        strokeWidth: 1.6
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        PathSvg { path: "M34 34 L 35 36 L 36 34" }
                    }
                }

                Shape {
                    anchors.fill: parent
                    visible: !root.alert
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeColor: root.fg
                        strokeWidth: 1.6
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        PathSvg { path: "M28 27 Q30.5 29 33 27 M37 27 Q39.5 29 42 27" }
                    }
                }

                Repeater {
                    model: root.alert ? 0 : 2
                    Text {
                        id: zee
                        required property int index
                        text: "z"
                        font.family: root.fontFamily
                        font.pixelSize: 10 - index * 2
                        color: root.muted
                        x: 54 + index * 6
                        y: 6
                        opacity: 0
                        ParallelAnimation {
                            id: zeeAnim
                            loops: Animation.Infinite
                            XAnimator { target: zee; from: 54 + zee.index * 6; to: 60 + zee.index * 6; duration: 2800 }
                            YAnimator { target: zee; from: 6; to: -12; duration: 2800; easing.type: Easing.OutQuad }
                            SequentialAnimation {
                                OpacityAnimator { target: zee; from: 0; to: 1; duration: 800 }
                                OpacityAnimator { target: zee; from: 1; to: 0; duration: 2000 }
                            }
                        }
                        Timer {
                            interval: zee.index * 1400 + 1
                            running: true
                            onTriggered: zeeAnim.start()
                        }
                    }
                }

                Repeater {
                    model: root.alert ? [29, 38] : []
                    Rectangle {
                        id: eye
                        required property var modelData
                        x: modelData
                        y: 25.4
                        width: 3.2
                        height: 3.2
                        radius: 1.6
                        color: root.fg
                        SequentialAnimation {
                            running: true
                            loops: Animation.Infinite
                            PauseAnimation { duration: 3800 }
                            OpacityAnimator { target: eye; from: 1; to: 0.1; duration: 90 }
                            OpacityAnimator { target: eye; from: 0.1; to: 1; duration: 90 }
                        }
                    }
                }

                Text {
                    id: bang
                    visible: root.alert
                    x: 58
                    y: 0
                    text: "!"
                    font.family: root.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: root.danger
                    SequentialAnimation {
                        running: bang.visible
                        loops: Animation.Infinite
                        OpacityAnimator { target: bang; from: 1; to: 0.3; duration: 600 }
                        OpacityAnimator { target: bang; from: 0.3; to: 1; duration: 600 }
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8

            Header {
                label: "PRODUÇÃO · SIGNOZ"
                rightText: "última hora"
            }

            Item {
                id: ecg
                width: parent.width
                height: 30

                ParallelAnimation {
                    running: true
                    loops: Animation.Infinite
                    XAnimator { target: ecgWindow; from: -40; to: ecg.width + 20; duration: 3500 }
                    XAnimator { target: ecgBright; from: 40; to: -(ecg.width + 20); duration: 3500 }
                }

                Shape {
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeColor: root.track
                        strokeWidth: 1.5
                        fillColor: "transparent"
                        PathSvg { path: root.ecgPath }
                    }
                }

                Item {
                    id: ecgWindow
                    x: -40
                    width: 40
                    height: parent.height
                    clip: true
                    Shape {
                        id: ecgBright
                        x: 40
                        width: ecg.width
                        height: ecg.height
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            strokeColor: root.alert ? root.danger : root.fg
                            strokeWidth: 1.5
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            joinStyle: ShapePath.RoundJoin
                            PathSvg { path: root.ecgPath }
                        }
                    }
                }
            }

            Hint {
                visible: !root.hasSignoz
                width: parent.width
                text: "defina SIGNOZ_API_KEY em ~/.config/desk-widgets/secrets.env"
            }

            Repeater {
                model: root.errored.slice(0, 3)
                Column {
                    required property var modelData
                    width: parent.width
                    spacing: 5
                    Item {
                        width: parent.width
                        height: 16
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 7
                            height: 7
                            radius: 3.5
                            color: root.danger
                            Rectangle {
                                id: ring
                                anchors.centerIn: parent
                                width: 20
                                height: 20
                                radius: 10
                                color: "transparent"
                                border.color: root.danger
                                border.width: 1.2
                                scale: 0.35
                                ParallelAnimation {
                                    running: true
                                    loops: Animation.Infinite
                                    ScaleAnimator { target: ring; from: 0.35; to: 1; duration: 1600; easing.type: Easing.OutQuad }
                                    OpacityAnimator { target: ring; from: 0.8; to: 0; duration: 1600 }
                                }
                            }
                        }
                        Text {
                            x: 17
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                            width: parent.width - 150
                            elide: Text.ElideRight
                            font.family: root.monoFamily
                            font.pixelSize: 12
                            color: root.fg
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.errors + " erros · " + root.fmtPct(modelData.rate)
                            font.family: root.fontFamily
                            font.pixelSize: 11
                            color: "#e8a0a0"
                        }
                    }
                    Rectangle {
                        x: 17
                        width: parent.width - 17
                        height: 3
                        radius: 2
                        color: root.track
                        Rectangle {
                            height: parent.height
                            radius: 2
                            color: root.danger
                            width: parent.width * Math.min(1, Math.max(0.02, modelData.rate / 100))
                        }
                    }
                }
            }

            Row {
                visible: root.hasSignoz && root.healthy.length > 0
                spacing: 10
                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: root.healthy.length
                        Rectangle {
                            id: okDot
                            required property int index
                            width: 7
                            height: 7
                            radius: 3.5
                            color: root.fg
                            SequentialAnimation {
                                id: okBreathe
                                loops: Animation.Infinite
                                OpacityAnimator { target: okDot; from: 1; to: 0.3; duration: 1600; easing.type: Easing.InOutSine }
                                OpacityAnimator { target: okDot; from: 0.3; to: 1; duration: 1600; easing.type: Easing.InOutSine }
                            }
                            Timer {
                                interval: okDot.index * 220 + 1
                                running: true
                                onTriggered: okBreathe.start()
                            }
                        }
                    }
                }
                Text {
                    text: root.healthy.length + (root.healthy.length === 1 ? " serviço sem erro" : " serviços sem erro")
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    color: root.muted
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8

            Header {
                label: "LINEAR"
                rightText: root.hasLinear ? (root.info.linear || []).length + " comigo" : ""
            }

            Hint {
                visible: !root.hasLinear
                width: parent.width
                text: "defina LINEAR_API_KEY em ~/.config/desk-widgets/secrets.env"
            }

            Repeater {
                model: (root.info.linear || []).slice(0, 4)
                Item {
                    id: issueRow
                    required property var modelData
                    readonly property bool review: /review/i.test(modelData.status)
                    width: parent.width
                    height: 16
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 12
                        height: 12
                        radius: 6
                        color: "transparent"
                        border.color: issueRow.review ? root.accent : root.muted
                        border.width: 1.4
                        Rectangle {
                            x: 6
                            y: 2
                            width: 4
                            height: issueRow.review ? 8 : 4
                            radius: 1
                            color: parent.border.color
                        }
                    }
                    Text {
                        x: 22
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.id
                        width: 70
                        font.family: root.monoFamily
                        font.pixelSize: 11
                        color: root.muted
                    }
                    Text {
                        x: 96
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 96
                        elide: Text.ElideRight
                        text: modelData.title
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        color: root.fg
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8

            Header {
                label: "PULL REQUESTS"
                rightText: (root.info.reviewCount || 0) + " pra revisar"
                rightColor: (root.info.reviewCount || 0) > 0 ? root.accent : root.muted
            }

            Hint {
                visible: (root.info.prs || []).length === 0
                text: "nenhum PR seu aberto"
            }

            Repeater {
                model: (root.info.prs || []).slice(0, 3)
                Item {
                    required property var modelData
                    width: parent.width
                    height: 16
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "#" + modelData.number
                        font.family: root.monoFamily
                        font.pixelSize: 11
                        color: root.muted
                    }
                    Text {
                        x: 46
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 46 - 70
                        elide: Text.ElideRight
                        text: modelData.title.replace(/^\[[A-Z]+-\d+\]\s*/, "")
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        color: root.fg
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.isDraft ? "rascunho" : modelData.reviewDecision === "APPROVED" ? "aprovado" : modelData.reviewDecision === "CHANGES_REQUESTED" ? "mudanças" : "em review"
                        font.family: root.fontFamily
                        font.pixelSize: 11
                        color: modelData.reviewDecision === "APPROVED" ? root.fg : root.accent
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8

            Header {
                label: "CI" + (root.info.ciRepo ? " · " + root.info.ciRepo.toUpperCase() : "")
                rightText: (root.info.runs || []).length > 0 ? root.info.runs[0].workflowName : ""
            }

            Rectangle {
                width: parent.width - 8
                x: 4
                height: 2
                radius: 1
                color: root.track
                Rectangle {
                    id: runner
                    y: -2
                    width: 6
                    height: 6
                    radius: 3
                    color: root.fg
                    SequentialAnimation {
                        running: true
                        loops: Animation.Infinite
                        XAnimator { target: runner; from: 0; to: runner.parent.width - 6; duration: 2600; easing.type: Easing.InOutSine }
                        XAnimator { target: runner; from: runner.parent.width - 6; to: 0; duration: 2600; easing.type: Easing.InOutSine }
                    }
                }
            }

            Repeater {
                model: (root.info.runs || []).slice(0, 2)
                Item {
                    id: runRow
                    required property var modelData
                    readonly property bool ok: modelData.conclusion === "success"
                    readonly property bool inProgress: modelData.status !== "completed"
                    width: parent.width
                    height: 16
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 14
                        height: 14
                        radius: 7
                        color: "transparent"
                        border.color: runRow.ok || runRow.inProgress ? root.fg : root.danger
                        border.width: 1.3
                        RotationAnimator on rotation {
                            running: runRow.inProgress
                            from: 0
                            to: 360
                            duration: 1500
                            loops: Animation.Infinite
                        }
                        Text {
                            anchors.centerIn: parent
                            text: runRow.inProgress ? "…" : runRow.ok ? "✓" : "✕"
                            font.pixelSize: 9
                            color: parent.border.color
                        }
                    }
                    Text {
                        x: 24
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 80
                        elide: Text.ElideRight
                        text: modelData.headBranch
                        font.family: root.monoFamily
                        font.pixelSize: 11
                        color: root.fg
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatTime(new Date(modelData.createdAt), "HH:mm")
                        font.family: root.fontFamily
                        font.pixelSize: 11
                        color: root.muted
                    }
                }
            }
        }
    }
}
