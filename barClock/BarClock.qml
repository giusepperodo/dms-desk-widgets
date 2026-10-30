import QtQuick
import Quickshell
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginComponent {
    id: root

    property date now: new Date()

    readonly property var weekdays: ["dom", "seg", "ter", "qua", "qui", "sex", "sáb"]
    readonly property var months: ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"]
    readonly property real textSize: Theme.barTextSize(barThickness, barConfig?.fontScale, barConfig?.maximizeWidgetText)

    function pad(n) {
        return n < 10 ? "0" + n : String(n);
    }

    readonly property string hours: pad(now.getHours())
    readonly property string minutes: pad(now.getMinutes())
    readonly property string day: String(now.getDate())
    readonly property string month: months[now.getMonth()]
    readonly property string weekday: weekdays[now.getDay()]

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    pillClickAction: () => Quickshell.execDetached(["dms", "ipc", "call", "dash", "toggle", ""])

    horizontalBarPill: Component {
        Row {
            spacing: 8
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.hours + ":" + root.minutes
                font.pixelSize: root.textSize
                font.weight: Font.DemiBold
                color: Theme.widgetTextColor
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.weekday + " " + root.day + " " + root.month
                font.pixelSize: root.textSize * 0.9
                color: Theme.surfaceTextMedium
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 0
            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.hours
                font.pixelSize: root.textSize * 1.35
                font.weight: Font.Black
                color: Theme.widgetTextColor
            }
            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.minutes
                font.pixelSize: root.textSize * 1.35
                font.weight: Font.Light
                color: Theme.widgetTextColor
            }
            Item {
                width: 1
                height: 8
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: dateColumn.implicitWidth + 10
                height: dateColumn.implicitHeight + 8
                radius: 7
                color: Theme.withAlpha(Theme.surfaceText, 0.1)
                Column {
                    id: dateColumn
                    anchors.centerIn: parent
                    spacing: -1
                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.day
                        font.pixelSize: root.textSize * 0.78
                        font.weight: Font.Medium
                        color: Theme.withAlpha(Theme.surfaceText, 0.55)
                    }
                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.month.toUpperCase()
                        font.pixelSize: root.textSize * 0.58
                        font.weight: Font.Medium
                        font.letterSpacing: 0.6
                        color: Theme.withAlpha(Theme.surfaceText, 0.55)
                    }
                }
            }
        }
    }
}
