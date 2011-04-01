/*  $Id$

    Part of XPCE --- The SWI-Prolog GUI toolkit

    Author:        Jan Wielemaker and Anjo Anjewierden
    E-mail:        jan@swi.psy.uva.nl
    WWW:           http://www.swi.psy.uva.nl/projects/xpce/
    Copyright (C): 1985-2002, University of Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/


:- module(swi_prolog_emacs_binding, []).
:- use_module(library(pce)).
:- require([ start_emacs/0
	   ]).

:- multifile
	user:message_hook/3.
:- dynamic
	user:message_hook/3.


		 /*******************************
		 *          WARNINGS		*
		 *******************************/

:- pce_global(@prolog_warnings, make_prolog_warning_list).

make_prolog_warning_list(L) :-
	new(L, emacs_hit_list('SWI-Prolog warnings')),
	send(L, clear_on_append, @on),
	send(L, expose_on_append, @on),
	send(L, message, error_at_location).

clear_message_list :-
	(   object(@prolog_warnings)
	->  send(@prolog_warnings, clear)
	;   true
	).

%%	ide_message(+Location, +String)
%
%	Display system messages in a graphical window.

ide_message(Path:Line, String) :-
	start_emacs,
	new(Buffer, emacs_buffer(Path)),
	get(Buffer, scan, 0, line, Line-1, start, SOL),
	send(@prolog_warnings, append_hit, Buffer, SOL, @default, String).

message_to_pce(Term, Lines, Path:Line, String) :-
	(   Term = error(syntax_error(Error),
			 file(Path, Line, _LinePos, _CharPos))
	->  new(String, string('Syntax error: %s', Error))
	;   Term = error(_, Location),
	    nonvar(Location),
	    Location = file(Path, Line)
	->  make_message(Lines, String)
	;   source_location(Path, Line),
	    make_message(Lines, String)
	),
	atom(Path).


make_message(Lines, String) :-
	phrase(make_message(Lines), Chars), !,
	new(String, string(Chars)).

make_message([]) -->
	[].
make_message([nl|T]) -->
	" ",
	make_message(T).
make_message([Fmt-Args|T]) --> !,
	{ format(codes(Codes, Tail), Fmt, Args)
	},
	dlist(Codes, Tail),
	make_message(T).
make_message([Fmt|T]) -->
	make_message([Fmt-[]|T]).

dlist(Codes, Tail, Codes, Tail).

%%	user:message_hook(+Term, +Level, +Lines)
%
%	Hook clauses that direct error messages to the (xpce) IDE.

user:message_hook(Term, Level, Lines) :-
	accept_level(Level),
	\+ object(@loading_emacs),
	message_to_pce(Term, Lines, Location, String),
	in_pce_thread(ide_message(Location, String)),
	fail.
user:message_hook(make(reload(_Files)), _, _) :-
	in_pce_thread(clear_message_list),
	fail.
user:message_hook(emacs(consult(_File)), _, _) :-
	in_pce_thread(clear_message_list),
	fail.

accept_level(warning).
accept_level(error).

