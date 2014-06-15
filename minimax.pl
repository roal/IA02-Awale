:- module(minimax, [caseAJouer/3]).

/* Premier agument hauteur, 2 eme argument case 0, troisieme argument joueur =1, 4 joueur ordi =0*/
testFinal2(Indice,Valeur):- simulationEnLargeur(1,0,0,1,[3,3,0,1,3,1],[1,1,0,2,1,5],0,Feuilles),!,
							maxDansListe(6,Feuilles,Indice,Valeur),!.

testFinal3(Indice,Valeur):- simulationEnLargeur(1,0,1,0,[3,3,0,1,3,1],[1,1,0,2,1,5],0,Feuilles),!,
							maxDansListe(6,Feuilles,Indice,Valeur),!.

							
simulationEnLargeur(Hauteur,6,_,_,_,_,_,[]):- !.
simulationEnLargeur(0,_,_,_,_,_,_,[]):- !.
simulationEnLargeur(Hauteur,Case,J1,J2,P1,P2,MaxGrainesRamassees,[Feuilles|Feuilles1]):- Case<6,!,
						NouvelleCase is Case + 1,
						simulationEnLargeur(Hauteur,NouvelleCase,J1,J2,P1,P2,MaxGrainesRamassees,Feuilles1),!,
						simulationEnProfondeur(Hauteur,NouvelleCase,J1,J2,P1,P2,MaxGrainesRamassees,Feuilles),!.

simulationEnProfondeur(0,_,_,_,_,_,Val,Val):- !. 
/*On passe en argument J1 =Joueir =1 J2=Joueur Ordi =0*/
simulationEnProfondeur(1,Case,J1,J2,P3,P4,MaxGrainesRamassees,GrainesRamassees):- getPlateaux(J1, J2, OldP1, OldP2), getScore(J1, J2, SOld1, SOld2),
																				tourPlateau(J1, J2, Case), 
																				write('Scoreavanttour plateau \n'),
																				write(SOld1),nl,write(SOld2),nl,
																				write('Scoreaaprestour plateau\n '),
																				getScore(J1, J2, SNew1, SNew2),
																				write(SNew1),nl,write(SNew2),
																				GrainesRamassees is (SNew1-SOld1),
																				write('GrainesRamassees='),
																				write(GrainesRamassees),
																				majScoresSup(J1,J2,GrainesRamassees),
																				majPlateaux(J1, J2, OldP1, OldP2),
																				!.

nouveauMax(Tete, ValMax, CaseMax, Case, Tete, Case):- Tete > ValMax; Tete == ValMax, Case \= 0,!.
nouveauMax(Tete, ValMax, CaseMax, Case, ValMax, CaseMax):- !.


maxDansListe(1,[T|Q],6,T):-!.
maxDansListe(NbCase,[T|Q],IndiceCase, Valeur):- NewNbCase is NbCase - 1,
												maxDansListe(NewNbCase,Q,AncienIndiceCase,AncienMax),
												CaseCourante is 7 - NbCase,
												nouveauMax(T, AncienMax, AncienIndiceCase, CaseCourante, Valeur, IndiceCase).							 

caseAJouer(ChoixCase,J1,J2):-getPlateaux(J1, J2, P1, P2),
							simulationEnLargeur(1,0,J1,J2,P1,P2,0,Feuilles),!,
							maxDansListe(6,Feuilles,ChoixCase,Valeur),!.
