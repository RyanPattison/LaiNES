#include <QDebug>
#include <QFile>
#include <QDir>
#include <QThread>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTime>

#include "EmulationRunner.h"
#include "cpu.hpp"

QList<QThread *> EmulationRunner::threads;

EmulationRunner::EmulationRunner(QObject *parent) : QThread(parent)
{
	threads.append(this);
	m_isPaused = true;
	m_isRunning = true;
}


void EmulationRunner::run()
{
    qDebug() << "emu runner started";
	while (m_isRunning) {
            m_time.start();
		for (int i = 0; i < 3; ++i) { // run 3 frames, at 60 fps, 50ms for 3.
			if (!m_isPaused) {
				m_lock.lock();
				CPU::run_frame();
				m_lock.unlock();
			}
		}
		int elapsed = m_time.elapsed();
		int rest = 50 - elapsed;
		if (rest > 0) msleep(rest);
	}
}


EmulationRunner::~EmulationRunner() { }


void EmulationRunner::pause()
{
	m_isPaused = true;
}


void EmulationRunner::play()
{
	m_isPaused = false;
}

void EmulationRunner::stop()
{
	m_isRunning = false;
}
