


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UN TOUR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tourPlateau(J1, J2, PJ1, PJ2, Case, PJ1Fin, PJ2Fin, GrainesRamassees):- Case < 7, Case > 0,
																		write("appel \n"),
																		nombreGrainesDansCase(Case, PJ1, NbGrainesCase),
																		NbGrainesCase > 0,
																		write("appel siPremiereDistribPossible\n"),
																		siPremiereDistribPossible(J1, J2, PJ1, PJ2, Case, NbGrainesCase, NbGrainesRamassees).

%premiere distrib
siPremiereDistribPossible(J1, J2, PJ1, PJ2, Case, NbGrainesCase, NbGrainesRamassees):- write("entre siPremiereDistribPossible\n"), NbGrainesCase \== 0, !,
																						distribuerSurPlateau(0, Case, NbGrainesCase, PJ1, NewPJ1, CaseArrive, NbGrainesRestantes),
																						siDeuxiemeDistribPossible(J2, J1, PJ2, NewPJ1, PJ2Fin, PJ1Fin, NbGrainesRestantes, NbGrainesRamassees).
siPremiereDistribPossible(J1, J2, PJ1, PJ2, Case, 0, 0):- !.

%distribution sur le plateau adverse
siDeuxiemeDistribPossible(J2, J1, PJ2, NewPJ1, PJ2Fin, PJ1Fin, NbGrainesRestantes, NbGrainesRamassees):- NbGrainesRestantes \== 0, !,
																										distribPlateauJ2(J2,J1,PJ2,NewPJ1,NbGrainesRestantes,CaseArrivee,P2AvtRamasse,PJ2Fin),
																										\+siPremiereDistribPossible(J1, J2, NewPJ1, PJ2, PJ1Fin, PJ2Fin, 1, NbGrainesRestantes, NbGrainesRamassees),
																										calculNombreDeGrainesRamassees(J1,Ja,P2AvtRamasse,PJ2Fin,CaseArrivee,NbGrainesRamassees).
siDeuxiemeDistribPossible(J2, J1, PJ2, NewPJ1, PJ2Fin, PJ1Fin, 0, 0).

distribPlateauJ2(J2,J1,PJ2,PJ1,NbGraines,CaseArrivee,NewP2):- distribuerSurPlateau(1,1,NbGraines,PJ2,NewP2,CaseArrivee,NbGrainesReste).
																			

/*TEST*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISTRIBUTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%param(Prise, Case, NbGrainesCase, [T|Q]PJ1, NewPJ1, CaseArrive, NbGrainesRestantes)
%Prise = 0 pour plateau du joueur, 1 pour plateau adverse
%Case = Case en cours de traitement
%Case > 1 -> copie la tete de PJ1 dans NewPJ1
distribuerSurPlateau(_, Case, NbGrainesCase, [T|Q], NewPJ1, CaseArrive, NbGrainesRestantes):- Case > 1, append(T, NewPJ1, NewPJ1), 
																							NewCase is Case - 1,
																							distribuerSurPlateau(0, NewCase, NbGrainesCase, Q, NewPJ1, CaseArrive, NbGrainesRestantes).

%Case ==1 -> Vide la case
distribuerSurPlateau(Prise, 1, NbGrainesCase, [T|Q], NewPJ1, CaseArrive, NbGrainesRestantes):- prise(Prise, T, FinalT, NbGrainesCase, FinalNbGraines),
																							append(T, NewPJ1, NewPJ1),
																							NewCase is Case - 1,
																							distribuerSurPlateau(0, NewCase, FinalNbGraines, Q, NewPJ1, CaseArrive, NbGrainesRestantes).
																							
%case < 1 -> Ajoute une graine et nbGraines-1
distribuerSurPlateau(_, Case, NbGrainesCase, [T|Q], NewPJ1, CaseArrive, NbGrainesRestantes):- Case < 1, Tmp is T + 1,
																							append(Tmp, NewPJ1, NewPJ1),
																							NbGrainesCase is NbGrainesCase - 1,
																							NewCase is Case - 1,
																							distribuerSurPlateau(0, NewCase, NbGrainesCase, Q, NewPJ1, CaseArrive, NbGrainesRestantes).
																							
%cas ou nombre graines restantes = 0
distribuerSurPlateau(_, Case, 0, _, _, CaseArrive, NbGrainesRestantes):- CaseArrive is Case, NbGrainesRestantes is 0.

%cas ou on arrive a la fin du plateau
distribuerSurPlateau(_, Case, NbGrainesCase, [], NewPJ1, CaseArrive, NbGrainesRestantes):- CaseArrive is 99, NbGrainesRestantes is NbGrainesCase, !.

%param (Prise, T, FinalT, NbGraines, FinalNbGraines)
prise(0, _, FinalT, NbGraines, FinalNbGraines):- FinalT is 0, FinalNbGraines is NbGraines.
prise(1, T, FinalT, NbGraines, FinalNbGraines):- FinalT is T + 1, FinalNbGraines is NbGraines -1.





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

copieTete([T|_], L):- L is [T|L].
supprimeTete([_|Q], newL):- newL is Q.