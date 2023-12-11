% Crime Solving Prolog Bot

addItem(Prompt, List, NewList) :-
    write(Prompt),
    read(Item),
    (   \+ member(Item, List)->   % Check if Item is not a member of List
    	append(List, [Item], NewList); % if not in list then add
    NewList=List).

% builds out a list of a certain length
buildListLength(MaxLength, List,Prompt) :-
    buildList(MaxLength, [], List, Prompt),
    Saves=List,
    write('Result List: '), write(Saves), nl.

buildList(MaxLength, CurrentList, ResultList, Prompt) :-
    length(CurrentList, Length),
    Length =< MaxLength,
    (Length =:= MaxLength ->
        ResultList = CurrentList,  %when length is reached, user is done
        write('List completed.'), nl
    ;
        addItem(Prompt,CurrentList, NewList),  % Add the item to the list
        buildList(MaxLength, NewList, ResultList, Prompt)  % Continue building the list
    ).

% prompts user to give an input, verifies that it is an option
askAndVerifyInformation(Options,VerifiedInfo,Prompt):-
    write(Prompt),
    read(Suspect1),
    (member(Suspect1,Options) ->
    	VerifiedInfo=Suspect1,
        write('Valid response inputted.'), nl
    ;
       write("Not an option."),
       askAndVerifyInformation(Options,VerifiedInfo,Prompt)
).

suspect(Suspects):-
    buildListLength(3,Suspects,"Please name a suspect. (all in lowercase and no spaces) ").

place(Places):-
    buildListLength(3,Places,"Please name a location. (all in lowercase and no spaces) ").

weapon(Weapons):-
    buildListLength(3,Weapons,"Please name a weapon. (all in lowercase and no spaces) ").

% gathers information from user about suspect & their weapons
suspectWeaponQuestion(Constraints, NewConstraintsList,Suspects,W):-
    write("Do you know what weapon any of the suspects used?(yes/no)"),
    read(Answer),
    processSW(Answer,Constraints,NewConstraintsList,Suspects,W).

processSW(yes,Constraints,NewConstraintsList,Suspects,Weapons):- !,
    askAndVerifyInformation(Suspects,GivenSuspect,"Name a Suspect"),
    askAndVerifyInformation(Weapons,GivenWeapon,"Name a Weapon"),
    NewConstraint = [GivenSuspect, _, GivenWeapon],
    NewConstraintsListTemp=[NewConstraint|Constraints],
    nl,
    suspectWeaponQuestion(NewConstraintsListTemp,NewConstraintsList,Suspects,Weapons).

processSW(no,Constraints,NewConstraintsList,_,_):- 
    NewConstraintsList=Constraints,
    write('Moving on then.'),nl.

processSW(Answer,Constraints,NewConstraintsList,Suspects,Weapons):-
    Answer \= no,
    Answer \= yes,
    write('Sorry I do not understand'), nl,
	suspectWeaponQuestion(Constraints,NewConstraintsList,Suspects,Weapons).


% gathers information from user about suspect & their locations
suspectPlaceQuestion(Constraints,NewConstraintsList,Suspects,Places):-
    write("Do you know where any of the suspects were?(yes/no)"),
    read(Answer),
    processSP(Answer,Constraints,NewConstraintsList,Suspects,Places).

processSP(yes,Constraints,NewConstraintsList,Suspects,Places):- !,
    askAndVerifyInformation(Suspects,GivenSuspect,"Name a Suspect"),
    askAndVerifyInformation(Places,GivenPlace,"Name a Place"),
    NewConstraint = [GivenSuspect,GivenPlace,_],
   	NewConstraintsListTemp=[NewConstraint|Constraints],
    nl,
    suspectPlaceQuestion(NewConstraintsListTemp,NewConstraintsList,Suspects,Places).

processSP(no,Constraints,NewConstraintsList,_,_):- 
    NewConstraintsList=Constraints,
    write('Moving on then.'),nl.

processSP(Answer,Constraints,NewConstraintsList,Suspects,Places):-
    Answer \= no,
    Answer \= yes,
    write('Sorry I do not understand'), nl,
    suspectPlaceQuestion(Constraints,NewConstraintsList,Suspects,Places).

%Asking about weapon place pairs
weaponPlaceQuestion(Constraints,NewConstraintsList,W,Places):-
    write("Do you know where any of the weapons were?(yes/no)"),
    read(Answer),
    processWP(Answer,Constraints,NewConstraintsList,W,Places).

processWP(yes,Constraints,NewConstraintsList,Weapons,Places):- !,
    askAndVerifyInformation(Places,GivenPlace,"Name a Place"),
    askAndVerifyInformation(Weapons,GivenWeapon,"Name a Weapon"),
    NewConstraint=[_,GivenPlace,GivenWeapon],
   	NewConstraintsListTemp=[NewConstraint|Constraints],
    nl,
    weaponPlaceQuestion(NewConstraintsListTemp,NewConstraintsList,Weapons,Places).

processWP(no,Constraint,NewConstraintsList,_,_):- 
    NewConstraintsList=Constraint,
    write('Moving on then.'),nl.

processWP(Answer,Constraints,NewConstraintsList,Weapons,Places):-
    Answer \= yes,
    Answer \= no, 
    write('Sorry I do not understand'), nl,
    weaponPlaceQuestion(Constraints,NewConstraintsList,Weapons,Places).

itemAtIndex(0,[Item|_],Item).

itemAtIndex(I,[_|Tail],Item):-
    I>0,
    NextI is I-1,
    itemAtIndex(NextI,Tail,Item).


declareConstraints([Head|Tail],Solution):-
    member(Head,Solution),
    declareConstraints(Tail,Solution).
declareConstraints([], _).


:- use_rendering(table).

play(Solution):- 
   write('Three crimes happened in three different places, by three different people,
          with three different weapons. It is up to you the detective to accurately
          report the details of these crimes and solve the mystery!'), nl,
    suspect(Suspects),weapon(Weapons),place(Places),

    Solution=[[Suspect1,Place1,Weapon1],[Suspect2,Place2,Weapon2],[Suspect3,Place3,Weapon3]], 
		Suspects=[Suspect1,Suspect2,Suspect3],
    suspectWeaponQuestion([],NewConstraints,Suspects,Weapons),
    suspectPlaceQuestion(NewConstraints,NewConstraints2,Suspects,Places),
    weaponPlaceQuestion(NewConstraints2,FinalConstraints,Weapons,Places),

   	permutation([Place1, Place2, Place3],Places),
    permutation([Weapon1, Weapon2, Weapon3],Weapons),
    declareConstraints(FinalConstraints,Solution),
   
    
    write("Congratulations detective! You solved the crime! You have successfully 
           pieced together all of the details to find out that: "), nl,
    write(Suspect1),
    write(" was found in "),
    write(Place1),
    write(" with the "),
    write(Weapon1), nl,
    write(" and then "),nl,
    write(Suspect2),
    write(" was found in "),
    write(Place2),
    write(" with the "),
    write(Weapon2), nl,
    write(" and then "), nl,
    write(Suspect3),
    write(" was found in "),
    write(Place3),
    write(" with the "),  
    write(Weapon3),
    write("."), nl.



