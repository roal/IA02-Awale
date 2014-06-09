:- dynamic( plateau1/1 ).
:- dynamic( plateau2/1 ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREDICAT DE MAJ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
majPlateaux(P1, P2):- retract(plateau1(_)),
					retract(plateau2(_)),
					asserta(plateau1(P1)),
					asserta(plateau2(P2)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UN TOUR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tourPlateau(J1, J2, PJ1, PJ2, Case, PJ1Fin, PJ2Fin, GrainesRamassees):- Case < 7, Case > 0,
																		nombreGrainesDansCase(Case, PJ1, NbGrainesCase),
																		NbGrainesCase > 0,
																		write('appel siPremiereDistribPossible'), nl,
																		siPremiereDistribPossible(J1, J2, PJ1, PJ2, Case, PJ1Fin, PJ2Fin, NbGrainesCase, GrainesRamassees).

%premiere distrib
siPremiereDistribPossible(J1, J2, PJ1, PJ2, Case, PJ1, PJ2, 0, NbGrainesRamassees):- !, fail.
siPremiereDistribPossible(J1, J2, PJ1, PJ2, Case, PJ1Fin, PJ2Fin, NbGrainesCase, NbGrainesRamassees):- write('entre siPremiereDistribPossible'), nl, NbGrainesCase > 0, !,
																						distribuerSurPlateau(0, Case, NbGrainesCase, PJ1, [], NewPJ1, CaseArrive, NbGrainesRestantes),
																						reverse(NewPJ1, RevertedPJ1),
																						majPlateaux(RevertedPJ1, PJ2),
																						siDeuxiemeDistribPossible(J2, J1, PJ2, RevertedPJ1, PJ2Fin, PJ1Fin, NbGrainesRestantes, NbGrainesRamassees).

%distribution sur le plateau adverse
siDeuxiemeDistribPossible(J2, J1, PJ2, PJ1, PJ2Fin, PJ1Fin, NbGrainesRestantes, NbGrainesRamassees):- NbGrainesRestantes \== 0, !,
																										P2AvtRamasse is NbGrainesRestantes,
																										distribPlateauJ2(J2, J1, PJ2, PJ1, NbGrainesRestantes, CaseArrivee, NewPJ2, NewNbGraines),
																										reverse(NewPJ2, RevertedPJ2),
																										majPlateaux(PJ1, RevertedPJ2),
																										write(NewNbGraines),
																										\+siPremiereDistribPossible(J1, J2, PJ1, RevertedPJ2, 1, PJ1Fin, PJ2Fin, NewNbGraines, NbGrainesRamassees).
																										%calculNombreDeGrainesRamassees(J1,Ja,P2AvtRamasse,PJ2Fin,CaseArrivee,NbGrainesRamassees).
siDeuxiemeDistribPossible(J2, J1, PJ2, NewPJ1, PJ2Fin, PJ1Fin, 0, 0).

distribPlateauJ2(J2, J1, PJ2, PJ1, NbGraines, CaseArrivee, NewP2, NbGrainesReste):- distribuerSurPlateau(1, 1, NbGraines, PJ2, [], NewP2, CaseArrivee, NbGrainesReste).
																			

/*TEST*/
testplateau:- afficherPlateaux([4,4,4,4,4,4], [4,4,4,4,4,4]),
					asserta(plateau1([4,4,4,4,4,4])),
					asserta(plateau2([4,4,4,4,4,4])),
			tourPlateau(J1, J2, [4,4,4,4,4,4], [4,4,4,4,4,4], 3, PJ1Fin, PJ2Fin, GrainesRamassees),
			write('graines ramassees '), write(GrainesRamassees), nl,
			plateau1(P1), plateau2(P2),
			afficherPlateaux(P1, P2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISTRIBUTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%param(Prise, Case, NbGrainesCase, PJ1, NewPJ1, CaseArrive, NbGrainesRestantes)
%Prise = 0 pour plateau du joueur, 1 pour plateau adverse
%Case = Case en cours de traitement

%cas ou nombre graines restantes = 0
distribuerSurPlateau(_, Case, 0, [], Inter, Inter, CaseArrive, NbGrainesRestantes):- CaseArrive is Case, NbGrainesRestantes is 0, !, write('nb graines restante = 0').
distribuerSurPlateau(_, Case, 0, Reste, Inter, PlateauFin, CaseArrive, NbGrainesRestantes):- CaseArrive is Case, NbGrainesRestantes is 0, concat(Reste, Inter, PlateauFin), !, write('nb graines restante = 0').

%cas ou on arrive a la fin du plateau
distribuerSurPlateau(_, _, NbGrainesCase, [], Inter, Inter, CaseArrive, NbGrainesRestantes):- CaseArrive is 99,
																							NbGrainesRestantes is NbGrainesCase, !.
%Case > 1 -> copie la tete de PJ1 dans NewPJ1
distribuerSurPlateau(_, Case, NbGrainesCase, [T|Q], Inter, NewPJ1, CaseArrive, NbGrainesRestantes):- Case > 1, !,
																							NewCase is Case - 1,
																							distribuerSurPlateau(0, NewCase, NbGrainesCase, Q, [T|Inter], NewPJ1, CaseArrive, NbGrainesRestantes).

%Case ==1 -> Vide la case sur plateau Jcourant | ajoute une graine ds la case sur plateau adverse
distribuerSurPlateau(Prise, 1, NbGrainesCase, [T|Q], Inter, NewPJ1, CaseArrive, NbGrainesRestantes):- !, prise(Prise, 1, T, FinalT, NbGrainesCase, FinalNbGraines),
																							distribuerSurPlateau(0, 0, FinalNbGraines, Q, [FinalT|Inter], NewPJ1, CaseArrive, NbGrainesRestantes).
																							
%case < 1 -> Ajoute une graine et nbGraines-1 sur plateau Jcourant | Laisse en place la case sur plateau adverse
distribuerSurPlateau(Prise, Case, NbGrainesCase, [T|Q], Inter, NewPJ1, CaseArrive, NbGrainesRestantes):- prise(Prise, Case, T, FinalT, NbGrainesCase, FinalNbGraines),
																							CaseTmp is Case - 1,
																							distribuerSurPlateau(0, CaseTmp, FinalNbGraines, Q, [FinalT|Inter], NewPJ1, CaseArrive, NbGrainesRestantes).


%param (Prise, T, FinalT, NbGraines, FinalNbGraines)
prise(0, 1, _, FinalT, NbGraines, FinalNbGraines):- FinalT is 0, FinalNbGraines is NbGraines.
prise(1, 1, T, FinalT, NbGraines, FinalNbGraines):- FinalT is T + 1, FinalNbGraines is NbGraines - 1.

prise(0, Case, T, FinalT, NbGraines, FinalNbGraines):- Case < 1, FinalT is T + 1, FinalNbGraines is NbGraines - 1.
prise(1, Case, T, FinalT, NbGraines, FinalNbGraines):- Case < 1, FinalT is T, FinalNbGraines is NbGraines.

%calculerCaseArrivee(Case1, _, CaseArrive):- Case1 > 0, nombreGrainesDansCase(Case1, PJ1, NbGrainesCase), CaseTmp is Case1 + NbGrainesCase, CaseTmp =< 6, CaseArrive is CaseTmp.
%calculerCaseArrivee(Case1, _, CaseArrive):- Case1 > 0, nombreGrainesDansCase(Case1, PJ1, NbGrainesCase), CaseTmp is Case1 + NbGrainesCase, CaseTmp > 6, CaseArrive is 99.
%calculerCaseArrivee(_, Case2, CaseArrive):- Case2 > 0, nombreGrainesDansCase(Case2, PJ2, NbGrainesCase), CaseTmp is Case2 + NbGrainesCase, CaseTmp =< 6, CaseArrive is CaseTmp.
%calculerCaseArrivee(_, Case2, CaseArrive):- Case2 > 0, nombreGrainesDansCase(Case2, PJ2, NbGrainesCase), CaseTmp is Case2 + NbGrainesCase, CaseTmp > 6, CaseArrive is 99.








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RAMASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%param(J1, Ja, P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator)

%Joueur = joueur courant(var dynamique)
%Pa = Plateau d'arrive
%P2AvtRamasse = Plateau J2 a la fin du tour, avant ramassage
%PJ2Fin = Plateau J2 apres ramassage
%CaseA = Case d'arrivee

%si le plateau d'arrivee est celui du joueur, aucun ramassage
calculNombreDeGrainesRamassees(J1, Pa, P2AvtRamasse, PJ2Fin, _, GrainesRamassees):- J1 =:= Pa, !, PJ2Fin =:= P2AvtRamasse, GrainesRamassees is 0.
calculNombreDeGrainesRamassees(J1, _, [T|Q], PJ2Fin, CaseA, GrainesRamassees):- CaseA < 1, !, ramasse(T, NewT, GrainesRamassees), 
																			append(NewT, PJ2Fin, PJ2Fin),
																			NewCase is CaseA - 1,
																			calculNombreDeGrainesRamassees(J1, Q, PJ2Fin, NewCase, GrainesRamassees).

calculNombreDeGrainesRamassees(J1, _, [T|Q], PJ2Fin, 1, GrainesRamassees):- !, ramasse(T, NewT, GrainesRamassees), 
																			append(NewT, PJ2Fin, PJ2Fin),
																			calculNombreDeGrainesRamassees(J1, Q, PJ2Fin, 0, GrainesRamassees).

calculNombreDeGrainesRamassees(J1, _, [T|Q], PJ2Fin, CaseA, GrainesRamassees):- CaseA > 1, !, append(T, PJ2Fin, PJ2Fin),
																			NewCase is CaseA - 1,
																			calculNombreDeGrainesRamassees(J1, Q, PJ2Fin, NewCase, GrainesRamassees).
																			
ramasse(T, NewT, GrainesRamassees):- T >= 2, T =< 3, !, GrainesRamassees is GrainesRamassees + T, NewT is 0.
ramasse(T, NewT, _):- NewT is T.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GESTION JEU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%update%
%miseAjourPlateau(Joueur, Plateau):- retract(jeu(Joueur,_)), assert(jeu(Joueur,Plateau)).
%miseAjourScore(Joueur, Score):- retract(score(Joueur,_)), assert(score(Joueur,Score)).

%initialisation
commencerJeu:- afficherPlateaux([4,4,4,4,4,4], [4,4,4,4,4,4]),
				tourJeu([4,4,4,4,4,4], [4,4,4,4,4,4], 0, 0).


tourJeu(PJ1, PJ2, SJ1, SJ2):- joueurJoue(PJ1, PJ2, SJ1, SJ2, PJ1Inter, PJ2Inter, NewSJ1),
							\+partieFinie(NewSJ1, SJ2),
							iaJoue(PJ1Inter, PJ2Inter, NewSJ1, NewSJ2, PJ1Final, PJ2Final, NewSJ2),
							\+partieFinie(NewSJ1, NewSJ2),
							tourJeu(PJ1Final, PJ2Final, NewSJ1, NewSJ2).

partieFinie(S1, _):- S1 >= 25.
partieFinie(_, S2):- S2 >= 25.


joueurJoue([0,0,0,0,0,0], _, SJ1, SJ2, _, _, _):- !, write('Joueur 1 ne peut pas jouer. La partie est terminée.'),
												nl,
												afficherScore(SJ1, SJ2).
joueurJoue(PJ1, PJ2, SJ1, _, PJ1Fin, PJ2Fin, NewSJ1):- write('Au joueur 1 de jouer. Entrez le numéro de la case à jouer : '), 
														read(ChoixCase),
														tourPlateau('Joueur 1', 'Joueur 2', PJ1, PJ2, ChoixCase, PJ1Fin, PJ2Fin, GrainesRamassees),
														NewSJ1 is SJ1 + GrainesRamassees,
														afficherPlateaux(PJ1Fin, PJ2Fin).

iaJoue(_, [0,0,0,0,0,0], SJ1, SJ2, _, _, _):- !, write('Joueur 2 ne peut pas jouer. La partie est terminée.'),
											nl,
											afficherScore(SJ1, SJ2).
iaJoue(PJ1, PJ2, _, SJ2, PJ1Fin, PJ2Fin, NewSJ2):-	write('Au joueur 2 de jouer'), nl,
														read(ChoixCase),
														tourPlateau('Joueur 2', 'Joueur 1', PJ2, PJ1, ChoixCase, PJ2Fin, PJ1Fin, GrainesRamassees),
														NewSJ2 is SJ2 + GrainesRamassees,
														afficherPlateaux(PJ1Fin, PJ2Fin).
afficherPlateaux(P1, P2):- write('affiche plateau'),
							reverse(P2, RevertedP2),
							write(RevertedP2), nl,
							write(P1), nl.
afficherScore(S1,S2):- write('Le score Joueur 1 : '), write(S1), write('; J2 : '), write(S2), nl.









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OPERATIONS SUR LISTE %%%%%%%%%%%%%%%%%%%%%


imprime([]).
imprime([T|Q]):- write(T), nl, imprime(Q).
imprime(X):- plateau(X,A), imprime(A).


nombreGrainesDansCase(Case, PJ1, NbGraines):- iemeElt(Case, 1, PJ1, NbGraines).

iemeElt(_, _, [], _):- !.
iemeElt(Case, N, [T|_], E):- N =:= Case, E is T, !.
iemeElt(Case, N, [_|Q], E):- N =\= Case, New_N is N+1, iemeElt(Case, New_N, Q, E).

setElt(Case, Valeur, [T|Q]):- iemeElt(Case, 1, [T|Q], E), E is Valeur.

concat([], L, L).
concat([T|Q], L, [T|R]):- concat(Q,L,R).

copieTete([T|_], L):- L is [T|L].
supprimeTete([_|Q], newL):- newL is Q.