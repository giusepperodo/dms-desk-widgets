import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.Common
import qs.Services
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    minWidth: 300
    minHeight: 400
    property real defaultWidth: 360
    property real defaultHeight: 560

    readonly property color fg: "#f2f2f2"
    readonly property color muted: "#9a9a9a"
    readonly property color track: "#2a2d2a"
    readonly property color panel: Qt.rgba(0, 0, 0, 0.88)
    readonly property color sunColor: "#e8c872"
    readonly property color rainColor: "#8fb3d9"
    readonly property string fontFamily: "Inter"
    readonly property var dgopModules: ["system", "cpu", "memory", "network", "disk", "diskmounts", "processes"]

    property date now: new Date()

    readonly property var w: WeatherService.weather
    readonly property int wCode: w.wCode ?? 0
    readonly property bool isNight: w.available && w.isDay === false
    readonly property bool rainy: wCode >= 51
    readonly property bool cloudy: wCode >= 2
    readonly property string weatherLabel: {
        if (!w.available)
            return "sem clima";
        if (wCode >= 95)
            return "trovoada";
        if (wCode >= 71 && wCode <= 77)
            return "neve";
        if (wCode >= 51)
            return wCode >= 80 ? "pancadas de chuva" : "chuva";
        if (wCode >= 45)
            return "neblina";
        if (wCode === 3)
            return "nublado";
        if (wCode === 2)
            return "poucas nuvens";
        return isNight ? "céu limpo" : "ensolarado";
    }

    readonly property var rootMount: {
        const mounts = DgopService.diskMounts || [];
        return mounts.find(m => (m.mountpoint ?? m.mount) === "/") ?? null;
    }

    function parseSize(s) {
        if (s === undefined || s === null)
            return 0;
        if (typeof s === "number")
            return s;
        const m = String(s).match(/([\d.]+)\s*([KMGT]?)/i);
        if (!m)
            return 0;
        const mult = { "": 1, "K": 1e3, "M": 1e6, "G": 1e9, "T": 1e12 }[m[2].toUpperCase()];
        return parseFloat(m[1]) * mult;
    }

    function fmtRate(bytes) {
        if (bytes >= 1048576)
            return (bytes / 1048576).toFixed(1).replace(".", ",") + " MB/s";
        return (bytes / 1024).toFixed(1).replace(".", ",") + " KB/s";
    }

    function fmtGB(mb) {
        return (mb / 1024).toFixed(1).replace(".", ",");
    }

    readonly property var topProcs: {
        const procs = (DgopService.processes || []).slice();
        procs.sort((a, b) => (b.cpu || 0) - (a.cpu || 0));
        return procs.slice(0, 3);
    }

    Component.onCompleted: {
        DgopService.addRef(dgopModules);
        WeatherService.addRef();
    }

    Component.onDestruction: {
        DgopService.removeRef(dgopModules);
        WeatherService.removeRef();
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    component SectionLabel: Text {
        font.family: root.fontFamily
        font.pixelSize: 10
        font.weight: Font.Medium
        font.letterSpacing: 1.6
        color: root.muted
    }

    component Meter: Column {
        id: meter
        property string label
        property string value
        property real pct: 0
        width: parent.width
        spacing: 7

        Item {
            width: parent.width
            height: valueText.height
            SectionLabel {
                text: meter.label
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: valueText
                anchors.right: parent.right
                text: meter.value
                font.family: root.fontFamily
                font.pixelSize: 13
                color: root.fg
            }
        }

        Rectangle {
            width: parent.width
            height: 3
            radius: 2
            color: root.track
            Rectangle {
                height: parent.height
                radius: 2
                color: root.fg
                width: parent.width * Math.max(0, Math.min(1, meter.pct))
                Behavior on width {
                    NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                }
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
        spacing: 20

        Item {
            width: parent.width
            height: 92

            Column {
                spacing: 2
                Row {
                    Text {
                        text: Qt.formatTime(root.now, "HH")
                        font.family: root.fontFamily
                        font.pixelSize: 68
                        font.weight: Font.ExtraLight
                        color: root.fg
                    }
                    Text {
                        text: ":"
                        opacity: root.now.getSeconds() % 2 === 0 ? 1 : 0.25
                        font.family: root.fontFamily
                        font.pixelSize: 68
                        font.weight: Font.ExtraLight
                        color: root.fg
                    }
                    Text {
                        text: Qt.formatTime(root.now, "mm")
                        font.family: root.fontFamily
                        font.pixelSize: 68
                        font.weight: Font.ExtraLight
                        color: root.fg
                    }
                }
                Text {
                    text: root.now.toLocaleDateString(Qt.locale("pt_BR"), "dddd, d 'de' MMMM")
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    color: root.muted
                }
            }

            Column {
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 2

                Item {
                    width: 88
                    height: 64
                    anchors.horizontalCenter: parent.horizontalCenter

                    Item {
                        visible: !root.rainy || root.cloudy
                        width: 60
                        height: 60
                        x: 10
                        y: 2

                        Shape {
                            id: rays
                            anchors.fill: parent
                            visible: !root.isNight
                            preferredRendererType: Shape.CurveRenderer
                            ShapePath {
                                strokeColor: root.fg
                                strokeWidth: 1.6
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap
                                PathSvg { path: "M30 6 V0 M30 60 V54 M6 30 H0 M60 30 H54 M13 13 L9 9 M51 51 L47 47 M13 47 L9 51 M51 9 L47 13" }
                            }
                            RotationAnimator on rotation {
                                from: 0
                                to: 360
                                duration: 18000
                                loops: Animation.Infinite
                                running: rays.visible
                            }
                        }

                        Rectangle {
                            id: sunCore
                            visible: !root.isNight
                            anchors.centerIn: parent
                            width: 26
                            height: 26
                            radius: 13
                            color: root.sunColor
                            SequentialAnimation {
                                running: sunCore.visible
                                loops: Animation.Infinite
                                OpacityAnimator { target: sunCore; from: 1; to: 0.6; duration: 2000; easing.type: Easing.InOutSine }
                                OpacityAnimator { target: sunCore; from: 0.6; to: 1; duration: 2000; easing.type: Easing.InOutSine }
                            }
                        }

                        Rectangle {
                            id: moon
                            visible: root.isNight
                            x: 16
                            y: 16
                            width: 28
                            height: 28
                            radius: 14
                            color: "#ece6d2"
                            SequentialAnimation {
                                running: moon.visible
                                loops: Animation.Infinite
                                YAnimator { target: moon; from: 16; to: 12; duration: 3000; easing.type: Easing.InOutSine }
                                YAnimator { target: moon; from: 12; to: 16; duration: 3000; easing.type: Easing.InOutSine }
                            }
                        }
                    }

                    Shape {
                        id: cloud
                        visible: root.cloudy
                        width: 88
                        height: 64
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            strokeColor: root.fg
                            strokeWidth: 1.6
                            fillColor: "#000000"
                            joinStyle: ShapePath.RoundJoin
                            PathSvg { path: "M26 52 H70 A11 11 0 0 0 68 30 A15 15 0 0 0 40 26 A12 12 0 0 0 26 52 Z" }
                        }
                        SequentialAnimation {
                            running: cloud.visible
                            loops: Animation.Infinite
                            XAnimator { target: cloud; from: -2; to: 4; duration: 3000; easing.type: Easing.InOutSine }
                            XAnimator { target: cloud; from: 4; to: -2; duration: 3000; easing.type: Easing.InOutSine }
                        }
                    }

                    Repeater {
                        model: root.rainy ? 3 : 0
                        Rectangle {
                            id: drop
                            required property int index
                            width: 1.6
                            height: 7
                            radius: 1
                            rotation: 15
                            color: root.rainColor
                            x: 36 + index * 12
                            y: 52
                            opacity: 0
                            ParallelAnimation {
                                id: fall
                                loops: Animation.Infinite
                                YAnimator { target: drop; from: 52; to: 66; duration: 1100 }
                                OpacityAnimator { target: drop; from: 1; to: 0; duration: 1100 }
                            }
                            Timer {
                                interval: drop.index * 360 + 1
                                running: true
                                onTriggered: fall.start()
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.w.available ? Math.round(root.w.temp) + "°C" : "--"
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    color: root.fg
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.weatherLabel
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    color: root.muted
                }
            }
        }

        Column {
            width: parent.width
            spacing: 14

            Meter {
                label: "CPU"
                value: Math.round(DgopService.cpuUsage) + "%  ·  " + Math.round(DgopService.cpuTemperature) + "°C"
                pct: DgopService.cpuUsage / 100
            }
            Meter {
                label: "MEMÓRIA"
                value: root.fmtGB(DgopService.usedMemoryMB) + " / " + root.fmtGB(DgopService.totalMemoryMB) + " GB"
                pct: DgopService.totalMemoryMB > 0 ? DgopService.usedMemoryMB / DgopService.totalMemoryMB : 0
            }
            Meter {
                readonly property var m: root.rootMount
                label: "DISCO"
                value: m ? (m.used + " / " + (m.total ?? m.size)) : "--"
                pct: m ? root.parseSize(m.used) / Math.max(1, root.parseSize(m.total ?? m.size)) : 0
            }
            Meter {
                visible: BatteryService.batteryAvailable
                label: "BATERIA"
                value: Math.round(BatteryService.batteryLevel) + "%  ·  " + (BatteryService.isCharging ? "carregando" : BatteryService.isPluggedIn ? "na tomada" : "na bateria")
                pct: BatteryService.batteryLevel / 100
            }
        }

        Item {
            width: parent.width
            height: 16
            SectionLabel {
                text: "REDE"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                anchors.right: parent.right
                text: "↓ " + root.fmtRate(DgopService.networkRxRate) + "    ↑ " + root.fmtRate(DgopService.networkTxRate)
                font.family: root.fontFamily
                font.pixelSize: 13
                color: root.fg
            }
        }

        Column {
            width: parent.width
            spacing: 8
            SectionLabel {
                text: "PROCESSOS"
            }
            Repeater {
                model: root.topProcs
                Item {
                    required property var modelData
                    width: parent.width
                    height: 16
                    Text {
                        text: modelData.command || "?"
                        width: parent.width - 60
                        elide: Text.ElideRight
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        color: root.fg
                    }
                    Text {
                        anchors.right: parent.right
                        text: (modelData.cpu || 0).toFixed(1).replace(".", ",") + "%"
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        color: "#c8c8c8"
                    }
                }
            }
        }
    }
}
