import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

RowLayout {
    StyledTextField {
        id: otpStaticPassword
        labelText: qsTr("Password")
    }

    StyledButton {
        id: generatePasswordBtn
        text: qsTr("Generate")
        onClicked: generatePassword()
        toolTipText: qsTr("Generate a random password")

    }

    function generatePassword() {
        yubiKey.generateStaticPw(keyboardLayout, function (resp) {
            if (resp.success) {
                otpStaticPassword.text = resp.password
            } else {
                navigator.snackBarError(resp)
                snackbarError.showResponseError(resp)
            }
        })
    }

    function programStaticPassword(slot, keyboardLayout) {
        console.log(otpStaticPassword.text)
        yubiKey.programStaticPassword(slot, otpStaticPassword.text,
                                      keyboardLayout, function (resp) {
                                          if (resp.success) {
                                              navigator.snackBar(
                                                          "Configured static password")
                                          } else {
                                              if (resp.error_id === 'write error') {
                                                  //views.otpWriteError()
                                              } else {
                                                  //views.otpFailedToConfigureErrorPopup(resp.error_id)
                                              }
                                          }
                                      })
    }

}
