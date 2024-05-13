#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQml>
#include <QFileSystemModel>
#include "connect.h"
#include "Extender.h"
#include "iomapdata.h"
#include "downloadmanager.h"
#include <QDebug>
#include <QDateTime>

#include <QCommandLineParser>
#include <QQuickWindow>
#include <QQuickItem>
#include <QTest>
#include <QQuickItemGrabResult>
#include <QPoint>
#include <QScreen>
#include <QThread>

#include <cstdio>
    ioMapData mpd;

void handleTestMode(QQmlApplicationEngine& engine, QGuiApplication& app);

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QApplication app(argc, argv);
    app.setOrganizationName("Power-Tune");
    app.setOrganizationDomain("power-tune.org");
    app.setApplicationName("PowerTune");

    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addOption({{"t", "test"}, "Run in test mode and take a screenshot."});
    parser.process(app);
        
    QQmlApplicationEngine engine;
    qmlRegisterType<ioMapData>("IMD", 1, 0, "IMD");
    qmlRegisterType<DownloadManager>("DLM", 1, 0, "DLM");
    qmlRegisterType<Connect>("com.powertune", 1, 0, "ConnectObject");
    engine.rootContext()->setContextProperty("IMD", new ioMapData(&engine));
    engine.rootContext()->setContextProperty("DLM", new DownloadManager(&engine));
    engine.rootContext()->setContextProperty("Connect", new Connect(&engine));
    engine.rootContext()->setContextProperty("Extender2",new Extender(&engine));
#ifdef HAVE_DDCUTIL
    engine.rootContext()->setContextProperty("HAVE_DDCUTIL", true);
#else
    engine.rootContext()->setContextProperty("HAVE_DDCUTIL", false);
#endif

    if (parser.isSet("test")) {
        handleTestMode(engine, app);
    }

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();

}

void screenShot(QQuickWindow* window, const QString& filePath) {
    if (!window) return; // Safety check

    QSharedPointer<QQuickItemGrabResult> grabResult = window->contentItem()->grabToImage();
    if (!grabResult) {
        qWarning() << "Failed to initiate grabToImage.";
        return;
    }

    QEventLoop loop;
    QObject::connect(grabResult.data(), &QQuickItemGrabResult::ready, [&loop, grabResult, filePath]() {
        if (!grabResult->image().isNull()) {
            if (grabResult->image().save(filePath)) {
                qDebug() << "Screenshot saved to" << filePath;
            } else {
                qWarning() << "Failed to save screenshot to" << filePath;
            }
        }
        loop.quit();
    });

    loop.exec(); // Wait here until the loop.quit() is called when the screenshot is ready
}

void simulateSwipe(QQuickWindow* window) {
    if (!window) return;

    // Use the window's size for calculating the center
    int centerX = window->width() / 2;
    int centerY = window->height() / 2;
    QPoint startPoint(centerX + 25, centerY); // Start 25px to the right of center
    QPoint endPoint(centerX - 25, centerY); // End 25px to the left of center

    // Simulate swiping from right to left
    auto pressEvent = new QMouseEvent(QEvent::MouseButtonPress, startPoint, Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);
    QCoreApplication::postEvent(window, pressEvent);

    // Simulating the drag movement
    const int steps = 10; // Number of steps in the swipe to simulate a smooth action
    for (int i = 1; i <= steps; ++i) {
        QPoint currentPoint = startPoint + (endPoint - startPoint) * i / steps;
        auto moveEvent = new QMouseEvent(QEvent::MouseMove, currentPoint, Qt::NoButton, Qt::LeftButton, Qt::NoModifier);
        QCoreApplication::postEvent(window, moveEvent);
        QThread::msleep(10); // Small delay to simulate real swipe speed
        qInfo() << "Simulating swipe at" << currentPoint;
    }

    auto releaseEvent = new QMouseEvent(QEvent::MouseButtonRelease, endPoint, Qt::LeftButton, Qt::NoButton, Qt::NoModifier);
    QCoreApplication::postEvent(window, releaseEvent);
}

void navigateSwipeViewNext(QQuickItem* swipeView) {
    if (!swipeView) return;

    // Retrieve the current index
    int currentIndex = swipeView->property("currentIndex").toInt();

    // Increment the index to navigate to the next page
    ++currentIndex;

    // Set the modified index back to the SwipeView
    swipeView->setProperty("currentIndex", currentIndex);
}


void handleTestMode(QQmlApplicationEngine& engine, QGuiApplication& app) {
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [&](QObject* obj, const QUrl&) {
        auto window = qobject_cast<QQuickWindow*>(obj);
        if (!window) {
            qWarning() << "Main window was not found. Unable to take a screenshot.";
            app.exit(-1);
            return;
        }

        window->show();
        QTest::qWaitForWindowExposed(window);
        // wait 8s to allow the night/day widgets to disappear
        // we could improve this by disabling it in the test mode
        QTest::qWait(8000);

        // Wait until the window is exposed before taking the first screenshot
        screenShot(window, "main.png");
        QTest::qWait(1000);

        QQuickItem* dashView = window->findChild<QQuickItem*>("dashView");
        if (dashView) {
            // Change to the next page to simulate a swipe
            navigateSwipeViewNext(dashView);
        } else {
            qWarning() << "SwipeView was not found. Unable to simulate swipe.";
            app.exit(-1);
        }

        QQuickItem* tabView = engine.rootObjects().first()->findChild<QQuickItem*>("tabView");
        if (tabView) {
            for (int i = 0; i < tabView->property("count").toInt(); ++i) {
                tabView->setProperty("currentIndex", i);
                QTest::qWait(500);
                screenShot(window, QString("serial_settings_%1.png").arg(i));
            }
        } else {
            qWarning() << "TabView 'tabView' not found.";
            app.exit(-1);
        }

        app.exit(-1);
    });
}
