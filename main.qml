import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

ApplicationWindow {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr(Qt.application.name)

    signal enterPressed(string msg)

    menuBar: MenuBar {
        id: menu
        Menu {
            title: qsTr("&File")

            MenuItem {
                text: qsTr("&Connect")
            }

            MenuItem {
                text: qsTr("&Disconnect")
            }

            MenuItem {
                text: qsTr("&Settings")
            }

            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit();
            }
        }

        Menu {
            title: qsTr("&About")

            MenuItem {
                text: qsTr("&" + Qt.application.name)
            }
        }
    }

    statusBar: StatusBar {
        id: status
        RowLayout {
            Label { text: "Future spot for settings ..." }
        }
    }

    TextField {
        id: consoleInput

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        Keys.onEnterPressed: {
            root.enterPressed(text)
            text = ""
        }
        Keys.onReturnPressed: {
            root.enterPressed(text)
            text = ""
        }

        focus: true
    }

    TextArea {
        id: consoleOutput
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: consoleInput.top
        anchors.top: parent.top
        readOnly: true
    }
}
