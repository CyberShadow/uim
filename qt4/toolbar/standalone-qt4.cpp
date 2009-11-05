/*

 Copyright (c) 2003-2009 uim Project http://code.google.com/p/uim/

 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. Neither the name of authors nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS'' AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE.

*/
#include <config.h>

#include "standalone-qt4.h"
#include "common-quimhelpertoolbar.h"
#include "common-uimstateindicator.h"

#include <QtCore/QPoint>
#include <QtGui/QApplication>
#include <QtGui/QCursor>
#include <QtGui/QDesktopWidget>
#include <QtGui/QHBoxLayout>
#include <QtGui/QMouseEvent>
#include <QtGui/QStyle>
#include <QtGui/QStyleOption>

#include <clocale>

#include "uim/uim.h"
#include "qtgettext.h"

static const int TOOLBAR_MARGIN_SIZE = 2;

UimStandaloneToolbar::UimStandaloneToolbar( QWidget *parent )
    : QFrame( parent, Qt::FramelessWindowHint | Qt::X11BypassWindowManagerHint )
{
    uim_init();

    QHBoxLayout *layout = new QHBoxLayout;
    layout->setMargin( 0 );
    setLayout( layout );

    adjustSize();
    UimToolbarDraggingHandler *h = new UimToolbarDraggingHandler( this );
    layout->addWidget( h );
    h->adjustSize();
    h->show();
    connect( h, SIGNAL( handleDoubleClicked() ),
                      this, SLOT( slotToolbarDoubleClicked() ) );

    
    toolbar = new QUimHelperToolbar( this );
    layout->addWidget( toolbar );
    toolbar->adjustSize();
    toolbar->show();
    connect( toolbar, SIGNAL( toolbarResized() ), this, SLOT( slotToolbarResized() ) );
    toolbar->setMargin(TOOLBAR_MARGIN_SIZE);

    // Move
    int panelHeight = 64; // FIXME!
    int screenwidth = QApplication::desktop()->screenGeometry().width();
    int screenheight = QApplication::desktop()->screenGeometry().height();
    QPoint p( screenwidth - panelHeight - toolbar->width() - h->width(), screenheight - height() - panelHeight );
    move( p );

    // Enable Dragging Feature
    connect( h, SIGNAL( moveTo( const QPoint & ) ),
                      this, SLOT( moveTo( const QPoint & ) ) );

    // Quit
    connect( toolbar, SIGNAL( quitToolbar() ),
                      qApp, SLOT( quit() ) );

    show();
}
UimStandaloneToolbar::~UimStandaloneToolbar()
{
    uim_quit();
}

void
UimStandaloneToolbar::slotToolbarResized()
{
    adjustSize();
}

void
UimStandaloneToolbar::slotToolbarDoubleClicked()
{
    if (toolbar->isVisible())
      toolbar->hide();
    else
      toolbar->show();
    adjustSize();
}

void
UimStandaloneToolbar::moveTo(const QPoint &point)
{
    move(point);
}

UimToolbarDraggingHandler::UimToolbarDraggingHandler( QWidget *parent )
        : QFrame( parent ), isDragging( false )
{
    setFrameStyle( NoFrame );

    setBackgroundRole( parent->backgroundRole() );

    setFixedWidth( 10 );
}

void UimToolbarDraggingHandler::drawContents( QPainter* p )
{
    const QStyle::State flags = QStyle::State_None | QStyle::State_Horizontal;
    QStyleOption opt;
    opt.state = flags;
    style()->drawPrimitive( QStyle::PE_IndicatorToolBarSeparator,
        &opt, p, this );
}

QSize UimToolbarDraggingHandler::sizeHint() const
{
    int width, height;
    
    width = style()->pixelMetric( QStyle::PM_DockWidgetSeparatorExtent,
        0, this );
    height = BUTTON_SIZE + TOOLBAR_MARGIN_SIZE * 2;

    return QSize( width, height );
}

QSizePolicy UimToolbarDraggingHandler::sizePolicy() const
{
    return QSizePolicy( QSizePolicy::Minimum, QSizePolicy::Minimum );
}

void UimToolbarDraggingHandler::mousePressEvent( QMouseEvent * /* e */ )
{
    isDragging = true;
    grabMouse( QCursor( Qt::SizeAllCursor) );

    offsetX = QCursor::pos().x() - this->parentWidget()->x();
    offsetY = QCursor::pos().y() - this->parentWidget()->y();
}

void UimToolbarDraggingHandler::mouseReleaseEvent( QMouseEvent * /* e */ )
{
    isDragging = false;
    releaseMouse();
}

void UimToolbarDraggingHandler::mouseMoveEvent( QMouseEvent * /* e */ )
{
    if ( isDragging ) {
        QPoint pos = QCursor::pos();
        pos -= QPoint(offsetX, offsetY);
        emit moveTo( pos );
    }
}

void UimToolbarDraggingHandler::mouseDoubleClickEvent( QMouseEvent * /* e */ )
{
    isDragging = false;
    emit handleDoubleClicked();
}

int main( int argc, char *argv[] )
{
    setlocale(LC_ALL, "");
    bindtextdomain(PACKAGE, LOCALEDIR);
    textdomain(PACKAGE);
    bind_textdomain_codeset(PACKAGE, "UTF-8"); // ensure code encoding is UTF8-
    
    QApplication a( argc, argv );
    UimStandaloneToolbar *toolbar = new UimStandaloneToolbar( 0 );
    toolbar->show();

    return a.exec();
}