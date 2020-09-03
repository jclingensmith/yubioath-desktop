#ifndef SCREENSHOT_H
#define SCREENSHOT_H
#include <QObject>
#include <QtWidgets>
#include <QVariant>

class ScreenShot: public QObject
{
    Q_OBJECT
public:
    explicit ScreenShot () : QObject() {}
    // Take a screenshot, convert it to a bitarray and return it with some metadata
    Q_INVOKABLE QString capture() {

        const QList<QScreen*> screens = QGuiApplication::screens();
        std::vector<QImage> screenshots(screens.length());
        std::transform(screens.begin(), screens.end(), screenshots.begin(), &ScreenShot::takeScreenshot);

        QImage image = screenshots[0];
        QByteArray ba;
        QBuffer buffer(&ba);
        buffer.open(QIODevice::WriteOnly);
        image.save(&buffer, "PNG");
        return QString(ba.toBase64());
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
