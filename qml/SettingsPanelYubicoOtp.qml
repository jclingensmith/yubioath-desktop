import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    RowLayout {
        StyledTextField {
            id: publicIdInput
            labelText: qsTr("Public ID")
        }

        ToolButton {
            id: btnUseSerial
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            onClicked: useSerial()
            Keys.onReturnPressed: useSerial()
            Keys.onEnterPressed: useSerial()

            Accessible.role: Accessible.Button
            Accessible.name: "Use serial"
            Accessible.description: "Use serial"

            ToolTip {
                text: qsTr("Use serial as Public ID")
                delay: 1000
                parent: parent
                visible: parent.hovered
                Material.foreground: toolTipForeground
                Material.background: toolTipBackground
            }

            icon.source: "../images/refresh.svg"
            icon.color: primaryColor
            opacity: hovered ? fullEmphasis : lowEmphasis

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: false
            }
        }
    }

    RowLayout {
        StyledTextField {
            id: privateIdInput
            labelText: qsTr("Private ID")
            validator: RegExpValidator {
                regExp: /[0-9a-fA-F]{12}$/
            }
        }

        ToolButton {
            id: btnGeneratePrivateId
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            onClicked: generatePrivateId()
            Keys.onReturnPressed: generatePrivateId()
            Keys.onEnterPressed: generatePrivateId()

            Accessible.role: Accessible.Button
            Accessible.name: "Generate"
            Accessible.description: "Generate a random Private ID"

            ToolTip {
                text: qsTr("Generate a random Private ID")
                delay: 1000
                parent: parent
                visible: parent.hovered
                Material.foreground: toolTipForeground
                Material.background: toolTipBackground
            }

            icon.source: "../images/refresh.svg"
            icon.color: primaryColor
            opacity: hovered ? fullEmphasis : lowEmphasis

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: false
            }
        }
    }

    RowLayout {
        StyledTextField {
            id: secretKeyInput
            labelText: qsTr("Secret key")
            validator: RegExpValidator {
                regExp: /[0-9a-fA-F]{32}$/
            }
        }

        ToolButton {
            id: btnGenerateSecretKey
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            onClicked: generateSecretKey()
            Keys.onReturnPressed: generateSecretKey()
            Keys.onEnterPressed: generateSecretKey()

            Accessible.role: Accessible.Button
            Accessible.name: "Generate"
            Accessible.description: "Generate a random secret key"

            ToolTip {
                text: qsTr("Generate a random secret key")
                delay: 1000
                parent: parent
                visible: parent.hovered
                Material.foreground: toolTipForeground
                Material.background: toolTipBackground
            }

            icon.source: "../images/refresh.svg"
            icon.color: primaryColor
            opacity: hovered ? fullEmphasis : lowEmphasis

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: false
            }
        }
    }

    function useSerial() {
        yubiKey.serialModhex(function (res) {
            publicIdInput.text = res
        })
    }

    function generatePrivateId() {
        yubiKey.randomUid(function (res) {
            privateIdInput.text = res
        })
    }

    function generateSecretKey() {
        yubiKey.randomKey(16, function (res) {
            secretKeyInput.text = res
        })
    }

    function programYubiOtp(slot) {
        yubiKey.programOtp(slot, publicIdInput.text,
                           privateIdInput.text, secretKeyInput.text, function (resp) {
                               if (resp.success) {
                                   navigator.snackBar(qsTr("Configured Yubico OTP credential"))
                               } else {
                                   if (resp.error_id === 'write error') {
                                       navigator.snackBar(qsTr("Failed to modify. Make sure the YubiKey does not have restricted access."))
                                   } else {
                                       navigator.snackBarError(
                                                   navigator.getErrorMessage(
                                                       resp.error_id))
                                   }
                               }
                           })
    }
}


