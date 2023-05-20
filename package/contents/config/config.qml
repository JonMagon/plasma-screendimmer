/*
    SPDX-FileCopyrightText: 2023 Dmitry Ilyich Sidorov <jonmagon@gmail.com>

    SPDX-License-Identifier: LGPL-3.0-or-later
*/

import QtQuick 2.0

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18nd("plasma_applet_org.kde.plasma.notifications", "Configure")
         icon: "configure"
         source: "ConfigGeneral.qml"
    }
}
