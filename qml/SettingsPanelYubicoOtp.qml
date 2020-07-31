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

        CheckBox {
            id: useSerialCb
            text: qsTr("Use serial")
            onCheckedChanged: useSerial()
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Use the encoded serial number of the YubiKey as Public ID")
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

        StyledButton {
            id: generatePrivateIDBtn
            text: qsTr("Generate")
            onClicked: generatePrivateId()
            toolTipText: qsTr("Generate a random Private ID")
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
        StyledButton {
            id: generateSecretKeyBtn
            text: qsTr("Generate")
            onClicked: generateSecretKey()
            toolTipText: qsTr("Generate a random secret key")
        }
    }

    function useSerial() {
        if (useSerialCb.checked) {
            yubiKey.serialModhex(function (res) {
                publicIdInput.text = res
            })
        }
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


