#ifndef SCREENSHOT_H
#define SCREENSHOT_H
#include <QObject>
#include <QtWidgets>
#include <QVariant>
#include "QZXing.h"

class ScreenShot: public QObject
{
    Q_OBJECT
public:
    explicit ScreenShot () : QObject() {}
    // Take a screenshot, convert it to a bitarray and return it with some metadata
    Q_INVOKABLE QString capture(QString fileName) {

        const QList<QScreen*> screens = QGuiApplication::screens();
        std::vector<QImage> screenshots(screens.length());
        std::transform(screens.begin(), screens.end(), screenshots.begin(), &ScreenShot::takeScreenshot);

        QImage image(fileName); // Or give a path to an image with: QImage image ("path/to/image");
        QZXing decoder;
        //mandatory settings
        decoder.setDecoder( QZXing::DecoderFormat_QR_CODE);
        //optional settings
        //decoder.setSourceFilterType(QZXing::SourceFilter_ImageNormal | QZXing::SourceFilter_ImageInverted);
        decoder.setSourceFilterType(QZXing::SourceFilter_ImageNormal);
        decoder.setTryHarderBehaviour(QZXing::TryHarderBehaviour_ThoroughScanning | QZXing::TryHarderBehaviour_Rotate);

        //trigger decode
        QString result = decoder.decodeImage(image);
        return result;
    }

private:
    static QImage takeScreenshot(QScreen *screen) {
        QRect g = screen->geometry();
        return screen->grabWindow(
            0,
#ifdef Q_OS_MACOS
            g.x(), g.y(),
#else
            0, 0,
#endif
            g.width(), g.height()
        ).toImage();
    }

};

#endif // SCREENSHOT_H
