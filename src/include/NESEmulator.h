#ifndef NESEmulator_H
#define NESEmulator_H

#include <QtQuick/QQuickItem>
#include <QMutex>
#include <QTime>

#include "PixelRenderer.h"
#include "Sound_Queue.h"
#include "common.hpp"
#include "EmulationRunner.h"

extern Sound_Queue *soundQueue;
typedef short blip_sample_t;
extern QMutex pixlock;

class NESEmulator : public QQuickItem
{
	Q_OBJECT

	Q_PROPERTY(QRect rect READ rect WRITE setRect NOTIFY rectChanged)
	Q_PROPERTY(QColor color READ color WRITE setColor)

public:
	static u8 get_joypad_state(int n);
	static void new_samples(const blip_sample_t* samples, size_t count);
	static void new_frame(u16* pixels);
    static bool m_isMuted;
	NESEmulator();
	~NESEmulator();

	QRect rect() { return m_rect; }
	void setRect(QRect);
	void setColor(QColor);
	QColor color() { return m_color; }

signals:
	void rectChanged();

public slots:
	void sync();
	void cleanup();

	void play();
	void pause();
	void stop();

	void upPressed();
	void leftPressed();
	void rightPressed();
	void downPressed();

	void startPressed();
	void selectPressed();

	void aPressed();
	void bPressed();

	void upReleased();
	void leftReleased();
	void rightReleased();
	void downReleased();

	void startReleased();
	void selectReleased();

	void aReleased();
	void bReleased();

	bool loadRom(QString);

    void mute(bool);

private slots:
	void handleWindowChanged(QQuickWindow *win);
protected:
	void timerEvent(QTimerEvent *event) Q_DECL_OVERRIDE;

private:
	EmulationRunner *m_emu;
	PixelRenderer *m_renderer;
	QMutex* m_lock;
    bool m_isPaused;
	QRect m_rect;
	QColor m_color;
};

#endif	/* NESEMULATOR_H */
