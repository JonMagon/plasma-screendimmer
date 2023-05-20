/*
    SPDX-FileCopyrightText: 2023 Dmitry Ilyich Sidorov <jonmagon@gmail.com>

    SPDX-License-Identifier: LGPL-3.0-or-later
*/

import QtQuick 2.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import QtQuick.Dialogs 1.2

Item {
    id: main

    property string displayName: i18n("plasma_applet_org.kde.plasma.battery", "Brightness")

    property int minimumScreenBrightness: plasmoid.configuration.minimumBrightness
    property int maximumScreenBrightness: 100
    property int screenBrightness: 100
    property string screenOutput

    MessageDialog {
        id: errorDialog
        title: "An error occuried"
        text: "Failed to get the current brightness and output values with xrandr."
        icon: StandardIcon.Critical
    }

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    Plasmoid.fullRepresentation: PlasmaExtras.Representation {
        id: dialogItem

        Layout.minimumWidth: PlasmaCore.Units.gridUnit * 10
        Layout.maximumWidth: PlasmaCore.Units.gridUnit * 80
        Layout.preferredWidth: PlasmaCore.Units.gridUnit * 20

        Layout.preferredHeight: implicitHeight

        contentItem: BrightnessItem {
            id: brightnessSlider

            icon.name: "video-display-brightness"
            text: i18nd("plasma_applet_org.kde.plasma.battery", "Display Brightness")
            value: screenBrightness
            maximumValue: maximumScreenBrightness

            stepSize: maximumScreenBrightness / 100

            enabled: screenOutput

            onMoved: {
                screenBrightness = value
                if (value < minimumScreenBrightness) {
                    screenBrightness = minimumScreenBrightness
                    return
                }

                executable.exec(`xrandr --output ${screenOutput} --brightness ${screenBrightness / 100}`)
            }

        }
    }

    Plasmoid.compactRepresentation: PlasmaCore.IconItem {
        source: Plasmoid.icon
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                if (mouse.button === Qt.LeftButton) {
                    if (plasmoid.expanded) {
                        plasmoid.expanded = false
                    } else {
                        executable.exec("xrandr --verbose | grep -m 2 -i \" connected\\|brightness\"")
                    }
                }
            }
        }
    }

    Connections {
        target: executable
        onExited: {
            if (exitCode == 0 && exitStatus == 0) {
                if (stdout != null && stdout.length > 5) {
                    var lines = stdout.trim().split('\n')
                    if (lines.length < 2) return

                    for (var i = 1; i < lines.length; i++) {
                        if (lines[i].split(' ')[0].includes('Brightness')) {
                           screenOutput = lines[i - 1].split(' ')[0]
                           screenBrightness = lines[i].split(' ')[1] * 100
                           break
                        }
                    }

                    if (!plasmoid.expanded) {
                        plasmoid.expanded = true
                    }
                }
            }
            else {
                errorDialog.visible = true
            }
        }
    }

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }
        function exec(cmd) {
            connectSource(cmd)
        }
        signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }
}
