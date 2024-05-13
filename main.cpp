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
#ifdef HAVE_TESTLIB
#include "tests.h"
#endif

#include <cstdio>
    ioMapData mpd;

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
        #ifdef HAVE_TESTLIB
        handleTestMode(engine, app);
        #else
        qWarning() << "Test mode is not available. Please recompile in debug mode.";
        #endif
    }

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();

}
