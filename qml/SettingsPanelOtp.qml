import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

StyledExpansionPanel {
    id: otpConfigurationPanel
    label: slot === 1 ? qsTr("Short touch (slot 1)") : qsTr("Long touch (slot 2)")
    description: getDescription()
    isVisible: yubiKey.currentDeviceEnabled("OATH")

    property bool isBusy

    property int slot: 1

    property bool credentialTypeYubicoOTP: credentialTypeCombobox.currentIndex === 1
    property bool credentialTypeChallengeResponse: credentialTypeCombobox.currentIndex === 2
    property bool credentialTypeStaticPassword: credentialTypeCombobox.currentIndex === 3
    property bool credentialTypeOATHHOTP: credentialTypeCombobox.currentIndex === 4

    property string slot1Configured: qsTr("Slot is empty")
    property string slot2Configured: qsTr("Slot is empty")

    function getDescription() {
        isBusy = true
        yubiKey.slotsStatus(function (resp) {
            if (resp.success) {
                if (resp.status[0]) {
                    slot1Configured = qsTr("Slot is programmed")
                }
                if (resp.status[1]) {
                    slot2Configured = qsTr("Slot is programmed")
                }

                isBusy = false
            } else {
                if (resp.error_id === 'timeout') {
                    navigator.snackBarError(qsTr("Failed to load OTP application"))
                } else {
                    navigator.snackBarError(
                                navigator.getErrorMessage(
                                    resp.error_id))
                }
                navigator.home()
            }
        })
        if (slot == 1)
            return slot1Configured
        else
            return slot2Configured
    }

    function confirmDelete() {
        navigator.confirm({
            "heading": qsTr("Delete configuration?"),
            "message": qsTr("Do you want to delete the content of %1? This permanently deletes the configuration.").arg(label),
            "acceptedCb": function () {
                yubiKey.eraseSlot(slot, function (resp) {
                    if (resp.success) {
                        getDescription()
                        navigator.snackBar(qsTr("Configured interfaces"))
                    } else {
                        if (resp.error_id === 'write error') {
                            //views.otpWriteError()
                        } else {
                            //views.otpFailedToConfigureErrorPopup(resp.error_id)
                        }
                    }
                })

            }
        })
    }


    function getComboBoxIndex(digits) {
        switch (digits) {
        case 0:
            return 0
        case 6:
            return 1
        case 7:
            return 2
        case 8:
            return 3
        default:
            return 0
        }
    }


    ColumnLayout {

        StyledComboBox {
            id: credentialTypeCombobox
            label: qsTr("Credential type")
            model: ["","Yubico OTP", "Challenge response", "Static password", "OATH-HOTP"]

            function getCurrentLabel() {
                switch (credentialTypeCombobox.currentIndex) {
                case 1:
                    return "A Yubico OTP is a 44-character, one use, secure, 128-bit encrypted Public ID and Password."
                case 2:
                    return "YubiKey creates a \"response\" based on a provided \"challenge\" and a shared secret."
                case 3:
                    return "Store a long static password on the YubiKey so you don't have to remember it."
                case 4:
                    return "OATH..."
                default:
                    return ""
                }
            }
        }

        Label {
            Layout.fillWidth: true
            font.pixelSize: 12
            color: primaryColor
            opacity: lowEmphasis
            text: credentialTypeCombobox.getCurrentLabel()
            wrapMode: Text.WordWrap
            Layout.rowSpan: 1
            bottomPadding: 8
        }
    }


    ColumnLayout {
        visible: otpConfigurationPanel.credentialTypeYubicoOTP

        StyledTextField {
            id: otpPublicId
            labelText: qsTr("Public id")
        }
        StyledTextField {
            id: otpPrivateId
            labelText: qsTr("Private id")
        }
        StyledTextField {
            id: otpSecretKey
            labelText: qsTr("Secret key")
        }
    }

    ColumnLayout {
        visible: otpConfigurationPanel.credentialTypeChallengeResponse

        StyledTextField {
            id: otpChallengeResponse
            labelText: qsTr("Secret key")
        }
    }

    ColumnLayout {
        visible: otpConfigurationPanel.credentialTypeStaticPassword

        StyledTextField {
            id: otpStaticPassword
            labelText: qsTr("Password")
        }
    }

    RowLayout {
        Layout.topMargin: 16
        Layout.alignment: Qt.AlignRight | Qt.AlignTop

        StyledButton {
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            enabled: slot == 1 ? (slot1Configured === qsTr("Slot is programmed") ) : (slot2Configured === qsTr("Slot is programmed"))
            text: "Delete"
            onClicked: {
                confirmDelete()
            }
        }
        StyledButton {
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            text: "Apply"
        }
    }
}
