/*
    SPDX-FileCopyrightText: 2023, 2024 Dmitry Ilyich Sidorov <jonmagon@gmail.com>

    SPDX-License-Identifier: LGPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
         name: i18nd("plasma_applet_org.kde.plasma.notifications", "Configure")
         icon: "configure"
         source: "ConfigGeneral.qml"
    }
}
