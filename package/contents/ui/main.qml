/*
    SPDX-FileCopyrightText: 2023, 2024 Dmitry Ilyich Sidorov <jonmagon@gmail.com>

    SPDX-License-Identifier: LGPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: main

    property string displayName: i18n("plasma_applet_org.kde.plasma.brightness", "Brightness")

    property int minimumScreenBrightness: plasmoid.configuration.minimumBrightness
    property int maximumScreenBrightness: 100
    property int screenBrightness: 100
    property string screenOutput

    MessageDialog {
        id: errorDialog
        title: "An error occuried"
        text: "Failed to get the current brightness and output values with xrandr."
    }

    preferredRepresentation: compactRepresentation

    fullRepresentation: PlasmaExtras.Representation {
        id: dialogItem

        Layout.minimumWidth: Kirigami.Units.gridUnit * 10
        Layout.maximumWidth: Kirigami.Units.gridUnit * 80
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20

        Layout.preferredHeight: implicitHeight

        contentItem: BrightnessItem {
            id: brightnessSlider

            icon.name: "video-display-brightness"
            text: i18nd("plasma_applet_org.kde.plasma.brightness", "Display Brightness")
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
                console.log(`xrandr --output ${screenOutput} --brightness ${screenBrightness / 100}`)
            }
        }
    }

    compactRepresentation: Kirigami.Icon {
        source: Plasmoid.icon
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: function (mouse) {
                if (mouse.button === Qt.LeftButton) {
                    if (main.expanded) {
                        main.expanded = false
                    } else {
                        executable.exec("xrandr --verbose | grep -m 2 -i \" connected\\|brightness\"")
                    }
                }
            }
        }
    }

    Connections {
        target: executable
        onExited: function(exitCode, exitStatus, stdout, stderr) {
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

                    if (!main.expanded) {
                        main.expanded = true
                    }
                }
            }
            else {
                errorDialog.visible = true
            }
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
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
