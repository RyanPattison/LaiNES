#ifndef Emulation_Runner_H 
#define Emulation_Runner_H

#include <QMutex>
#include <QObject>
#include <QString>
#include <QThread>
#include <QTime>
#include <QThread>


class EmulationRunner : public QThread
{
	Q_OBJECT
public:
	EmulationRunner(QObject *parent);
	~EmulationRunner();

	static void waitAll() {
		foreach (QThread *t, threads) {
			t->wait();
		}
	}

	void play();
	void pause();
	void stop();

protected:
	virtual void run();

private:
	QMutex m_lock;
	QMutex m_pixel_lock;
	bool m_isPaused;
	bool m_isRunning;
	QTime m_time;
	static QList<QThread *> threads;
};

#endif 
