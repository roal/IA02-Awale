:- module(liste, [nombreGrainesDansCase/3, vider/3, concat/3]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OPERATIONS SUR LISTE %%%%%%%%%%%%%%%%%%%%%

imprime([]).
imprime([T|Q]):- write(T), nl, imprime(Q).
imprime(X):- plateau(X,A), imprime(A).

nombreGrainesDansCase(Case, PJ1, NbGraines):- iemeElt(Case, 1, PJ1, NbGraines).

iemeElt(_, _, [], _):- !.
iemeElt(Case, N, [T|_], E):- N =:= Case, E is T, !.
iemeElt(Case, N, [_|Q], E):- N =\= Case, New_N is N+1, iemeElt(Case, New_N, Q, E).

vider([T|Q], Inter, Fin):- vider(Q, [T|Inter], Fin).
vider([], Inter, Inter).

setElt(Case, Valeur, [T|Q]):- iemeElt(Case, 1, [T|Q], E), E is Valeur.

concat([], L, L).
concat([T|Q], L, [T|R]):- concat(Q,L,R).

copieTete([T|_], L):- L is [T|L].
supprimeTete([_|Q], newL):- newL is Q.
