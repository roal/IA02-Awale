:-use_module(liste).
:-use_module(minimax).

:- dynamic(plateau1/1).
:- dynamic(plateau2/1).
:- dynamic(score1/1).
:- dynamic(score2/1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREDICAT DE MAJ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
majPlateaux(1, 0, P1, P2):- retract(plateau1(_)),
							retract(plateau2(_)),
							asserta(plateau1(P1)),
							asserta(plateau2(P2)).

majPlateaux(0, 1, P1, P2):- retract(plateau1(_)),
							retract(plateau2(_)),
							asserta(plateau1(P2)),
							asserta(plateau2(P1)).

majScores(1, 0, Add):- score1(Old), retract(score1(_)), NewScore is Old + Add, asserta(score1(NewScore)).
majScores(0, 1, Add):- score2(Old), retract(score2(_)), NewScore is Old + Add, asserta(score2(NewScore)).

majScoresSup(1, 0, Sup):- score1(Old), retract(score1(_)), NewScore is Old - Sup, asserta(score1(NewScore)).
majScoresSup(0, 1, Sup):- score2(Old), retract(score2(_)), NewScore is Old -Sup, asserta(score2(NewScore)).

getScore(1, 0, S1, S2):- score1(S1), score2(S2).
getScore(0, 1, S1, S2):- score1(S2), score2(S1).


getPlateaux(1, 0, P1, P2):- plateau1(P1), plateau2(P2).
getPlateaux(0, 1, P1, P2):- plateau1(P2), plateau2(P1).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UN TOUR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tourPlateau(J1, J2, Case):- Case < 7, Case > 0,
						getPlateaux(J1, J2, P1, P2),
						nombreGrainesDansCase(Case, P1, NbGrainesCase),
						NbGrainesCase > 0,
						CaseOrigin is - Case + 2,
						siPremiereDistribPossible(J1, J2, P1, P2, Case, CaseOrigin, NbGrainesCase).

tourPlateau(J1, J2, Case):- Case < 7, Case > 0,
						getPlateaux(J1, J2, P1, P2),
						nombreGrainesDansCase(Case, P1, NbGrainesCase),
						NbGrainesCase =:= 0,!.


%premiere distrib
siPremiereDistribPossible(_, _, P1, P2, _, P1, P2, 0, _):- !, fail.
siPremiereDistribPossible(J1, J2, P1, P2, Case, CaseOrigin, NbGrainesCase):- !, distribuerSurPlateau(0, Case, 99, NbGrainesCase, P1, [], NewP1, _, NbGrainesRestantes),
																			reverse(NewP1, RevertedP1),
																			majPlateaux(J1, J2, RevertedP1, P2),
																			write('1er distrib : P1 = '), write(RevertedP1), write(';   P2 = '), write(P2), nl,
																			siDeuxiemeDistribPossible(J2, J1, CaseOrigin, P2, RevertedP1, NbGrainesRestantes).

%distribution sur le plateau adverse
siDeuxiemeDistribPossible(_, _, _, _, _, 0):- !.
siDeuxiemeDistribPossible(J2, J1, CaseOrigin, P2, P1, NbGrainesRestantes):- distribPlateauJ2(J2, J1, P2, P1, NbGrainesRestantes, CaseArrivee, NewP2, NewNbGrainesRestantes),
																			reverse(NewP2, P2AvtRam),
																			majPlateaux(J1, J2, P1, P2AvtRam),
																			write('2eme distrib : P1 = '), write(P1), write(';   P2 = '), write(P2AvtRam), nl,
																			siTroisieme(J1, J2, P1, P2AvtRam, 1, CaseOrigin, CaseArrivee, NewNbGrainesRestantes).

distribPlateauJ2(_, _, P2, _, NbGraines, CaseArrivee, NewP2, NbGrainesReste):- distribuerSurPlateau(1, 1, 99, NbGraines, P2, [], NewP2, CaseArrivee, NbGrainesReste).

%Nouvelle distrib sur plateau du joueur courant
%si plus de graines a distrib, on regarde combien on peut en ramasser
siTroisieme(J1, J2, P1, P2AvtRam, _, _, CaseArrivee, 0):- !, CaseArriveeReelle is CaseArrivee + 5,
														reverse(P2AvtRam, P2Reverted),
														calculNombreDeGrainesRamassees(P2Reverted, [], P2Inter, CaseArriveeReelle, NbGraines),
														ramassageValide(P2Inter, P2AvtRam, P2Fin, NbGraines, GrainesRamasses), 
														majScores(J1, J2, GrainesRamasses),
														majPlateaux(J1, J2, P1, P2Fin).

%sinon on distribue une nouvelle fois sur le premier plateau
siTroisieme(J1, J2, P1, P2AvtRam, Case, CaseOrigin, CaseArrivee, NbGrainesRestantes):- distribuerSurPlateau(0, Case, CaseOrigin, NbGrainesRestantes, P1, [], NewP1, CaseArrive, NewNbGraines),
																						reverse(NewP1, RevertedP1),
																						majPlateaux(J1, J2, RevertedP1, P2AvtRam),
																						siDeuxiemeDistribPossible(J2, J1, CaseOrigin, P2AvtRam, RevertedP1, NewNbGraines).
																						
																						
/**************TEST***************************/
testplateau:- asserta(plateau1([2,1,0,0,4,4])),
			asserta(plateau2([1,0,0,15,3,4])),
			asserta(score1(0)),
			asserta(score2(0)),
			afficherEtat,
			tourJeu.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISTRIBUTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%param(Prise, Case, NbGrainesCase, PJ1, NewPJ1, CaseArrive, NbGrainesRestantes)
%Prise = 0 pour plateau du joueur, 1 pour plateau adverse
%Case = Case en cours de traitement

%cas ou nombre graines restantes = 0
distribuerSurPlateau(_, Case, _, 0, [], Inter, Inter, CaseArrive, NbGrainesRestantes):- CaseArrive is Case + 1, NbGrainesRestantes is 0, !.
distribuerSurPlateau(_, Case, _, 0, Reste, Inter, PlateauFin, CaseArrive, NbGrainesRestantes):- CaseArrive is Case + 1, NbGrainesRestantes is 0, vider(Reste, Inter, PlateauFin), !.

%cas ou on arrive a la fin du plateau
distribuerSurPlateau(_, _, _, NbGrainesCase, [], Inter, Inter, CaseArrive, NbGrainesRestantes):- CaseArrive is 99,
																							NbGrainesRestantes is NbGrainesCase, !.
%Case > 1 -> copie la tete de PJ1 dans NewPJ1
distribuerSurPlateau(_, Case, CaseOrigin, NbGrainesCase, [T|Q], Inter, NewP1, CaseArrive, NbGrainesRestantes):- Case > 1, !,
																							NewCase is Case - 1,
																							distribuerSurPlateau(0, NewCase, CaseOrigin, NbGrainesCase, Q, [T|Inter], NewP1, CaseArrive, NbGrainesRestantes).

%Case ==1 -> Vide la case sur plateau Jcourant | ajoute une graine ds la case sur plateau adverse
distribuerSurPlateau(Prise, 1, CaseOrigin, NbGrainesCase, [T|Q], Inter, NewP1, CaseArrive, NbGrainesRestantes):- !, prise(Prise, 1, CaseOrigin, T, FinalT, NbGrainesCase, FinalNbGraines),
																							distribuerSurPlateau(Prise, 0, CaseOrigin, FinalNbGraines, Q, [FinalT|Inter], NewP1, CaseArrive, NbGrainesRestantes).
																							
%case < 1 -> Ajoute une graine et nbGraines-1 sur plateau Jcourant | Laisse en place la case sur plateau adverse
distribuerSurPlateau(Prise, Case, CaseOrigin, NbGrainesCase, [T|Q], Inter, NewP1, CaseArrive, NbGrainesRestantes):- prise(Prise, Case, CaseOrigin, T, FinalT, NbGrainesCase, FinalNbGraines),
																							CaseTmp is Case - 1,
																							distribuerSurPlateau(Prise, CaseTmp, CaseOrigin, FinalNbGraines, Q, [FinalT|Inter], NewP1, CaseArrive, NbGrainesRestantes).


%param (Prise, T, FinalT, NbGraines, FinalNbGraines)
%Prise = 0 pour plateau du joueur, 1 pour plateau adverse
prise(0, 1, 99, _, FinalT, NbGraines, FinalNbGraines):- FinalT is 0, FinalNbGraines is NbGraines.

%Si case = caseOrigin, alors on fait 2eme tour sur plateau 1 et on ne doit pas mettre de graine ds cette case
prise(0, Case, Case, _, 0, NbGraines, NbGraines):- !.

prise(0, 1, CaseOrigin, T, FinalT, NbGraines, FinalNbGraines):- CaseOrigin > -5, CaseOrigin < 2, FinalT is T + 1, FinalNbGraines is NbGraines - 1, !.
prise(0, Case, _, T, FinalT, NbGraines, FinalNbGraines):- Case < 1, FinalT is T + 1, FinalNbGraines is NbGraines - 1.

%si on distribue sur le plateau adverse et quon appel prise, on ajoutera toujours une graine
prise(1, _, _, T, FinalT, NbGraines, FinalNbGraines):- FinalT is T + 1, FinalNbGraines is NbGraines - 1.

%calculerCaseArrivee(Case1, _, CaseArrive):- Case1 > 0, nombreGrainesDansCase(Case1, PJ1, NbGrainesCase), CaseTmp is Case1 + NbGrainesCase, CaseTmp =< 6, CaseArrive is CaseTmp.
%calculerCaseArrivee(Case1, _, CaseArrive):- Case1 > 0, nombreGrainesDansCase(Case1, PJ1, NbGrainesCase), CaseTmp is Case1 + NbGrainesCase, CaseTmp > 6, CaseArrive is 99.
%calculerCaseArrivee(_, Case2, CaseArrive):- Case2 > 0, nombreGrainesDansCase(Case2, PJ2, NbGrainesCase), CaseTmp is Case2 + NbGrainesCase, CaseTmp =< 6, CaseArrive is CaseTmp.
%calculerCaseArrivee(_, Case2, CaseArrive):- Case2 > 0, nombreGrainesDansCase(Case2, PJ2, NbGrainesCase), CaseTmp is Case2 + NbGrainesCase, CaseTmp > 6, CaseArrive is 99.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RAMASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%param(P2AvtRamasse, PJ2Fin, CaseA, GrainesRamassees, Iterator)

%P2AvtRamasse = Plateau J2 a la fin du tour, avant ramassage
%PJ2Fin = Plateau J2 apres ramassage
%CaseA = Case d'arrivee
calculNombreDeGrainesRamassees([], Inter, Inter, _, 0).
calculNombreDeGrainesRamassees([T|Q], Inter, PJ2Fin, CaseA, TotalGrainesRamassees):- CaseA =< 1, ramasse(T, NewT, NbGraines), !,
																			NewCase is CaseA - 1,
																			calculNombreDeGrainesRamassees(Q, [NewT|Inter], PJ2Fin, NewCase, GrainesRamassees),
																			TotalGrainesRamassees is GrainesRamassees + NbGraines.
%Si un ramassage n'est pas possible, on stop
calculNombreDeGrainesRamassees([T|Q], Inter, PJ2Fin, CaseA, 0):- CaseA =< 1, !, \+ramasse(T, NewT, NbGraines), 
																vider([T|Q],Inter, PJ2Fin).

calculNombreDeGrainesRamassees([T|Q], Inter, PJ2Fin, CaseA, GrainesRamassees):- CaseA > 1,
																			NewCase is CaseA - 1,
																			calculNombreDeGrainesRamassees(Q, [T|Inter], PJ2Fin, NewCase, GrainesRamassees).


ramasse(T, 0, T):- T >= 2, T =< 3, !.
ramasse(_, _, 0):- fail.

%si le plateau du joueur adverse ne contient plus de graine apres le ramassage, 
%on le remet dans l'etat avant le ramassage et le joueur ne ramasse rien
ramassageValide([0,0,0,0,0,0], P2AvtRam, P2AvtRam, _, 0):-!.

%Sinon le plateau final est celui apres ramassage et le joueur ramassage le nb de graines calcule
ramassageValide(P2Inter, _, P2Inter, NbGraines, NbGraines).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GESTION JEU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialisation
init:- asserta(plateau1([4,4,4,4,4,4])),
		asserta(plateau2([4,4,4,4,4,4])),
		asserta(score1(0)),
		asserta(score2(0)).

commencerJeu:- init, afficherEtat, tourJeu.

tourJeu:-joueurJoue,
		\+partieFinie,
		iaJoue,
		\+partieFinie,
		tourJeu.

partieFinie:- score1(S1), S1 >= 25, !.
partieFinie:- score2(S2), S2 >= 25.


joueurJoue:- write('Au joueur 1 de jouer. Entrez le numéro de la case à jouer : '), 
			read(ChoixCase),
			tourPlateau(1, 0, ChoixCase),
			afficherEtat.

iaJoue:- write('Au joueur 2 de jouer. Entrez le numéro de la case à jouer : '), 
		read(ChoixCase),
		tourPlateau(0, 1, ChoixCase),
		afficherEtat.

afficherEtat:- plateau1(PJ1), plateau2(PJ2), score1(S1), score2(S2),
				write('Etat du jeu : '), nl,
				reverse(PJ2, RevertedPJ2),
				write('J2 : '), write(RevertedPJ2), write(' score : '), write(S2), nl,
				write('J1 : '), write(PJ1), write(' score : '), write(S1), nl.



