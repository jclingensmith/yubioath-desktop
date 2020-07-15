import QtQuick 2.5
import io.thp.pyotherside 1.4
import "utils.js" as Utils

// @disable-check M300
Python {
    id: py

    property bool yubikeyModuleLoaded: false
    property bool yubikeyReady: false
    property var queue: []

    property var availableDevices: []
    property var availableReaders: []

    property var currentDevice

    // Check if a application such as OATH, PIV, etc
    // is enabled on the current device.
    function currentDeviceEnabled(app) {
        if (!!currentDevice) {
            if (currentDevice.isNfc) {
                return currentDevice.nfcAppEnabled.includes(app)
            } else {
                return currentDevice.usbAppEnabled.includes(app)
            }
        } else {
            return false
        }
    }

    // Check if a application such as OATH, PIV, etc
    // is supported on the current device.
    function currentDeviceSupported(app) {
        if (!!currentDevice) {
            if (currentDevice.isNfc) {
                return currentDevice.nfcAppSupported.includes(app)
            } else {
                return currentDevice.usbAppSupported.includes(app)
            }
        } else {
            return false
        }
    }

    signal enableLogging(string logLevel, string logFile)
    signal disableLogging

    // Timestamp in seconds for when it's time for the
    // next calculateAll call. -1 means never
    property int nextCalculateAll: -1

    Component.onCompleted: {
        importModule('site', function () {
            call('site.addsitedir', [appDir + '/pymodules'], function () {
                addImportPath(urlPrefix + '/py')
                importModule('yubikey', function () {
                    yubikeyModuleLoaded = true
                })
            })
        })
    }

    onEnableLogging: {
        doCall('yubikey.init_with_logging',
               [logLevel || 'DEBUG', logFile || null], function () {
                   yubikeyReady = true
               })
    }

    onDisableLogging: {
        doCall('yubikey.init', [], function () {
            yubikeyReady = true
        })
    }

    onYubikeyModuleLoadedChanged: runQueue()
    onYubikeyReadyChanged: runQueue()

    function isPythonReady(funcName) {
        if (funcName.startsWith("yubikey.init")) {
            return yubikeyModuleLoaded
        } else {
            return yubikeyReady
        }
    }

    function runQueue() {
        var oldQueue = queue
        queue = []
        for (var i in oldQueue) {
            doCall(oldQueue[i][0], oldQueue[i][1], oldQueue[i][2])
        }
    }

    function doCall(func, args, cb) {
        if (!isPythonReady(func)) {
            queue.push([func, args, cb])
        } else {
            call(func, args.map(JSON.stringify), function (json) {
                if (cb) {
                    try {
                        cb(json ? JSON.parse(json) : undefined)
                    } catch (err) {
                        console.log(err, json)
                    }
                }
            })
        }
    }

    function isNEO(device) {
        return device.name === 'YubiKey NEO'
    }

    function isYubiKeyEdge(device) {
        return device.name === 'YubiKey Edge'
    }

    function isYubiKey4(device) {
        return device.name === 'YubiKey 4'
    }

    function isSecurityKeyNfc(device) {
        return device.name === 'Security Key NFC'
    }

    function isSecurityKeyByYubico(device) {
        return device.name === 'Security Key by Yubico'
    }

    function isFidoU2fSecurityKey(device) {
        return device.name === 'FIDO U2F Security Key'
    }

    function isYubiKeyStandard(device) {
        return device.name === 'YubiKey Standard'
    }

    function isYubiKeyPreview(device) {
        return device.name === 'YubiKey Preview'
    }

    function isYubiKey5NFC(device) {
        return device.name === 'YubiKey 5 NFC'
    }

    function isYubiKey5Nano(device) {
        return device.name === 'YubiKey 5 Nano'
    }

    function isYubiKey5C(device) {
        return device.name === 'YubiKey 5C'
    }

    function isYubiKey5CNano(device) {
        return device.name === 'YubiKey 5C Nano'
    }

    function isYubiKey5CNFC(device) {
        return device.name === 'YubiKey 5C NFC'
    }

    function isYubiKey5A(device) {
        return device.name === 'YubiKey 5A'
    }

    function isYubiKey5Ci(device) {
        return device.name === 'YubiKey 5Ci'
    }

    function isYubiKey5Family(device) {
        return device.name.startsWith('YubiKey 5')
    }

    function isYubiKeyFIPS(device) {
        return device.name === 'YubiKey FIPS'
    }

    function supportsNewInterfaces(deviceName) {
        return isYubiKeyPreview(deviceName) || isYubiKey5Family(deviceName)
                || isSecurityKeyByYubico(deviceName) || isSecurityKeyNfc(deviceName)
    }

    function getYubiKeyImageSource(currentDevice) {
        if (isYubiKey4(currentDevice)) {
            return "../images/yk4series.png"
        }
        if (isYubiKeyEdge(currentDevice)) {
            return "../images/ykedge.png"
        }
        if (isSecurityKeyNfc(currentDevice)) {
            return "../images/sky3.png"
        }
        if (isSecurityKeyByYubico(currentDevice)) {
            return "../images/sky2.png"
        }
        if (isFidoU2fSecurityKey(currentDevice)) {
            return "../images/sky1.png"
        }
        if (isNEO(currentDevice)) {
            return "../images/neo.png"
        }
        if (isYubiKeyStandard(currentDevice)) {
            return "../images/standard.png"
        }
        if (isYubiKeyPreview(currentDevice)) {
            return "../images/yk5nfc.png"
        }
        if (isYubiKey5NFC(currentDevice)) {
            return "../images/yk5nfc.png"
        }
        if (isYubiKey5Nano(currentDevice)) {
            return "../images/yk5nano.png"
        }
        if (isYubiKey5C(currentDevice)) {
            return "../images/yk5c.png"
        }
        if (isYubiKey5CNano(currentDevice)) {
            return "../images/yk5cnano.png"
        }
        if (isYubiKey5CNFC(currentDevice)) {
            return "../images/yk5cnfc.png"
        }
        if (isYubiKey5A(currentDevice)) {
            return "../images/yk4.png"
        }
        if (isYubiKey5Ci(currentDevice)) {
            return "../images/yk5ci.png"
        }
        if (isYubiKey5Family(currentDevice)) {
            return "../images/yk5series.png"
        }
        return "../images/yk5series.png" //default for now
    }

    function getCurrentDeviceImage() {
        if (!!currentDevice) {
            return getYubiKeyImageSource(currentDevice)
        } else {
            return ""
        }
    }

    function slotsStatus(cb) {
        doCall('yubikey.controller.slots_status', [], cb)
    }

    function eraseSlot(slot, cb) {
        doCall('yubikey.controller.erase_slot', [slot], cb)
    }

    function checkUsbDescriptorsChanged(cb) {
        doCall('yubikey.controller.check_descriptors', [], cb)
    }

    function checkReaders(filter, cb) {
        doCall('yubikey.controller.check_readers', [filter], cb)
    }

    function setMode(connections, cb) {
        doCall('yubikey.controller.set_mode', [connections], cb)
    }

    function clearCurrentDeviceAndEntries() {
        currentDevice = null
        entries.clear()
        nextCalculateAll = -1
    }

    function refreshReaders() {
        yubiKey.getConnectedReaders(function(resp) {
            if (resp.success) {
                availableReaders = resp.readers
            } else {
                console.log("failed to update readers:", resp.error_id)
            }
        })
    }

    function loadDevicesCustomReaderOuter(cb) {
        yubiKey.loadDevicesCustomReader(settings.customReaderName, function(resp) {
            if (resp.success) {
                availableDevices = resp.devices

                if (availableDevices.length === 0) {
                    clearCurrentDeviceAndEntries()
                }

                // no current device, or current device is no longer available, pick a new one
                if (!currentDevice || !availableDevices.some(dev => dev.serial === currentDevice.serial)) {
                    // new device is being loaded, clear any old device
                    clearCurrentDeviceAndEntries()
                    // Just pick the first device
                    currentDevice = availableDevices[0]
                    // If oath is enabled, do a calculate all
                    if (yubiKey.currentDeviceEnabled("OATH") && navigator.isInAuthenticator()) {
                        oathCalculateAllOuter()
                    }
                } else {
                    // the same one but potentially updated
                    currentDevice = resp.devices.find(dev => dev.serial === currentDevice.serial)
                }
            } else {
                console.log("refreshing devices failed:", resp.error_id)
                availableReaders = []
                clearCurrentDeviceAndEntries()
            }

            if (cb) {
                cb()
            }

        })
    }

    function loadDevicesUsbOuter(cb) {

        yubiKey.loadDevicesUsb(function (resp) {
            if (resp.success) {
                availableDevices = resp.devices

                if (availableDevices.length === 0) {
                    clearCurrentDeviceAndEntries()
                }

                // no current device, or current device is no longer available, pick a new one
                if (!currentDevice || !availableDevices.some(dev => dev.serial === currentDevice.serial)) {
                    // new device is being loaded, clear any old device
                    clearCurrentDeviceAndEntries()
                    // Just pick the first device
                    currentDevice = availableDevices[0]
                    // If oath is enabled, do a calculate all and go to authenticator
                    if (yubiKey.currentDeviceEnabled("OATH") && navigator.isInAuthenticator()) {
                        navigator.goToLoading()
                        navigator.goToAuthenticator()
                    }

                } else {
                    // the same one but potentially updated
                    currentDevice = resp.devices.find(dev => dev.serial === currentDevice.serial)
                }
            } else {
                console.log("refreshing devices failed:", resp.error_id)
                availableDevices = []
                clearCurrentDeviceAndEntries()
            }

            if (cb) {
                cb()
            }
        })
    }

    function pollCustomReader() {
        if (!currentDevice) {
            checkReaders(settings.customReaderName, function (resp) {
                if (resp.success) {
                    if (resp.needToRefresh) {
                        poller.running = false
                        loadDevicesCustomReaderOuter(function() {
                            poller.running = true
                        })
                    } else {
                        // Nothing changed
                   }
                } else {
                    console.log("check descriptors failed:", resp.error_id)
                    clearCurrentDeviceAndEntries()
                }
            })
        }
        refreshReaders()
    }

    function pollUsb() {

        checkUsbDescriptorsChanged(function (resp) {
            if (resp.success) {
                if (resp.usbDescriptorsChanged) {
                    poller.running = false
                    loadDevicesUsbOuter(function() {
                        poller.running = true
                    })
                } else {
                    // Nothing changed
                }

            } else {
                console.log("check descriptors failed:", resp.error_id)
                clearCurrentDeviceAndEntries()
            }
        })


    }

    function oathCalculateAllOuter(cb) {


        oathCalculateAll(function (resp) {
            if (resp.success) {
                entries.updateEntries(resp.entries, function() {
                    updateNextCalculateAll()
                    if (cb) {
                        cb()
                    }
                })
            } else {
                if (resp.error_id === 'access_denied') {
                    entries.clear()
                    currentDevice.hasPassword = true
                    navigator.goToEnterPassword()
                    return
                } else if (resp.error_id === 'no_device_custom_reader') {
                    navigator.snackBarError(navigator.getErrorMessage(resp.error_id))
                    clearCurrentDeviceAndEntries()
                    if (cb) {
                        cb()
                    }
                } else {
                    clearCurrentDeviceAndEntries()
                    console.log("calculateAll failed:", resp.error_id)
                    if (!settings.useCustomReader) {
                        loadDevicesUsbOuter()
                    }
                    if (cb) {
                        cb()
                    }
                }
            }

        })
    }

    function updateNextCalculateAll() {
        // Next calculateAll should be when a default TOTP cred expires.
        for (var i = 0; i < entries.count; i++) {
            var entry = entries.get(i)
            if (entry.code && entry.credential.period === 30) {
                // Just use the first default one
                nextCalculateAll = entry.code.valid_to
                return
            }
        }
        // No default TOTP cred found, don't set a time for nextCalculateAll
        nextCalculateAll = -1
    }

    function timeToCalculateAll() {
        return nextCalculateAll !== -1 && nextCalculateAll <= Utils.getNow()
    }

    function supportsTouchCredentials() {
        return !!currentDevice && !!currentDevice.version && parseInt(
                    currentDevice.version.split('.').join("")) >= 426
    }

    function supportsOathSha512() {
        return !!currentDevice && !!currentDevice.version && parseInt(
                    currentDevice.version.split('.').join("")) >= 431
                && !isYubiKeyFIPS(currentDevice)
    }

    function oathCalculateAll(cb) {
        var now = Math.floor(Date.now() / 1000)
        doCall('yubikey.controller.ccid_calculate_all', [now], cb)
    }

    function loadDevicesCustomReader(customReaderName, cb) {
        doCall('yubikey.controller.load_devices_custom_reader', [customReaderName],  cb)
    }

    function loadDevicesUsb(cb) {
        doCall('yubikey.controller.load_devices_usb', [],  cb)
    }

    function writeConfig(usbApplications, nfcApplications, cb) {
        doCall('yubikey.controller.write_config',
               [usbApplications, nfcApplications], cb) // TODO: lockcode
    }

    function selectCurrentSerial(serial, cb) {
        doCall('yubikey.controller.select_current_serial', [serial], cb)
    }

    function calculate(credential, cb) {
        var margin = credential.touch ? 10 : 0
        var nowAndMargin = Utils.getNow() + margin
        doCall('yubikey.controller.ccid_calculate',
               [credential, nowAndMargin], cb)
    }


    function ccidAddCredential(name, key, issuer, oathType, algo, digits, period, touch, overwrite, cb) {
        doCall('yubikey.controller.ccid_add_credential',
               [name, key, issuer, oathType, algo, digits, period, touch, overwrite], cb)
    }

    function deleteCredential(credential, cb) {
        doCall('yubikey.controller.ccid_delete_credential', [credential], cb)
    }

    function parseQr(screenShots, cb) {
        doCall('yubikey.controller.parse_qr', [screenShots], cb)
    }

    function reset(cb) {
        doCall('yubikey.controller.ccid_reset', [], cb)
    }

    function otpSlotStatus(cb) {
        doCall('yubikey.controller.otp_slot_status', [], cb)
    }

    function setPassword(password, remember, cb) {
        doCall('yubikey.controller.ccid_set_password', [password, remember], cb)
    }

    function removePassword(cb) {
        doCall('yubikey.controller.ccid_remove_password', [], cb)
    }

    function clearLocalPasswords(cb) {
        doCall('yubikey.controller.ccid_clear_local_passwords', [], cb)
    }


    function validate(password, remember, cb) {
        doCall('yubikey.controller.ccid_validate', [password, remember], cb)
    }

    function getConnectedReaders(cb) {
        doCall('yubikey.controller.get_connected_readers', [], cb)
    }
}
