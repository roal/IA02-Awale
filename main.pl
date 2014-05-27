%I - debut de l'iteration
%K - borne de la boucle
%L - Liste sur laquelle on itere
%V - Nouvelle valeur pour les elt de la lite
%boucle(I, K, L, V):- I < K, nth0(I, L, E), boucle(I+1, K, L).

%initialisation
commencerJeu:- tourPlateau(J1, J2, [4,4,4,4,4,4], [4,4,4,4,4,4], _, PJ1Fin, PJ2Fin, _).


tourPlateau(J1, J2, PJ1, PJ2, Case, PJ1Fin, PJ2Fin, GrainesRamassees):- joueur(J1),
																		write("Joueur 1 - choix case : "),
																		read(Case),
																		premiereDistributionPossible(J1, J2, PJ1, PJ2, Case, NbGrainesCase, NbGrainesRamassees),
																		calculerCaseArrivee(Case, 0, CaseArrivee),
																		nombreGrainesDansCase(Case, PJ1, NbGraines),
																		distribuerSurPlateau(0, Case, NbGrainesCase, PJ1, PJ1Tmp, CaseArrive, NbGraines),
																		CaseArrivee =:= 99,
																		calculerCaseArrivee(0, 6, CaseArrivee),
																		distribuerSurPlateau(1, Case, NbGrainesCase, PJ2, PJ2Tmp, CaseArrive, NbGraines),
																		calculNombreDeGrainesRamassees(J1, PJ2Tmp, PJ2Tmp, PJ2Fin, CaseArrive, GrainesRamassees, 6), 
																		SPJ1 is SPJ1 + GrainesRamassees.
																		\+finJeu,
																		tourPlateau(J1, J2, PJ1, PJ2, Case, PJ1Fin, PJ2Fin, GrainesRamassees).
finJeu:- joueur(J1), SJ1 => 25.
finJeu:- joueur(J1), SJ1 < 25, retract(joueur(J1)), asserta(joueur(J2)).
finJeu:- joueur(J2), SJ1 => 25.
finJeu:- joueur(J2), SJ1 < 25, retract(joueur(J1)), asserta(joueur(J2)).
																		

%Case > 1 -> copie la tête de PJ1 dans NewPJ1
%Case ==1 -> Vide la case
%case < 1 -> Ajoute une graine et nbGraines-1
%Prise = 0 pour plateau du joueur, 1 pour plateau adverse
%Case = Case en cours de traitement
distribuerSurPlateau(0, Case, NbGrainesCase, PJ1, NewPJ1, CaseArrive, NbGrainesRestantes):- Case > 1, copieTete(PJ1, NewPJ1), 
																							supprimeTete(PJ1, PJ1), Case is Case - 1,
																							distribuerSurPlateau(0, Case, NbGrainesCase, PJ1, NewPJ1, CaseArrive, NbGrainesRestantes).
																								
distribuerSurPlateau(0, 1, NbGrainesCase, PJ1, NewPJ1, CaseArrive, NbGrainesRestantes):- 	nombreGrainesDansCase(Case, PJ1, NbGrainesRestantes),
																							setElt(Case, 0, PJ1), copieTete(PJ1, NewPJ1), 
																							supprimeTete(PJ1, PJ1), Case is Case - 1,
																							distribuerSurPlateau(0, Case, NbGrainesCase, PJ1, NewPJ1, CaseArrive, NbGrainesRestantes).

distribuerSurPlateau(0, Case, NbGrainesCase, PJ1, NewPJ1, CaseArrive, NbGrainesRestantes):- Case < 1, nombreGrainesDansCase(Case, PJ1, nbGraine),
																							nbGraine is NbGraine +1,
																							copieTete(PJ1, NewPJ1),
																							supprimeTete(PJ1, PJ1), setElt(Case, NbGraine, NewPJ1).
%cas ou nombre graines restantes = 0
distribuerSurPlateau(Prise, Case, NbGrainesCase, PJ2, NewPJ2, CaseArrive, 0):- joueur(X), X =:= J1, 
																				
distribuerSurPlateau(Prise, Case, NbGrainesCase, PJ1, NewPJ1, CaseArrive, 0):- joueur(X), X =:= J2, 
																				calculNombreDeGrainesRamassees(X, PJ1, NewPJ1, , CaseArrive, GrainesRamassees, 6), 
																				SPJ2 is SPJ2 + GrainesRamassees.
%cas ou PJ1 est vide
distribuerSurPlateau(Prise, Case, NbGrainesCase, [], NewPJ1, CaseArrive, NbGrainesRestantes).

premiereDistributionPossible(J1, J2, PJ1, PJ2, Case, NbGrainesCase, NbGrainesRamassees):- J1 =:= 1, Case < 7, Case > 0, nombreGrainesDansCase(Case, PJ1, NbGrainesCase), NbGrainesCase > 0, NbGrainesRamassees is NbGrainesCase.
premiereDistributionPossible(J1, J2, PJ1, PJ2, Case, NbGrainesCase, NbGrainesRamassees):- J2 =:= 1, Case < 7, Case > 0, nombreGrainesDansCase(Case, PJ2, NbGrainesCase), NbGrainesCase > 0, NbGrainesRamassees is NbGrainesCase.
	
