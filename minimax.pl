:- module(minimax, [caseAJouer/3]).

testFinal2(Hauteur,Result,Indice,Valeur):- simulationEnLargeur(1,0,JOrdi,JHumain,[3,3,0,1,3,1],[1,1,0,2,1,5],0,Feuilles),!,
							maxDansListe(6,Feuilles,Indice,Valeur),!.
							
simulationEnLargeur(Hauteur,6,_,_,_,_,_,[]):- !.
simulationEnLargeur(0,_,_,_,_,_,_,[]):- !.
simulationEnLargeur(Hauteur,Case,J1,J2,P1,P2,MaxGrainesRamassees,[Feuilles|Feuilles1]):- Case<6,!,
						NouvelleCase is Case + 1,
						simulationEnLargeur(Hauteur,NouvelleCase,J1,J2,P1,P2,MaxGrainesRamassees,Feuilles1),!,
						simulationEnProfondeur(Hauteur,NouvelleCase,J1,J2,P1,P2,MaxGrainesRamassees,Feuilles),!.

simulationEnProfondeur(0,_,_,_,_,_,Val,Val):- !. 
simulationEnProfondeur(1,Case,J1,J2,P1,P2,MaxGrainesRamassees,GrainesRamassees):- tourPlateau(J1,J2,P1,P2,P1Fin,P2Fin,Case,GrainesRamassees),!.

nouveauMax(Tete, ValMax, CaseMax, Case, Tete, Case):- Tete > ValMax; Tete == ValMax, Case \= 0,!.
nouveauMax(Tete, ValMax, CaseMax, Case, ValMax, CaseMax):- !.


maxDansListe(1,[T|Q],6,T):-!.
maxDansListe(NbCase,[T|Q],IndiceCase, Valeur):- NewNbCase is NbCase - 1,
												maxDansListe(NewNbCase,Q,AncienIndiceCase,AncienMax),
												CaseCourante is 7 - NbCase,
												nouveauMax(T, AncienMax, AncienIndiceCase, CaseCourante, Valeur, IndiceCase).							 
caseAJouer(ChoixCase,PlateauOrdi,PlateauJoueur):-simulationEnLargeur(1,0,PlateauOrdi,PlateauJoueur,0,Feuilles),!,
							          maxDansListe(6,Feuilles,ChoixCase,Valeur),!.
