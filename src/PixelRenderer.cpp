#include <QOpenGLFunctions>
#include <QOpenGLContext>
#include <QOpenGLShaderProgram>
#include <QOpenGLTexture>
#include <QOpenGLBuffer>

#include "common.hpp"
#include "PixelRenderer.h"
#include "NESEmulator.h"


PixelRenderer::PixelRenderer(int width, int height, u8* pixels)
	: m_pixels(pixels)
	, m_program(0)
	, m_texture(0)
	, m_vertices(0)
{
	setBufferSize(width, height);
}


PixelRenderer::~PixelRenderer()
{
	if (m_program) delete m_program;
	if (m_texture) delete m_texture;
	if (m_vertices) delete m_vertices;
}


static int ceilpow2(int v)
{
	int c = 1;
	while (c < v) {
		c <<= 1;
	}
	return c;
}


void PixelRenderer::setBufferSize(int width, int height)
{ 
    // opengl es 2 needs powers of 2 dimensions
	m_tex_width = ceilpow2(width);
	m_tex_height = ceilpow2(height);
	m_image_width = width;
	m_image_height = height;
}


void PixelRenderer::initializeGL()
{
	initializeOpenGLFunctions();
	GLenum err = 0;
	m_texture = new QOpenGLTexture(QOpenGLTexture::Target2D);
	if ((err = glGetError())) qDebug() << "Error texture::new: " << err;
	m_texture->setFormat(QOpenGLTexture::RGBAFormat);
	if ((err = glGetError())) qDebug() << "Error textuer::setFormat: " << err;
	m_texture->setSize(m_tex_width, m_tex_height);
	if ((err = glGetError())) qDebug() << "Error texture::setSize: " << err;
	m_texture->allocateStorage();
	if ((err = glGetError())) qDebug() << "Error texture::allocate: " << err;
	m_texture->setMinMagFilters(QOpenGLTexture::Nearest, QOpenGLTexture::Nearest);
	if ((err = glGetError())) qDebug() << "Error texture::setMinMag: " << err;
	m_texture->setWrapMode(QOpenGLTexture::Repeat);
	if ((err = glGetError())) qDebug() << "Error texture::setWrap: " << err;
	m_texture->setData(QOpenGLTexture::RGBA, QOpenGLTexture::UInt16_RGB5A1, m_pixels);
	if ((err = glGetError())) qDebug() << "Error texture::setData: " << err;

	GLfloat w = m_image_width / (double)m_tex_width;
	GLfloat h = m_image_height / (double)m_tex_height;

	QVector<GLfloat> vertData {
	-1.0f, -1.0f, 0.0f, 	0.0f, h,
	 1.0f, -1.0f, 0.0f, 	   w, h,
	-1.0f, 1.0f, 0.0f, 	0.0f, 0.0f,
	 1.0f, 1.0f, 0.0f, 	   w, 0.0f
	};
	m_vertices = new QOpenGLBuffer(QOpenGLBuffer::VertexBuffer);
	m_vertices->setUsagePattern(QOpenGLBuffer::StaticDraw);
	m_vertices->create();
	m_vertices->bind();

	m_vertices->allocate(vertData.constData(), vertData.count() * sizeof (GLfloat));

	glDisable(GL_DEPTH_TEST);

	#define PROGRAM_VERTEX_ATTRIBUTE 0
	#define PROGRAM_TEXCOORD_ATTRIBUTE 1

	const char *vshader_src =
	"attribute vec4 a_position;\n"
	"attribute vec2 a_texCoord;\n"
	"varying vec2 v_texCoord;\n"
	"void main()\n"
	"{\n"
	"    gl_Position = a_position;\n"
	"    v_texCoord = a_texCoord;\n"
	"}\n";

	const char *fshader_src =
	"varying mediump vec2 v_texCoord;\n"
	"uniform sampler2D s_texture;\n"
	"void main()\n"
	"{\n"
	"   gl_FragColor =  texture2D(s_texture, v_texCoord.st);\n"
	"}\n";

	m_program = new QOpenGLShaderProgram;
	m_program->addShaderFromSourceCode(QOpenGLShader::Vertex, vshader_src);
	m_program->addShaderFromSourceCode(QOpenGLShader::Fragment, fshader_src);
	m_program->bindAttributeLocation("a_position", PROGRAM_VERTEX_ATTRIBUTE);
	m_program->bindAttributeLocation("a_texCoord", PROGRAM_TEXCOORD_ATTRIBUTE);
	m_program->link();
	m_program->bind();
	m_program->setUniformValue("s_texture", 0);
}


void PixelRenderer::paintGL()
{
	glClearColor(m_color.redF(), m_color.greenF(), m_color.blueF(), m_color.alphaF());
	glViewport(0, 0, m_width, m_height);
	glClear(GL_COLOR_BUFFER_BIT);

	setViewport();

	m_program->bind();
	m_texture->bind(0, QOpenGLTexture::ResetTextureUnit);

    pixlock.lock();
	m_texture->setData(QOpenGLTexture::RGBA, QOpenGLTexture::UInt16_RGB5A1, m_pixels);
    pixlock.unlock();

	m_vertices->bind();
	m_program->setUniformValue("s_texture", 0);
	m_program->enableAttributeArray(PROGRAM_VERTEX_ATTRIBUTE);
	m_program->enableAttributeArray(PROGRAM_TEXCOORD_ATTRIBUTE);
	m_program->setAttributeBuffer(PROGRAM_VERTEX_ATTRIBUTE, GL_FLOAT, 0, 3, 5 * sizeof (GLfloat));
	m_program->setAttributeBuffer(PROGRAM_TEXCOORD_ATTRIBUTE, GL_FLOAT, 3 * sizeof (GLfloat), 2, 5 * sizeof (GLfloat));

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	m_program->release();

	glFinish();
}


void PixelRenderer::resizeGL(int width, int height)
{
	m_width = width;
	m_height = height;
	// image is scaled by integer multiples
	int xscale = width / m_image_width;
	int yscale = height / m_image_height;
	int scale = qMin(xscale, yscale);
	int w = m_image_width * scale;
	int h = m_image_height * scale;
	int x_remaining = width - w;
	int y_remaining = height - h;
	// centred horizontally
	int x = x_remaining / 2;
	// anchored to the top with a "small" margin
	int y = y_remaining - qMin(x_remaining, y_remaining) / 8; 
	m_viewRect = QRect(x, y, w, h); 
}


void PixelRenderer::setViewport()
{
	glViewport(m_viewRect.x(), m_viewRect.y(), m_viewRect.width(), m_viewRect.height());
}


void PixelRenderer::paint()
{
	if (!m_program) {
		initializeGL();
	} 
	paintGL();
	m_window->resetOpenGLState();
}
