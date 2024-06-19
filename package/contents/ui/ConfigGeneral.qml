/*
    SPDX-FileCopyrightText: 2023, 2024 Dmitry Ilyich Sidorov <jonmagon@gmail.com>

    SPDX-License-Identifier: LGPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    signal configurationChanged

    function saveConfig() {
        plasmoid.configuration.minimumBrightness = minimumBrightness.value
    }

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        SpinBox {
            id: minimumBrightness
            Kirigami.FormData.label: i18n("Minimal safe brightness:")
            from: 1
            value: plasmoid.configuration.minimumBrightness
        }
    }
}
