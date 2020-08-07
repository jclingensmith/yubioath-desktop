import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    RowLayout {
        StyledTextField {
            id: secretKeyInput
            labelText: qsTr("Secret key")
            validator: validator
        }

        StyledButton {
            id: generateSecretKeyBtn
            text: qsTr("Generate")
            onClicked: generateSecretKey()
            toolTipText: qsTr("Generate a random Secret Key")

        }
    }

    RowLayout {
        CheckBox {
            id: requireTouchCb
            text: qsTr("Require touch")
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("YubiKey will require a touch for the challenge-response operation")
        }
    }

    function generateSecretKey() {
        yubiKey.randomKey(20, function (res) {
            secretKeyInput.text = res
        })
    }

    RegExpValidator {
        id: validator
        regExp: /([0-9a-fA-F]{2}){1,20}$/
    }

    function programChallengeResponse(slot) {
        yubiKey.programChallengeResponse(slot,
                                         secretKeyInput.text,
                                         requireTouchCb.checked,
                                         function (resp) {
                                             if (resp.success) {
                                                 navigator.snackBar(
                                                             qsTr("Configured Challenge-Response credential"))
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


