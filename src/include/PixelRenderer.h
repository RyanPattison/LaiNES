#ifndef PIXEL_RENDER_H
#define PIXEL_RENDER_H

#include <QOpenGLFunctions>
#include <QtGui/QOpenGLShaderProgram>
#include <QtGui/QOpenGLFunctions>
#include <QQuickWindow>
#include <QMutex>
#include <QDebug>

#include "common.hpp"

QT_FORWARD_DECLARE_CLASS(QOpenGLShaderProgram);
QT_FORWARD_DECLARE_CLASS(QOpenGLTexture);
QT_FORWARD_DECLARE_CLASS(QOpenGLBuffer);


class PixelRenderer : public QObject, protected QOpenGLFunctions
{
	Q_OBJECT
public:
	
	PixelRenderer(int width, int height, u8 *pixels);
	~PixelRenderer();

	void setWindow(QQuickWindow *window) { m_window = window; }
	void setColor(QColor c) { m_color = c; }
	void setViewRect(QRect rect) { resizeGL(rect.width(), rect.height()); }
	QRect viewRect() { return m_viewRect; }
	QColor color() { return m_color; }

public slots:
	void paint();

protected:
	void initializeGL();
	void paintGL();
	void resizeGL(int width, int height);
	void setViewport();
	void setBufferSize(int width, int height);

private:
	QOpenGLShaderProgram *m_program;
	QOpenGLTexture *m_texture;
	QOpenGLBuffer *m_vertices;

	QQuickWindow *m_window;
	QColor m_color;
    	QRect m_viewRect; 
	u8* m_pixels;
	int m_image_width, m_image_height;
	int m_width, m_height;
	int m_tex_width, m_tex_height;
};

#endif 
