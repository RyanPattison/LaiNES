#include <QDebug>
#include <QtQuick/qquickwindow.h>
#include <QFile>
#include <QThread>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTextStream>
#include <QIODevice>
#include <QTime>

#include <algorithm>

#include "NESEmulator.h"
#include "common.hpp"
#include "Sound_Queue.h"
#include "apu.hpp"
#include "cpu.hpp"
#include "cartridge.hpp"



// Screen size:
const unsigned WIDTH  = 256;
const unsigned HEIGHT = 240;
u16 texpix[WIDTH * HEIGHT];
enum KEY {
    KEY_A,
    KEY_B,
    KEY_SELECT,
    KEY_START,
    KEY_UP,
    KEY_DOWN,
    KEY_LEFT,
    KEY_RIGHT
};

Sound_Queue *soundQueue;
QMutex pixlock;
static u8 keys = 0;
bool NESEmulator::m_isMuted = false;

u8 NESEmulator::get_joypad_state(int n)
{
	return keys;
}


static int newframe;
void NESEmulator::new_frame(u16* pixels)
{
    if (pixlock.tryLock(1)) {
        newframe = 1;
        std::copy(pixels, &pixels[WIDTH * HEIGHT], texpix);
        pixlock.unlock();
    }
}

void NESEmulator::new_samples(const blip_sample_t* samples, size_t count)
{
    if (not m_isMuted) {
        soundQueue->write(samples, count);
    }
}


NESEmulator::NESEmulator() : m_renderer(0)
{
	m_lock = new QMutex();
	APU::init();
	soundQueue = new Sound_Queue;
        soundQueue->start(44100, 1);
	connect(this, &QQuickItem::windowChanged, this, &NESEmulator::handleWindowChanged);
	windowChanged(window());
	m_isPaused = true;
	startTimer(16, Qt::PreciseTimer);
	m_emu = new EmulationRunner(this);
	m_emu->start(QThread::TimeCriticalPriority);
    memset(texpix, 0xFF, sizeof texpix);
}

void NESEmulator::timerEvent(QTimerEvent*)
{
    if (!m_isPaused && newframe) {
        window()->update();
        newframe = 0;
    }
}


void NESEmulator::setColor(QColor c) 
{
	m_color = c;
	if (m_renderer) {
		m_renderer->setColor(c);
	} 
}


void NESEmulator::setRect(QRect r)
{
	if (r != m_rect) {
		m_rect = r;
		emit rectChanged();
	}
}


NESEmulator::~NESEmulator()
{
}


void NESEmulator::handleWindowChanged(QQuickWindow *win)
{
	if (win) {
		connect(win, &QQuickWindow::beforeSynchronizing, this, &NESEmulator::sync, Qt::DirectConnection);
		connect(win, &QQuickWindow::sceneGraphInvalidated, this, &NESEmulator::cleanup, Qt::DirectConnection);
		win->setClearBeforeRendering(false);
	} 
}


void NESEmulator::cleanup()
{
	delete m_renderer;
	m_renderer = 0;
}


void NESEmulator::sync()
{
	if (!m_renderer) {
        m_renderer = new PixelRenderer(WIDTH, HEIGHT, reinterpret_cast<u8*>(texpix));
		connect(window(), &QQuickWindow::beforeRendering, m_renderer, &PixelRenderer::paint, Qt::DirectConnection);
		m_renderer->setColor(color());
		m_renderer->setWindow(window());
	}
	QSize size = window()->size() * window()->devicePixelRatio();
	m_renderer->setViewRect(QRect(QPoint(0, 0), size));
	setRect(m_renderer->viewRect());
	window()->update();
}


#define PRESS(key) keys |= (1 << (key));
#define RELEASE(key) keys &= ~(1 << (key));

void NESEmulator::upPressed()      	{ PRESS(KEY_UP); 	}
void NESEmulator::leftPressed() 	{ PRESS(KEY_LEFT); 	}
void NESEmulator::rightPressed() 	{ PRESS(KEY_RIGHT); 	}
void NESEmulator::downPressed() 	{ PRESS(KEY_DOWN); 	}
void NESEmulator::startPressed() 	{ PRESS(KEY_START); 	}
void NESEmulator::selectPressed() 	{ PRESS(KEY_SELECT); 	}
void NESEmulator::aPressed() 		{ PRESS(KEY_A); 	}
void NESEmulator::bPressed() 		{ PRESS(KEY_B); 	}

void NESEmulator::upReleased() 		{ RELEASE(KEY_UP); 	}
void NESEmulator::leftReleased()        { RELEASE(KEY_LEFT); 	}
void NESEmulator::rightReleased()       { RELEASE(KEY_RIGHT); 	}
void NESEmulator::downReleased()        { RELEASE(KEY_DOWN); 	}
void NESEmulator::startReleased()       { RELEASE(KEY_START); 	}
void NESEmulator::selectReleased()      { RELEASE(KEY_SELECT); 	}
void NESEmulator::aReleased() 	        { RELEASE(KEY_A); 	}
void NESEmulator::bReleased()           { RELEASE(KEY_B); 	}


bool NESEmulator::loadRom(QString path)
{
	std::string cppstr = path.toStdString();
	const char *local_path = cppstr.c_str(); 
	m_lock->lock();
	Cartridge::load(local_path);
	m_lock->unlock();
	return true;
}


void NESEmulator::stop()
{
        m_emu->stop();
}

void NESEmulator::pause()
{
	if (!m_isPaused) {
		m_isPaused = true;
        m_emu->pause();
    }
}

void NESEmulator::mute(bool mute)
{
    m_isMuted = mute;
}

void NESEmulator::play()
{
	if (m_isPaused) {
		m_isPaused = false;
        m_emu->play();
	}
}