calculerCaseArrivee(Case1, Case2, CaseArrive):- Case1 > 0, nombreGrainesDansCase(Case1, PJ1, NbGrainesCase), CaseTmp is Case1 + NbGrainesCase, CaseTmp =< 6, CaseArrive is CaseTmp.
calculerCaseArrivee(Case1, Case2, CaseArrive):- Case1 > 0, nombreGrainesDansCase(Case1, PJ1, NbGrainesCase), CaseTmp is Case1 + NbGrainesCase, CaseTmp > 6, CaseArrive is 99.
calculerCaseArrivee(Case1, Case2, CaseArrive):- Case2 > 0, nombreGrainesDansCase(Case2, PJ2, NbGrainesCase), CaseTmp is Case2 + NbGrainesCase, CaseTmp =< 6, CaseArrive is CaseTmp.
calculerCaseArrivee(Case1, Case2, CaseArrive):- Case2 > 0, nombreGrainesDansCase(Case2, PJ2, NbGrainesCase), CaseTmp is Case2 + NbGrainesCase, CaseTmp > 6, CaseArrive is 99.

%Joueur = joueur courant (var dynamique)
%Ja = Plateau d'arrive
%P2AvtRamasse = Plateau J2 a la fin du tour, avant ramassage
%PJ2Fin = Plateau J2 apres ramassage
%CaseA = Case d'arrivee
calculNombreDeGrainesRamassees(J1, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator):- Ja =:= PJ1.
calculNombreDeGrainesRamassees(J1, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator):- 	Ja =:= PJ2,
																									Iterator => CaseA,
																									nombreGrainesCase(Iterator, P2AvtRamasse, Tmp),
																									Tmp =< 3, Tmp => 2,
																									GrainesRamassees is GrainesRamassees + Tmp,
																									copieTete(P2AvtRamasse, PJ2Fin), 
																									supprimeTete(P2AvtRamasse, P2AvtRamasse),
																									setElt(1, 0, PJ2Fin).
																									Iterator is Iterator - 1,
																									calculNombreDeGrainesRamassees(Joueur, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator).
calculNombreDeGrainesRamassees(J1, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator):- Ja =:= PJ2,
																									Iterator < CaseA,
																									copieTete(P2AvtRamasse, PJ2Fin), 
																									supprimeTete(P2AvtRamasse, P2AvtRamasse),
																									Iterator is Iterator - 1,
																									calculNombreDeGrainesRamassees(Joueur, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator).
calculNombreDeGrainesRamassees(J1, Ja, [], PJ2Fin, CaseA, GrainesRamassees, Iterator).

calculNombreDeGrainesRamassees(J2, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator):- Ja =:= PJ1.
calculNombreDeGrainesRamassees(J2, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator):- Ja =:= PJ1,
																									Iterator => CaseA,
																									nombreGrainesCase(Iterator, P2AvtRamasse, Tmp),
																									Tmp =< 3, Tmp => 2,
																									GrainesRamassees is GrainesRamassees + Tmp,
																									copieTete(P2AvtRamasse, PJ2Fin), 
																									supprimeTete(P2AvtRamasse, P2AvtRamasse),
																									setElt(1, 0, PJ2Fin).
																									Iterator is Iterator - 1,
																									calculNombreDeGrainesRamassees(Joueur, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator).
calculNombreDeGrainesRamassees(J2, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator):- Ja =:= PJ1,
																									Iterator < CaseA,
																									copieTete(P2AvtRamasse, PJ2Fin), 
																									supprimeTete(P2AvtRamasse, P2AvtRamasse),
																									Iterator is Iterator - 1,
																									calculNombreDeGrainesRamassees(Joueur, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator).
calculNombreDeGrainesRamassees(J2, Ja, [], PJ2Fin, CaseA, GrainesRamassees, Iterator).

imprime([]).
imprime([T|Q]):- write(T), nl, imprime(Q).
imprime(X):- plateau(X,A), imprime(A).

%Operations sur liste.
nombreGrainesDansCase(Case, PJ1, NbGraines):- iemeElt(Case, 1, PJ1, NbGraines).

iemeElt(_, _, [], _):- !.
iemeElt(Case, N, [T|Q], E):- N =:= Case, E is T, !.
iemeElt(Case, N, [T|Q], E):- N =\= Case, New_N is N+1, iemeElt(Case, New_N, Q, E).

setElt(Case, Valeur, [T|Q]):- iemeElt(Case, 1, [T|Q], E), E is Valeur.

copieTete([T|_], L):- L is [T|L].
supprimeTete([_|Q], newL):- newL is Q.