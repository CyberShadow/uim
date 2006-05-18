;;; im-switcher.scm: Action-based IM switcher
;;;
;;; Copyright (c) 2006 uim Project http://uim.freedesktop.org/
;;;
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:
;;; 1. Redistributions of source code must retain the above copyright
;;;    notice, this list of conditions and the following disclaimer.
;;; 2. Redistributions in binary form must reproduce the above copyright
;;;    notice, this list of conditions and the following disclaimer in the
;;;    documentation and/or other materials provided with the distribution.
;;; 3. Neither the name of authors nor the names of its contributors
;;;    may be used to endorse or promote products derived from this software
;;;    without specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
;;; IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;;; THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;;; PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
;;; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;;; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;;; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
;;; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;;; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
;;; OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
;;; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;;;

(require "util.scm")
(require "im.scm")
(require "i18n.scm")
(require "load-action.scm")

(define imsw-indication-id-alist
  '())

(define imsw-iconic-label-alist
  '((direct . "-")
    (anthy  . "A")
    (canna  . "C")
    (mana   . "M")
    (skk    . "S")
    (tcode  . "T")
    (byeoru . "B")))

(define imsw-default-iconic-label "IM")

(define imsw-indication-id
  (lambda (idname)
    (or (assq-cdr idname imsw-indication-id-alist)
	idname)))

(define imsw-iconic-label
  (lambda (idname)
    (or (assq-cdr idname imsw-iconic-label-alist)
	imsw-default-iconic-label)))

;; FIXME: the helper protocol must be revised as codeset included
;; in each branches, to make the switcher widget context-encoding
;; independent.
(define imsw-actions
  (lambda ()
    (reverse
     (map (lambda (im)
	    (let* ((idname (im-name im))
		   (act-name (symbolconc 'action_imsw_ idname))
		   (indication (list (imsw-indication-id idname)
				     (imsw-iconic-label idname)
				     (im-name-label im)
				     (im-short-desc im))))
	      (register-action act-name
			       (lambda (ctx) ;; indication handler
				 indication)

			       (lambda (ctx) ;; activity predicate
				 (eq? (im-name (context-im ctx))
				      idname))

			       (lambda (ctx) ;; action handler
				 (im-switch-im ctx idname)
				 (case imsw-coverage
				   ((focused-context)
				    #t)

				   ((app-global)
				    (im-switch-app-global-im ctx idname))

				   ((system-global)
				    (im-switch-system-global-im ctx idname)))))
	      act-name))
	  im-list))))

(define imsw-widget-codeset
  (or (and (feature? 'nls)
	   (bind-textdomain-codeset (gettext-package) #f))
      (locale-codeset (locale-new ""))))

;; This procedure must be called after all IM entries are prepared in
;; im-list. So the invocation is defferred to
;; imsw-add-im-switcher-widget or context-refresh-switcher-widget!.
(define imsw-register-widget
  (lambda ()
    (or (assq 'widget_im_switcher widget-proto-list)
	(let ((acts (imsw-actions)))
	  (register-widget 'widget_im_switcher
			   (activity-indicator-new acts)
			   (actions-new acts))))))

(define imsw-add-im-switcher-widget
  (lambda (widget-id-list)
    (if toolbar-show-action-based-switcher-button?
	(begin
	  (imsw-register-widget)
	  (if (memq 'widget_im_switcher widget-id-list)
	      widget-id-list
	      (cons 'widget_im_switcher widget-id-list)
	      ;;(append widget-id-list '(widget_im_switcher))
	      ))
	(delete 'widget_im_switcher widget-id-list eq?))))

(define context-init-widgets-orig context-init-widgets!)
(define context-init-widgets!
  (lambda (context widget-id-list)
    (context-init-widgets-orig context
			       (imsw-add-im-switcher-widget widget-id-list))))

(define context-list-replace-widgets-orig context-list-replace-widgets!)
(define context-list-replace-widgets!
  (lambda (target-im-name widget-id-list)
    (context-list-replace-widgets-orig
     target-im-name
     (imsw-add-im-switcher-widget widget-id-list))))

(define context-update-widget-states-orig context-update-widget-states!)
(define context-update-widget-states!
  (lambda (context act-ids)
    (if toolbar-show-action-based-switcher-button?
	(for-each widget-activate!
		  (cdr (context-widgets context))
		  (cdr act-ids))
	(context-update-widget-states-orig context act-ids))))

(define widgets-refresh-switcher-widget
  (lambda (widgets ctx)
    (if toolbar-show-action-based-switcher-button?
	(begin
	  (imsw-register-widget)
	  (if (assq 'widget_im_switcher widgets)
	      widgets
	      (cons (widget-new 'widget_im_switcher ctx)
		    widgets)))
	(alist-delete 'widget_im_switcher widgets eq?))))

(define context-refresh-switcher-widget!
  (lambda (ctx)
    (let ((toggle-state (context-toggle-state ctx))
	  (widgets (context-widgets ctx)))
      (context-set-widgets! ctx (widgets-refresh-switcher-widget widgets ctx))
      (if toggle-state
	  (let ((alt-widgets (toggle-state-widget-states toggle-state)))
	    (toggle-state-set-widget-states!
	     toggle-state
	     (widgets-refresh-switcher-widget alt-widgets ctx))))
      (if (context-focused? ctx)
	  (context-propagate-widget-configuration ctx)))))
