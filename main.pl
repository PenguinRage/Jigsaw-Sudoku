% Assignment 2: Logic Based Programming
% By Ian Cleasby
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definitions:
% Sublists - contain 9 sublist elements [X,Y] where X,Y are between 1..9
% Subelements - are lists [X,Y]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial Setup:
:- use_module(library(clpfd)).
:- use_module(library(clpr)).
:- use_module(library(apply)).
:- use_module(library(yall)).

% Problems from spec sheet
problem(1, [
[3,_,_,_,_,_,_,_,4],
[_,_,2,_,6,_,1,_,_],
[_,1,_,9,_,8,_,2,_],
[_,_,5,_,_,_,6,_,_],
[_,2,_,_,_,_,_,1,_],
[_,_,9,_,_,_,8,_,_],
[_,8,_,3,_,4,_,6,_],
[_,_,4,_,1,_,9,_,_],
[5,_,_,_,_,_,_,_,7]],
[[[1,1],[1,2],[1,3],[2,1],[2,2],[2,3],[3,1],[4,1],[4,2]],
[[1,4],[2,4],[2,5],[2,6],[3,6],[3,7],[3,8],[4,8],[4,9]],
[[1,5],[1,6],[1,7],[1,8],[1,9],[2,7],[2,8],[2,9],[3,9]],
[[3,2],[3,3],[3,4],[3,5],[4,3],[5,1],[5,2],[5,3],[5,4]],
[[4,4],[4,5],[4,6],[4,7],[5,5],[6,3],[6,4],[6,5],[6,6]],
[[5,6],[5,7],[5,8],[5,9],[6,7],[7,5],[7,6],[7,7],[7,8]],
[[6,1],[6,2],[7,2],[7,3],[7,4],[8,4],[8,5],[8,6],[9,6]],
[[6,8],[6,9],[7,9],[8,7],[8,8],[8,9],[9,7],[9,8],[9,9]],
[[7,1],[8,1],[8,2],[8,3],[9,1],[9,2],[9,3],[9,4],[9,5]]]).
% Failing test case
problem(2,[],
[
[[1,2],[1,2],[1,2],[2,1],[2,2],[2,3],[3,1],[4,1],[4,2]],
[[1,4],[2,4],[2,5],[2,6],[3,6],[3,7],[3,8],[4,8],[4,9]],
[[1,2],[1,6],[1,7],[1,8],[1,9],[2,7],[2,8],[2,9],[3,9]],
[[3,2],[3,3],[3,4],[3,5],[4,3],[5,1],[5,2],[5,3],[5,4]],
[[4,4],[4,5],[4,6],[4,7],[5,5],[6,3],[6,4],[6,5],[6,6]],
[[5,6],[5,7],[5,8],[5,9],[6,7],[7,5],[7,6],[7,7],[7,8]],
[[6,1],[6,2],[7,2],[7,3],[7,4],[8,4],[8,5],[8,6],[9,6]],
[[6,8],[6,9],[7,9],[8,7],[8,8],[8,9],[9,7],[9,8],[9,9]],
[[7,1],[8,1],[8,2],[8,3],[9,1],[9,2],[9,3],[9,4]]]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Question 1: completegrid
% Goal: 
% Inorder to complete this task, I needed to:
% - Check we have 9 sublists containing 9 subelements [X,Y]
% - Check element lists X and Y are between 1-9
% - Finally check that each element is individual.
%
% Overview of the code below:
% - So beginning from completegrid, I check to see if I have 9 sublists
% - maplist checks to see if sublists are length of 9
% - shrink flattens my S matrix from 9x9 to 1x81
% - next we change list to set removing duplicates
% - we check length for 81 because if 81 all subelements are unique
% - finally we check values of X and Y are between 1..9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% mylength is used to parse a sublist 
mylength(N,Ls) :- length(Ls, N).


% valuecheck - is the predicate to iterate through each element 
% by recursion and check if X and Y are between 1..9
valuecheck([]).
valuecheck([[X,Y]|Tail]) :-
    between(1,9,X),
    between(1,9,Y),
    valuecheck(Tail).


% shrink - is a recursive predicate that 
% reduces the S matrix from containing 9 sublists -> 81 subelements
% shrink recieves S (splits it into Head and Tail) 
% as well as a Result which is recursively added by T1.
% append H -> T1 and Save into Result.
% is_list - checks that H is a list.
shrink([],[]).
shrink([H|T],Result) :- 
    is_list(H), 
    shrink(T,T1), 
    append(H,T1,Result).


% Complete grid is my overview predicate.
% As defined above:
% - we check for 9 sublists
% - followed by maplist to check from 9 subelements
% - shrink flattens our matrix -> all subelements in a single sublist
% - set list to set -> removes duplicates
% - check length of Set == 81 unique elements
% - check X and Y are between 1..9
completegrid(S) :-
    length(S,9),
    maplist(mylength(9), S),
    shrink(S,R),
    list_to_set(R,L),
    length(L, 81),
    valuecheck(L).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Question 2: contiguousgrid
% Goal: 
% Inorder to complete this task, I needed to:
% - Check that the sublist given returned a single region.
% 
% Definitions:
% - XY: sublist containing X-Y subelements for convinence.
% - Region: confirmed subelements that are in our region.
% - Rest: All the subelements that need to be assessed.
% - Open: subelements that we haven't explored yet, begins with head. 
% - Closed: Is our region being determined in the recursive predicate.
%
% Overview of the code below: (Note I go into more detail below)
% - We receive a sublist called R
% - We have R formated from all [X,Y] -> X^Y into XY as way of pattern matching later on.
% - We then send XY to set_region_rest.
% - We sort XY values into an ordset.
% - We parse the following to the recusive predicate find connect subelements.
%       - the head as the Open set,
%       - Region as closed and 
%       - Sls (the sorted tail) as rest
% - We create neighbour coordinates: Nort, South, East, West
% - Next find the intersection, difference of neighbours and set (S)
% - Append the intersections to Open
% - Recursing til we get empty sets in Open and Closed
% - Returning to check Rest has no remaining subelements.
% - If: empty == Single Region
% - else: more than one region.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% My Main Overview predicate:
% Uses convert predicate to convert S elements 
% convert predicate returns XY, where subelments are changed. [X,Y] -> X^Y
% Then is sent to set_region rest.
contiguousgrid(S) :- 
    convert(S,XY), 
    check_for_region(XY, _ , _ ).



% convert is used to cleanup S and assign the new values to XY.
% The lambda expression: Parameters>>Lambda
% [X,Y] and X^Y are given parameters.
% Maplist maps the lambda expression [[X,Y],X^Y]>>Goal 
% where this goal is true and X^Y is assigned to XY.
% Purpose: This part is used for a bit of pattern matching with
% ord_subtraction and ord_intersection later on
convert(S,XY) :- maplist([[X,Y], X^Y] >> true, S, XY).


% Sort the set of new subelements to standard order of terms, 
% this now implies we have a ordset.
% Split the set into a Region, and a Rest that doesn't belong to it.
% This is then going into a recursive predicate, which will be defined below.. 
% From the recursive predicate we will be given a empty list iff it is a region, 
% the maplist(mylength(0), [Rest]) checks for length of 0  
check_for_region([H |Ls], Rest, Region) :-
    sort([H |Ls], [Sh|Sls]),
    find_connected_subelements([Sh],Region, Sls, Rest),
    maplist(mylength(0),[Rest]).


%%%%%%%%%%%%% Recursive Rule %%%%%%%%%%%%%
% Base Case: If the Open set is [], so is Closed set. 
% The remaining set is Rest.
% if rest still has subelements we don't have a single region.
find_connected_subelements([], [], Rest, Rest).


% Otherwise:
% Take the first pair of coordinates from the Open list, 
% put it at the front of closed coordinates.
% Next try to find coordinates: North, South, East West
% Find any neighbours of the first pairs in the Set of Co-ordinates.
% Append these to the front of open set,
% the rest of the set after removing the neighbours is the new set.
% Repeat with new Open Set, the remainder of Closed 
% and the remaining Set and Rest    
% Used ord_intersection: to find out 
% which neighbors of a coordinate are in the Set (S)
find_connected_subelements([X^Y|Ls], [X^Y|Closed], S, Rest) :-
    North is Y + 1,        % North
    South is Y - 1,        % South
    East is X + 1,         % East
    West is X - 1,         % West
    % Ns recieves all differences with our Set S & Neighbours 
    ord_subtract(S,[West^Y,X^South,X^North,East^Y],Ns),
    % N receives all Intersections with our Set S & Neighbours
    ord_intersection([West^Y,X^South,X^North,East^Y], S, N),
    % Append new found intersections as Unexplored subelements
    append(N, Ls, Open),
	% Recurse again with the newset of differences 
    % and the remainder of open and closed.
    find_connected_subelements(Open, Closed, Ns, Rest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Question 3: solve
% Goal: 
% Inorder to complete this task, I needed to:
% - Solve the puzzle given to us.
%
% Overview of the code below: (Note I go into more detail below)
% - Using the sudoku code, specified in spec.
% - we check the completegrid(S) defined in Q1
% - Check the length of G is 9
% - Check sublists of G are 9
% - Check values in G are between 1 & 9
% - Check rows are distinct
% - Transpose G
% - Check Columns are distinct in G
% - Next we check that the blocks contain distinct values.
% - Beginning by going into a recursive predicate.
% - The predicate takes S and G, [H|T] from S.
% - We check contiguousgrid defined in Q2
% - We pass the row into another recursive predicate,
% - to get the values for the coordinates
% - We get all coordinates till the result and head reach empty sets.
% - We then check Results (All coordinate values) are all_distinct
% - Then repeat for each row.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get coordinates takes in X, Y and G
% From X we get the Row from G
% From Y we get the subelement from the Row (A)
% Result matches to H
get_coordinates(X,Y,S,Result) :- 
    nth1(X,S,A),
    nth1(Y,A,Result).

% Base Case: No more elements to search for a similar application from Q2
evaluate_regions([],_,[]).
% Recursive Case where we iterate through all the subelements in a row
% Get the coordinates and leading to a value in G and then recursing 
% only parsing the tails of T and T2. 
evaluate_regions([[X,Y]|T],S,[H|T2]) :-
    get_coordinates(X,Y,S,H),
    evaluate_regions(T,S,T2).

% Basically the same thing as the normal sudoku code with a few adjustments
% Check completegrid(S) defined in Q1
% check 9 sublists
% check 9 subelements in sublists
% check values are between 1..9
% check rows are distinct & columns are distinct
% Then my code comes in:
% Blocks has changed to meet the jigsaw requirement.
% X = G which is the solution to the problem.

solve(G,S,X) :-
    completegrid(G),
    length(S,9),
    maplist(mylength(9),S),
    append(S, Vs), Vs ins 1..9,
    maplist(all_distinct, S),
    transpose(S,ST),
    maplist(all_distinct,ST),
    blocks(G,S),
    X=S.    

% Blocks similar to the provided code, however changed to meet jigsaw.
% Recursively iterate through each row.
% Contiguousgrid from Q2.
% Return values matching the coordinates S->G->R
% Check the values returned in result are distinct
% Recurse again till tail is []

blocks([],_).
blocks([H|T],S) :-
    contiguousgrid(H),
    evaluate_regions(H, S, Result), 
    maplist(all_distinct, [Result]),
    blocks(T,S).

