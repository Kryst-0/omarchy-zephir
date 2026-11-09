import QtQuick
import qs.Commons as Commons
import qs.Ui as Ui

Ui.Panel {
    id: root
    moduleName: "krysto.zephir"
    ipcTarget: "krysto.zephir"
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight
    property bool spinning: true
    property int speed: 2
    property int fanType: 0
    readonly property var fanModels: ["desk", "retro", "industrial", "pedestal", "ceiling", "turbine"]
    property int jokeIndex: 0
    readonly property var jokeKeys: ["joke.dangles", "joke.drips", "joke.stinks", "joke.takeoff", "joke.breeze", "joke.screws", "joke.work"]
    function nextJoke() { jokeIndex = (jokeIndex + 1) % jokeKeys.length }
    readonly property int bladeCount: fanType === 1 ? 4 : fanType === 2 ? 6 : fanType === 4 ? 5 : fanType === 5 ? 9 : 3
    Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }
    onOpenedChanged: if (opened) spinning = true

    Timer {
        interval: 5000
        repeat: true
        running: root.opened
        onTriggered: root.nextJoke()
    }

    Ui.BarIconButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        text: "󰈐"
        tooltipText: "Zephir"
        onPressed: root.toggle()
    }

    Ui.KeyboardPanel {
        id: panel
        owner: root
        anchorItem: button
        bar: root.bar
        open: root.opened
        focusTarget: panel.loadedContent
        contentWidth: Commons.Style.space(290)
        contentHeight: Commons.Style.space(445)
        content: FocusScope {
            anchors.fill: parent
            Keys.onEscapePressed: root.close()
            Column {
                anchors.fill: parent
                spacing: Commons.Style.space(10)
                Text {
                    text: "Zephir"
                    textFormat: Text.PlainText
                    color: Commons.Color.foreground
                    font.family: Commons.Style.font.family
                    font.pixelSize: Commons.Style.space(23)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item {
                    id: jokeViewport
                    width: parent.width
                    height: Commons.Style.space(50)
                    clip: true
                    Text {
                        id: jokeCaption
                        width: parent.width
                        height: parent.height
                        text: strings.t(root.jokeKeys[root.jokeIndex])
                        textFormat: Text.PlainText
                        color: Commons.Color.foreground
                        font.family: root.bar ? root.bar.fontFamily : Commons.Style.font.family
                        font.pixelSize: Commons.Style.space(16)
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    Connections {
                        target: root
                        function onJokeIndexChanged() { jokeEntrance.restart() }
                    }
                    NumberAnimation {
                        id: jokeEntrance
                        target: jokeCaption
                        property: "y"
                        from: jokeViewport.height
                        to: 0
                        duration: Commons.Style.duration(220)
                        easing.type: Easing.OutCubic
                    }
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Commons.Style.space(6)
                    Ui.Button {
                        text: "‹"
                        onClicked: root.fanType = (root.fanType + root.fanModels.length - 1) % root.fanModels.length
                    }
                    Text {
                        width: Commons.Style.space(170)
                        height: Commons.Style.space(30)
                        text: strings.t(root.fanModels[root.fanType])
                        textFormat: Text.PlainText
                        color: Commons.Color.foreground
                        font.family: Commons.Style.font.family
                        font.pixelSize: Commons.Style.font.body
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    Ui.Button {
                        text: "›"
                        onClicked: root.fanType = (root.fanType + 1) % root.fanModels.length
                    }
                }
                Item {
                    id: fan
                    width: parent.width
                    height: Commons.Style.space(225)
                    Rectangle {
                        visible: root.fanType !== 2 && root.fanType !== 4 && root.fanType !== 5
                        width: Commons.Style.space(root.fanType === 1 ? 26 : 18)
                        height: Commons.Style.space(root.fanType === 3 ? 110 : 60)
                        x: (parent.width - width) / 2
                        y: Commons.Style.space(root.fanType === 3 ? 105 : 155)
                        radius: width / 2
                        color: Commons.Color.muted
                    }
                    Rectangle {
                        visible: root.fanType !== 4
                        width: Commons.Style.space(root.fanType === 2 || root.fanType === 5 ? 190 : root.fanType === 1 ? 120 : 95)
                        height: Commons.Style.space(14)
                        radius: height / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        color: Commons.Color.foreground
                    }
                    Rectangle {
                        id: cage
                        width: Commons.Style.space(root.fanType === 3 ? 140 : 180)
                        y: root.fanType === 5 ? Commons.Style.space(20) : 0
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: root.fanType === 2 ? Commons.Style.space(16) : width / 2
                        color: Commons.Color.background
                        border.color: Commons.Color.foreground
                        border.width: root.fanType === 4 ? 0 : Commons.Style.space(root.fanType === 1 || root.fanType === 5 ? 7 : 4)

                        Item {
                            id: rotor
                            anchors.fill: parent
                            anchors.margins: Commons.Style.space(12)
                            Repeater {
                                model: root.bladeCount
                                Item {
                                    required property int index
                                    anchors.fill: parent
                                    rotation: index * 360 / root.bladeCount
                                    Rectangle {
                                        x: parent.width * 0.46
                                        y: parent.height * 0.08
                                        width: parent.width * (root.fanType === 5 ? 0.13 : root.fanType === 4 ? 0.16 : root.fanType === 2 ? 0.18 : root.fanType === 1 ? 0.25 : 0.29)
                                        height: parent.height * 0.48
                                        radius: width * (root.fanType === 2 || root.fanType === 4 ? 0.15 : 0.5)
                                        rotation: root.fanType === 2 ? -15 : -28
                                        color: root.fanType === 1 ? Commons.Color.foreground : Commons.Color.accent
                                    }
                                }
                            }
                            NumberAnimation on rotation {
                                from: 0
                                to: 360
                                duration: Commons.Style.duration(root.speed === 1 ? 360 : root.speed === 2 ? 240 : 150)
                                loops: Animation.Infinite
                                easing.type: Easing.Linear
                                running: root.opened && root.spinning && Commons.Style.duration(160) > 0
                            }
                        }
                        Repeater {
                            model: root.fanType === 4 ? 0 : root.fanType === 1 ? 5 : 3
                            Rectangle {
                                required property int index
                                anchors.centerIn: parent
                                width: parent.width * (root.fanType === 1 ? 0.30 + index * 0.13 : 0.42 + index * 0.18)
                                height: width
                                radius: width / 2
                                color: "transparent"
                                border.color: Commons.Color.foreground
                                border.width: 1
                                opacity: 0.3
                            }
                        }
                        Repeater {
                            model: root.fanType === 4 ? 0 : 6
                            Item {
                                required property int index
                                anchors.fill: parent
                                rotation: index * 30
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 1
                                    height: parent.height - Commons.Style.space(8)
                                    color: Commons.Color.foreground
                                    opacity: 0.22
                                }
                            }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: Commons.Style.space(62)
                            height: Commons.Style.space(32)
                            radius: height / 2
                            color: Commons.Color.foreground
                            Text {
                                anchors.centerIn: parent
                                text: "Zephir"
                                textFormat: Text.PlainText
                                font.family: root.bar ? root.bar.fontFamily : Commons.Style.font.family
                                font.pixelSize: Commons.Style.space(12)
                                font.bold: true
                                color: Commons.Color.background
                            }
                        }
                    }
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Commons.Style.space(6)
                    Ui.Button {
                        text: strings.t(root.spinning ? "pause" : "start")
                        onClicked: root.spinning = !root.spinning
                    }
                    Repeater {
                        model: 3
                        Ui.Button {
                            required property int index
                            text: Commons.I18n.formatNumber(index + 1)
                            selected: root.speed === index + 1
                            onClicked: { root.speed = index + 1; root.spinning = true }
                        }
                    }
                }
            }
        }
    }
}
