/******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Wesley Graba
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
******************************************************************************/

import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: root
    visible: true
    width: 640
    height: 480
    title: Qt.application.name

    signal consoleInputEntered(string msg)
    signal connect();
    signal disconnect();
    signal newPort(string port);

    function inputEntered() {
        consoleInputEntered(consoleInput.text)
        consoleInput.text = ""
    }

    menuBar: MenuBar {
        id: menu
        Menu {
            title: qsTr("&File")

            MenuItem {
                text: { simpleTerminal.connState ? qsTr("&Disconnect") : qsTr("&Connect") }
                onTriggered: { simpleTerminal.connState ? root.disconnect() : root.connect()}
            }

            MenuItem {
                text: qsTr("&Settings...")
                onTriggered: settingsDialog.open()
                enabled: !simpleTerminal.connState
            }

            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit();
            }
        }

        Menu {
            title: qsTr("&View")

            MenuItem {
                text: qsTr("&Autoscroll")
                onTriggered: { consoleOutput.autoscroll = !consoleOutput.autoscroll }
                checked: consoleOutput.autoscroll
                checkable: true
            }

            MenuItem {
                text: qsTr("&Clear")
                onTriggered: {
//                    consoleOutput.cursorPosition = 0
//                    consoleOutput.text = ""
                    consoleOutput.remove(0, consoleOutput.length)
                }
            }
        }

        Menu {
            title: qsTr("&Help")

            MenuItem {
                text: qsTr("&About...")
                onTriggered: aboutDialog.open()
            }
        }
    }

    statusBar: StatusBar {
        id: status
        RowLayout {
            anchors.fill: parent
            Label {
                id: notification
                text: qsTr(simpleTerminal.statusText)
                horizontalAlignment: Text.AlignLeft
                font.wordSpacing: 5.0
            }

            Label {
                id: error
                color: "red"
                text: qsTr(simpleTerminal.errorText)
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    TextField {
        id: consoleInput

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Keys.onEnterPressed: root.inputEntered()
        Keys.onReturnPressed: root.inputEntered()
        Keys.onUpPressed: { text = simpleTerminal.getPrevHistory() }
        Keys.onDownPressed: { text = simpleTerminal.getNextHistory() }
        Keys.onEscapePressed: {
            text = ""
            simpleTerminal.resetHistoryIdx()
        }

        KeyNavigation.tab: consoleOutput
        focus: true
    }

    TextArea {
        id: consoleOutput

        property bool autoscroll: true

        menu: null

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: consoleInput.top
        anchors.top: parent.top

        KeyNavigation.tab: consoleInput

        Connections {
            target: simpleTerminal
            onNewDisplayText: {
                if (consoleOutput.length > simpleTerminal.maxDspTxtChars) {
                    consoleOutput.remove(0, consoleOutput.length - simpleTerminal.maxDspTxtChars)
                }

                consoleOutput.insert(consoleOutput.length, text)
                if (consoleOutput.autoscroll) {
                    consoleOutput.cursorPosition = consoleOutput.length
                }
            }
        }

        readOnly: true
        textFormat: TextEdit.RichText
        wrapMode: TextEdit.Wrap

        font.family: "Monospace"
        font.pointSize: 10

    }

    MessageDialog {
        id: aboutDialog
        icon: StandardIcon.Information
        modality: Qt.ApplicationModal
        text: { "<p><strong>y</strong>et <strong>a</strong>nother Serial <strong>Term</strong>inal " +
                Qt.application.version +
                "<p><em>by Wesley Graba</em></p>" +
                "<p>The program is provided AS IS with NO WARRANTY OF ANY KIND.</p>" }
        title: qsTr("About ") + Qt.application.name
    }

    Dialog {
        id: settingsDialog
        modality: Qt.WindowModal
        standardButtons: StandardButton.Apply | StandardButton.Cancel
        title: qsTr("Settings")
        width: settingsLayout.width + 50

        onVisibleChanged: {
            if (visible) {

                // Baud Rate
                console.log("Current baud rate: ", serialPort.baudRate)
                switch (serialPort.baudRate)
                {
                    default:
                    case 1200:
                        baudRateCombo.currentIndex = 0
                        break

                    case 2400:
                        baudRateCombo.currentIndex = 1
                        break

                    case 4800:
                        baudRateCombo.currentIndex = 2
                        break

                    case 9600:
                        baudRateCombo.currentIndex = 3
                        break

                    case 19200:
                        baudRateCombo.currentIndex = 4
                        break

                    case 38400:
                        baudRateCombo.currentIndex = 5
                        break

                    case 57600:
                        baudRateCombo.currentIndex = 6
                        break

                    case 115200:
                        baudRateCombo.currentIndex = 7
                        break
                }

                // Data Bits
                console.log("Current data bits: " + serialPort.dataBits)
                switch (serialPort.dataBits)
                {
                    default:
                    case 5:
                        dataBitsCombo.currentIndex = 0
                        break

                    case 6:
                        dataBitsCombo.currentIndex = 1
                        break;

                    case 7:
                        dataBitsCombo.currentIndex = 2
                        break

                    case 8:
                        dataBitsCombo.currentIndex = 3
                        break
                }

                // Parity
                console.log("Parity: " + serialPort.parity)
                switch (serialPort.parity)
                {
                    default:
                    case 0:
                        parityCombo.currentIndex = 0
                        break

                    case 2:
                        parityCombo.currentIndex = 1
                        break

                    case 3:
                        parityCombo.currentIndex = 2
                        break

                }

                // Stop bits
                console.log("Stop bits: " + serialPort.stopBits)
                switch (serialPort.stopBits)
                {
                    default:
                    case 1:
                        parityCombo.currentIndex = 0
                        break

                    case 3:
                        parityCombo.currentIndex = 1
                        break

                    case 2:
                        parityCombo.currentIndex = 2
                        break
                }

                // Flow control
                console.log("Flow control: " + serialPort.flowControl)
                switch (serialPort.flowControl)
                {
                    default:
                    case 0:
                        flowCombo.currentIndex = 0
                        break

                    case 1:
                        flowCombo.currentIndex = 1
                        break

                    case 2:
                        flowCombo.currentIndex = 2
                        break
                }

                // EOM
                switch (simpleTerminal.eom)
                {
                    default:
                    case "\r":
                        console.log("EOM: CR")
                        eomCombo.currentIndex = 0
                        break;

                    case "\n":
                        console.log("EOM: LF")
                        eomCombo.currentIndex = 1
                        break;

                    case "\n\r":
                        console.log("EOM: LF+CR")
                        eomCombo.currentIndex = 2
                        break;
                }

            }
        }

        onApply: {
            console.log("Applying new settings: " + portCombo.currentText + " " + baudRateCombo.currentText + " " +
                        dataBitsCombo.currentText + " " + parityCombo.currentText + " " + stopCombo.currentText + " " +
                        flowCombo.currentText, " " + eomCombo.currentText)

            // Port
            newPort(portCombo.currentText)

            // Baud rate
            serialPort.baudRate = baudRateCombo.currentText

            // Data bits
            serialPort.dataBits = "Data" + dataBitsCombo.currentText

            // Parity
            switch (parityCombo.currentIndex)
            {
                case 0:
                    serialPort.parity = "NoParity"
                    break;

                case 1:
                    serialPort.parity = "EvenParity"
                    break;

                case 2:
                    serialPort.parity = "OddParity"
                    break;

                 default:
                     serialPort.parity = "UnknownParity"
                     break;
            }

            // Stop bits
            switch (stopCombo.currentIndex)
            {
                case 0:
                    serialPort.stopBits = "OneStop"
                    break;

                case 1:
                    serialPort.stopBits = "OneAndHalfStop"
                    break;

                case 2:
                    serialPort.stopBits = "TwoStop"
                    break;

                default:
                    serialPort.stopBits = "UnknownStopBits";
                    break;
            }

            // Flow control
            switch (flowCombo.currentIndex)
            {
                case 0:
                    serialPort.flowControl = "NoFlowControl";
                    break;

                case 1:
                    serialPort.flowControl = "HardwareControl";
                    break;

                case 2:
                    serialPort.flowControl = "SoftwareControl";
                    break;

                default:
                    serialPort.flowControl = "UnknownFlowControl";
                    break;
            }

            // EOM
            switch (eomCombo.currentIndex)
            {
                default:
                case 0:
                    simpleTerminal.eom = "\r";
                    break;

                case 1:
                    simpleTerminal.eom = "\n";
                    break;

                case 2:
                    simpleTerminal.eom = "\n\r";
                    break;
            }
        }

        GridLayout {
            id: settingsLayout
            columns: 2

            Label { text: "<strong>Port</strong>" }
            ComboBox {
                id: portCombo
                model: portsListModel
            }

            Label { text: "<strong>Baud Rate</strong>" }
            ComboBox {
                id: baudRateCombo
                model: baudListModel
            }

            Label { text: "<strong>Data Bits</strong>" }
            ComboBox {
                id: dataBitsCombo
                model: [5, 6, 7, 8]
            }

            Label { text: "<strong>Parity</strong>" }
            ComboBox {
                id: parityCombo
                model: ["None", "Even", "Odd"]
                currentIndex: 0
            }

            Label { text: "<strong>Stop Bits</strong>" }
            ComboBox {
                id: stopCombo
                model: [1, 1.5, 2]
                currentIndex: 0
            }

            Label { text: "<strong>Flow Control</strong>" }
            ComboBox {
                id: flowCombo
                model: ["None", "Hardware", "Software"]
                currentIndex: 0
            }

            Label { text: "<strong>End-of-Message Terminator</strong>" }
            ComboBox {
                id: eomCombo
                model: ["CR", "LF", "LF+CR"]
                currentIndex: 0
            }
        }
    }
}



