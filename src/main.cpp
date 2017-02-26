#include <QApplication>
#include <QQuickView>

#include "NESEmulator.h"
#include "EmulationRunner.h"


int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	qmlRegisterType<NESEmulator>("LaiNES", 1, 0, "NESEmulator");

	QQuickView view;
	view.setResizeMode(QQuickView::SizeRootObjectToView);
	view.setSource(QUrl("qrc:///main.qml"));
	view.show();

	int result = app.exec();

	EmulationRunner::waitAll();	

	return result;
}
