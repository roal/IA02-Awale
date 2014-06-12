:-use_module(liste).
:-use_module(minimax).

:- dynamic(plateau1/1).
:- dynamic(plateau2/1).
:- dynamic(score1/1).
:- dynamic(score2/1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREDICAT DE MAJ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
majPlateaux(P1, P2):- retract(plateau1(_)),
					retract(plateau2(_)),
					asserta(plateau1(P1)),
					asserta(plateau2(P2)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UN TOUR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tourPlateau(J1, J2, PJ1, PJ2, Case, PJ1Fin, PJ2Fin, GrainesRamassees):- Case < 7, Case > 0,
																		nombreGrainesDansCase(Case, PJ1, NbGrainesCase),
																		NbGrainesCase > 0,
																		CaseOrigin is - Case + 2,
																		siPremiereDistribPossible(J1, J2, PJ1, PJ2, Case, CaseOrigin, PJ1Fin, PJ2Fin, NbGrainesCase, GrainesRamassees).

%premiere distrib
siPremiereDistribPossible(_, _, PJ1, PJ2, _, PJ1, PJ2, 0, _):- !, fail.
siPremiereDistribPossible(J1, J2, PJ1, PJ2, Case, CaseOrigin, PJ1Fin, PJ2Fin, NbGrainesCase, NbGrainesRamassees):- NbGrainesCase > 0, !,
																						distribuerSurPlateau(0, Case, 99, NbGrainesCase, PJ1, [], NewPJ1, CaseArrive, NbGrainesRestantes),
																						reverse(NewPJ1, RevertedPJ1),
																						majPlateaux(RevertedPJ1, PJ2),
																						write('1er distrib : PJ1 = '), write(RevertedPJ1), write(';   PJ2 = '), write(PJ2), nl,
																						siDeuxiemeDistribPossible(J2, J1, CaseOrigin, PJ2, RevertedPJ1, PJ2Fin, PJ1Fin, NbGrainesRestantes, NbGrainesRamassees).

%distribution sur le plateau adverse
siDeuxiemeDistribPossible(J2, J1, CaseOrigin, PJ2, PJ1, PJ2Fin, PJ1Fin, NbGrainesRestantes, NbGrainesRamassees):- NbGrainesRestantes \== 0, !,
																										distribPlateauJ2(J2, J1, PJ2, PJ1, NbGrainesRestantes, CaseArrivee, NewPJ2, NewNbGrainesRestantes),
																										reverse(NewPJ2, PJ2AvtRam),
																										majPlateaux(PJ1, PJ2AvtRam),
																										write('2eme distrib : PJ1 = '), write(PJ1), write(';   PJ2 = '), write(PJ2AvtRam), nl,
																										trace, siTroisieme(J1, J2, PJ1, PJ2AvtRam, 1, CaseOrigin, CaseArrivee, PJ1Fin, PJ2Fin, NewNbGrainesRestantes, NbGraines),
																										write('3eme distrib : PJ1 = '), write(PJ1Fin), write(';   PJ2 = '), write(PJ2Fin), write(';   Score = '), write(NbGraines), nl.
siDeuxiemeDistribPossible(J2, J1, CaseOrigin, PJ2, NewPJ1, PJ2Fin, PJ1Fin, 0, 0).

distribPlateauJ2(J2, J1, PJ2, PJ1, NbGraines, CaseArrivee, NewP2, NbGrainesReste):- distribuerSurPlateau(1, 1, 99, NbGraines, PJ2, [], NewP2, CaseArrivee, NbGrainesReste).

%si plus de graines a distrib, on regarde combien on peut en ramasser
siTroisieme(J1, J2, PJ1, PJ2AvtRam, Case, CaseOrigin, CaseArrivee, PJ1Fin, PJ2Fin, 0, GrainesRamasses):- !, CaseArriveeReelle is - CaseArrivee + 2,
																						calculNombreDeGrainesRamassees(J1, Ja, PJ2AvtRam, [], PJ2Inter, CaseArriveeReelle, NbGraines),
																						ramassageValide(PJ2Inter, PJ2AvtRam, PJ2Fin, NbGraines, GrainesRamasses).

%sinon on distribue une nouvelle fois sur le premier plateau
siTroisieme(J1, J2, PJ1, PJ2AvtRam, Case, CaseOrigin, CaseArrivee, PJ1Fin, PJ2Fin, NbGrainesRestantes, 0):-
																						distribuerSurPlateau(0, Case, CaseOrigin, NbGrainesRestantes, PJ1, [], NewPJ1, CaseArrive, 0),
																						reverse(NewPJ1, RevertedPJ1),
																						majPlateaux(RevertedPJ1, PJ2).
																						
																						
/*TEST*/
testplateau:- afficherPlateaux([4,4,4,4,4,4], [4,5,1,2,4,1]),
			asserta(plateau1([4,4,4,4,4,4])),
			asserta(plateau2([4,5,1,2,4,1])),
			tourPlateau(J1, J2, [4,4,4,4,4,4], [4,5,1,2,4,1], 6, PJ1Fin, PJ2Fin, GrainesRamassees).
			%write('graines ramassees '), write(GrainesRamassees), nl,
			%plateau1(P1), plateau2(P2),
			%afficherPlateaux(P1, P2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISTRIBUTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%param(Prise, Case, NbGrainesCase, PJ1, NewPJ1, CaseArrive, NbGrainesRestantes)
%Prise = 0 pour plateau du joueur, 1 pour plateau adverse
%Case = Case en cours de traitement

%cas ou nombre graines restantes = 0
distribuerSurPlateau(_, Case, _, 0, [], Inter, Inter, CaseArrive, NbGrainesRestantes):- CaseArrive is Case + 1, NbGrainesRestantes is 0, !.
distribuerSurPlateau(_, Case, _, 0, Reste, Inter, PlateauFin, CaseArrive, NbGrainesRestantes):- CaseArrive is Case + 1, NbGrainesRestantes is 0, concat(Reste, Inter, PlateauFin), !.

%cas ou on arrive a la fin du plateau
distribuerSurPlateau(_, _, CaseOrigin, NbGrainesCase, [], Inter, Inter, CaseArrive, NbGrainesRestantes):- CaseArrive is 99,
																							NbGrainesRestantes is NbGrainesCase, !.
%Case > 1 -> copie la tete de PJ1 dans NewPJ1
distribuerSurPlateau(_, Case, CaseOrigin, NbGrainesCase, [T|Q], Inter, NewPJ1, CaseArrive, NbGrainesRestantes):- Case > 1, !,
																							NewCase is Case - 1,
																							distribuerSurPlateau(0, NewCase, CaseOrigin, NbGrainesCase, Q, [T|Inter], NewPJ1, CaseArrive, NbGrainesRestantes).

%Case ==1 -> Vide la case sur plateau Jcourant | ajoute une graine ds la case sur plateau adverse
distribuerSurPlateau(Prise, 1, CaseOrigin, NbGrainesCase, [T|Q], Inter, NewPJ1, CaseArrive, NbGrainesRestantes):- !, prise(Prise, 1, CaseOrigin, T, FinalT, NbGrainesCase, FinalNbGraines),
																							distribuerSurPlateau(Prise, 0, CaseOrigin, FinalNbGraines, Q, [FinalT|Inter], NewPJ1, CaseArrive, NbGrainesRestantes).
																							
%case < 1 -> Ajoute une graine et nbGraines-1 sur plateau Jcourant | Laisse en place la case sur plateau adverse
distribuerSurPlateau(Prise, Case, CaseOrigin, NbGrainesCase, [T|Q], Inter, NewPJ1, CaseArrive, NbGrainesRestantes):- prise(Prise, Case, CaseOrigin, T, FinalT, NbGrainesCase, FinalNbGraines),
																							CaseTmp is Case - 1,
																							distribuerSurPlateau(Prise, CaseTmp, CaseOrigin, FinalNbGraines, Q, [FinalT|Inter], NewPJ1, CaseArrive, NbGrainesRestantes).


%param (Prise, T, FinalT, NbGraines, FinalNbGraines)
%Prise = 0 pour plateau du joueur, 1 pour plateau adverse
prise(0, 1, 99, _, FinalT, NbGraines, FinalNbGraines):- FinalT is 0, FinalNbGraines is NbGraines.

%Si case = caseOrigin, alors on fait 2eme tour sur plateau 1 et on ne doit pas mettre de graine ds cette case
prise(0, Case, Case, T, FinalT, NbGraines, FinalNbGraines):- FinalT is 0, FinalNbGraines is NbGraines, !.

prise(0, 1, CaseOrigin, T, FinalT, NbGraines, FinalNbGraines):- CaseOrigin > -5, CaseOrigin < 2, FinalT is T + 1, FinalNbGraines is NbGraines - 1, !.
prise(0, Case, _, T, FinalT, NbGraines, FinalNbGraines):- Case < 1, FinalT is T + 1, FinalNbGraines is NbGraines - 1.

%si on distribue sur le plateau adverse et quon appel prise, on ajoutera toujours une graine
prise(1, Case, _, T, FinalT, NbGraines, FinalNbGraines):- FinalT is T + 1, FinalNbGraines is NbGraines - 1.

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


calculNombreDeGrainesRamassees(J1, Pa, [], Inter, Inter, CaseA, 0).
calculNombreDeGrainesRamassees(J1, Pa, [T|Q], Inter, PJ2Fin, CaseA, TotalGrainesRamassees):- CaseA >= 1, ramasse(T, NewT, NbGraines), !,
																			NewCase is CaseA - 1,
																			calculNombreDeGrainesRamassees(J1, Pa, Q, [NewT|Inter], PJ2Fin, NewCase, GrainesRamassees),
																			TotalGrainesRamassees is GrainesRamassees + NbGraines.
%Si un ramassage n'est pas possible, on stop
calculNombreDeGrainesRamassees(J1, Pa, [T|Q], Inter, PJ2Fin, CaseA, 0):- CaseA >= 1, !, \+ramasse(T, NewT, NbGraines), 
																			concat([T|Q],Inter, PJ2Fin).

calculNombreDeGrainesRamassees(J1, Pa, [T|Q], Inter, PJ2Fin, CaseA, GrainesRamassees):- CaseA < 1,
																			NewCase is CaseA - 1,
																			calculNombreDeGrainesRamassees(J1, Pa, Q, [T|Inter], PJ2Fin, NewCase, GrainesRamassees).


ramasse(T, 0, T):- T >= 2, T =< 3, !.
ramasse(T, NewT, 0):- fail.

%si le plateau du joueur adverse ne contient plus de graine apres le ramassage, 
%on le remet dans l'etat avant le ramassage et le joueur ne ramasse rien
ramassageValide([0,0,0,0,0,0], PJ2AvtRam, PJ2AvtRam, NbGraines, 0):-!.

%Sinon le plateau final est celui apres ramassage et le joueur ramassage le nb de graines calcule
ramassageValide(PJ2Inter, PJ2AvtRam, PJ2Inter, NbGraines, NbGraines).

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
afficherPlateaux(P1, P2):- write('affiche plateau'), nl,
							reverse(P2, RevertedP2),
							write(RevertedP2), nl,
							write(P1), nl.
afficherScore(S1,S2):- write('Le score Joueur 1 : '), write(S1), write('; J2 : '), write(S2), nl.









