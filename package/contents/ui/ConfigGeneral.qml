/*
    SPDX-FileCopyrightText: 2023 Dmitry Ilyich Sidorov <jonmagon@gmail.com>

    SPDX-License-Identifier: LGPL-3.0-or-later
*/

import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.4 as Kirigami

Item {
    id: page
    width: childrenRect.width
    height: childrenRect.height

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

