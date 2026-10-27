import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.Common
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    minWidth: 220
    minHeight: 200
    property real defaultWidth: 360
    property real defaultHeight: 280

    readonly property color fg: "#f2f2f2"
    readonly property color panel: Qt.rgba(0, 0, 0, 0.88)
    readonly property color weed: "#5f7a52"
    readonly property color weedDark: "#4e6644"

    component Fish: Item {
        id: fish
        property color color: "#e0a36c"
        property real size: 1
        property real depth: 100
        property int period: 14000
        property real phase: 0
        readonly property real startX: -60
        readonly property real endX: tank.width + 20
        width: 46 * size
        height: 24 * size
        x: startX + (endX - startX) * phase
        y: depth

        SequentialAnimation {
            running: tank.width > 100
            XAnimator { target: fish; from: fish.startX + (fish.endX - fish.startX) * fish.phase; to: fish.endX; duration: fish.period * (1 - fish.phase) }
            ScriptAction { script: swimLoop.start() }
        }

        XAnimator {
            id: swimLoop
            target: fish
            from: fish.startX
            to: fish.endX
            duration: fish.period
            loops: Animation.Infinite
        }

        Item {
            id: bob
            width: parent.width
            height: parent.height
            SequentialAnimation {
                running: true
                loops: Animation.Infinite
                YAnimator { target: bob; from: 0; to: -6; duration: 1100; easing.type: Easing.InOutSine }
                YAnimator { target: bob; from: -6; to: 0; duration: 1100; easing.type: Easing.InOutSine }
            }

        Item {
            id: tailPivot
            x: 16 * fish.size - 16 * fish.size
            y: 12 * fish.size - 16 * fish.size
            width: 32 * fish.size
            height: 32 * fish.size
            SequentialAnimation {
                running: true
                loops: Animation.Infinite
                RotationAnimator { target: tailPivot; from: -12; to: 12; duration: 260 }
                RotationAnimator { target: tailPivot; from: 12; to: -12; duration: 260 }
            }
            Shape {
                x: 0
                y: 6 * fish.size
                width: 16 * fish.size
                height: 20 * fish.size
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    fillColor: fish.color
                    strokeColor: "transparent"
                    PathSvg { path: "M" + 16 * fish.size + " " + 10 * fish.size + " L 0 0 L " + 3 * fish.size + " " + 10 * fish.size + " L 0 " + 20 * fish.size + " Z" }
                }
            }
        }

        Rectangle {
            x: 14 * fish.size
            y: 3 * fish.size
            width: 32 * fish.size
            height: 18 * fish.size
            radius: height / 2
            color: fish.color

            Rectangle {
                x: parent.width * 0.72
                y: parent.height * 0.3
                width: 3.6 * fish.size
                height: width
                radius: width / 2
                color: "#0d0f0d"
            }
        }
        }
    }

    component Weed: Shape {
        id: weedShape
        property string svg
        property color stroke: root.weed
        property int delay: 0
        width: 40
        height: 140
        transformOrigin: Item.Bottom
        preferredRendererType: Shape.CurveRenderer
        SequentialAnimation {
            id: sway
            loops: Animation.Infinite
            RotationAnimator { target: weedShape; from: -5; to: 5; duration: 2000; easing.type: Easing.InOutSine }
            RotationAnimator { target: weedShape; from: 5; to: -5; duration: 2000; easing.type: Easing.InOutSine }
        }
        Timer {
            interval: weedShape.delay + 1
            running: true
            onTriggered: sway.start()
        }
        ShapePath {
            strokeColor: weedShape.stroke
            strokeWidth: 2.2
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: weedShape.svg }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: root.panel
    }

    Rectangle {
        id: tank
        anchors.fill: parent
        anchors.margins: 16
        radius: 14
        color: Qt.rgba(0.56, 0.70, 0.85, 0.08)
        clip: true

        Item {
            width: parent.width
            height: 12
            y: 10
            clip: true
            Shape {
                width: parent.width + 60
                height: 12
                preferredRendererType: Shape.CurveRenderer
                XAnimator on x {
                    from: 0
                    to: -40
                    duration: 3000
                    loops: Animation.Infinite
                }
                ShapePath {
                    strokeColor: Qt.rgba(0.56, 0.70, 0.85, 0.6)
                    strokeWidth: 1.4
                    fillColor: "transparent"
                    PathSvg { path: "M0 6 q10 -5 20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0 t20 0" }
                }
            }
        }

        Shape {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 36
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: "#2a2620"
                strokeColor: "transparent"
                PathSvg { path: "M0 12 q" + tank.width * 0.14 + " -11 " + tank.width * 0.28 + " -2 q" + tank.width * 0.18 + " 9 " + tank.width * 0.36 + " -4 q" + tank.width * 0.18 + " -9 " + tank.width * 0.36 + " 4 V 36 H 0 Z" }
            }
        }

        Weed {
            x: 24
            y: parent.height - 146
            svg: "M20 140 C 12 108, 30 88, 20 58 C 14 38, 26 24, 22 8"
        }
        Weed {
            x: 38
            y: parent.height - 116
            height: 110
            stroke: root.weedDark
            delay: 700
            svg: "M20 110 C 28 84, 14 66, 24 42"
        }
        Weed {
            x: parent.width - 74
            y: parent.height - 136
            delay: 400
            svg: "M20 140 C 12 110, 30 94, 20 68 C 14 52, 26 42, 22 30"
        }

        Rectangle {
            x: parent.width * 0.62
            y: parent.height - 26
            width: 32
            height: 16
            radius: 8
            color: "#3a352d"
        }
        Rectangle {
            x: parent.width * 0.36
            y: parent.height - 20
            width: 20
            height: 10
            radius: 5
            color: "#3a352d"
        }

        Repeater {
            model: [[0.22, 6, 0], [0.25, 4, 900], [0.66, 5, 1800], [0.69, 3.2, 2600], [0.48, 4, 3400], [0.82, 4.4, 1300]]
            Rectangle {
                id: bubble
                required property var modelData
                x: tank.width * modelData[0]
                y: tank.height - 30
                width: modelData[1]
                height: width
                radius: width / 2
                color: "transparent"
                border.color: Qt.rgba(0.95, 0.95, 0.95, 0.7)
                border.width: 1
                opacity: 0
                ParallelAnimation {
                    id: rise
                    loops: Animation.Infinite
                    YAnimator { target: bubble; from: tank.height - 30; to: 18; duration: 4500; easing.type: Easing.InQuad }
                    SequentialAnimation {
                        OpacityAnimator { target: bubble; from: 0; to: 0.9; duration: 600 }
                        OpacityAnimator { target: bubble; from: 0.9; to: 0; duration: 3900 }
                    }
                }
                Timer {
                    interval: bubble.modelData[2] + 1
                    running: tank.height > 0
                    onTriggered: rise.start()
                }
            }
        }

        Fish {
            color: "#e0a36c"
            size: 1
            depth: tank.height * 0.24
            period: 14000
            phase: 0.7
        }
        Fish {
            color: "#f2f2f2"
            size: 0.75
            depth: tank.height * 0.5
            period: 19000
            phase: 0.2
        }
        Fish {
            color: "#e8c872"
            size: 0.6
            depth: tank.height * 0.7
            period: 11000
            phase: 0.45
        }

        Rectangle {
            x: 10
            y: 24
            width: 3
            height: parent.height * 0.3
            radius: 1.5
            color: Qt.rgba(0.95, 0.95, 0.95, 0.15)
        }
    }

    Rectangle {
        anchors.fill: tank
        radius: 14
        color: "transparent"
        border.color: Qt.rgba(0.95, 0.95, 0.95, 0.7)
        border.width: 1.4
    }
}
