/** Prolog Programming Project (Project 1)
CMPE 260 - Spring 2018, Boun
@author Halit Ozsoy - 2016400141
*/

% all teams in the database as a list (L) and its length (N)
% also defined as allteams, due to ambiguity on the project description and examples
allTeams(L, N) :-
	findall(X, team(X, _), AllTeams),
	length(AllTeams, N),
	% let N be the number of teams (length of AllTeams)
	permutation(AllTeams, L). 
	% accept any answer L which is a permutation of AllTeams
allteams(L, N) :- allTeams(L, N).

% WinLose condition for the scores of two teams.
% 0 means Lose, 1 means Win, 2 means Draw for the first team. (Team)
setWinLose(TeamScore, OtherScore, WinLose):-
	TeamScore < OtherScore,
	WinLose is 0. % Team Loses
setWinLose(TeamScore, OtherScore, WinLose):-
	TeamScore > OtherScore,
	WinLose is 1. % Team Wins
setWinLose(TeamScore, OtherScore, WinLose):-
	TeamScore == OtherScore,
	WinLose is 2. % Draw

% WinLose condition of any two teams (Team, Other) in a week (Week)
resultMatch(Team, Other, Week, WinLose) :-
	match(Week, Team, TeamScore, Other, OtherScore),
	setWinLose(TeamScore, OtherScore, WinLose).
resultMatch(Team, Other, Week, WinLose) :-
	match(Week, Other, OtherScore, Team, TeamScore),
	setWinLose(TeamScore, OtherScore, WinLose).

% all teams that team T has won/lost/drawed (ResultType) against (L) in and before week W
results(_, 0, [], _).
results(T, W, L, ResultType):-
	W > 0,
	NextW is W - 1,
	results(T, NextW, OldResults, ResultType),
	findall(X, resultMatch(T, X, W, ResultType), CurrentResults),
	append(OldResults, CurrentResults, L).

% permutations of all such teams (results as described above)
% number of such teams: N 
resultsPermutation(T, W, L, N, ResultType):-
	results(T, W, P, ResultType),
	length(P, N),
	permutation(P, L).

% wins/losses/draws as a call to results with 1/0/2 as ResultType (Win/Lose/Draw respectively)
wins(T, W, L, N) :- resultsPermutation(T, W, L, N, 1).
losses(T, W, L, N) :- resultsPermutation(T, W, L, N, 0).
draws(T, W, L, N) :- resultsPermutation(T, W, L, N, 2).	

% List of scores (TeamScore) of a Team on a specified Week
getScore(Team, TeamScore, Week) :-
	match(Week, Team, TeamScore, _, _).
getScore(Team, TeamScore, Week) :-
	match(Week, _, _, Team, TeamScore).

% List of concedes (TeamConcede) of a Team on a specified Week
getConcede(Team, TeamConcede, Week) :-
	match(Week, Team, _, _, TeamConcede).
getConcede(Team, TeamConcede, Week) :-
	match(Week, _, TeamConcede, Team, _).

% sumList(List, Total)
% sum of the elements of the List (Total)
sumList([], Total) :-
	Total is 0.
sumList([Head|Tail], Total) :-
	sumList(Tail, Partial),
	Total is Head + Partial.

% Sum of scores (S) made by team T, on W.
scoreWeek(T, W, S) :- % scores in the week, W.
	findall(X, getScore(T, X, W), Scores), % get scores for each week
	sumList(Scores, S). % sum scores for each week

% Sum of concedes (C) of team T, on week W.
concedeWeek(T, W, C) :- % concedes in the week, W.
	findall(X, getConcede(T, X, W), Concedes), % get concedes for each week
	sumList(Concedes, C). % sum concedes of each week


% Sum of scores (S) made by team T, in and before the week W.
scored(_, 0, 0).
scored(T, W, S) :- % scores in and before the week, W.
	team(T, _),
	W > 0,
	Old is W - 1,
	scored(T, Old, OldScore),
	scoreWeek(T, W, CurrentScore),
	S is OldScore + CurrentScore.

% Sum of concedes (C) made by team T, in and before the week W.
conceded(_, 0, 0).
conceded(T, W, C) :- % concedes in and before the week, W.
	team(T, _),
	W > 0,
	Old is W - 1,
	conceded(T, Old, OldConcede),
	concedeWeek(T, W, CurrentConcede),
	C is OldConcede + CurrentConcede.

% Average (A) of team T, in and before the week, W
% A = Scores - Concedes
average(T, W, A) :- % average in and before the week, W.
	scored(T, W, Scores),
	conceded(T, W, Concedes),
	A is Scores - Concedes.

% select team Team, that has a better average than any other team in BiggerTeams, on Week.
isLower(Team, Week, BiggerTeams) :-
	team(Other, _),
	\+ member(Other, [Team|BiggerTeams]),
	average(Team, Week, TeamAverage),
	average(Other, Week, OtherAverage),
	TeamAverage < OtherAverage.

isBiggest(Team, Week, BiggerTeams) :-
	team(Team, _),
	\+ member(Team, BiggerTeams),
	\+ isLower(Team, Week, BiggerTeams).

% getOrdered(TeamList, Week, N)
% get N teams with highest average on Week.
% TeamList goes from low to high (reversed).
getOrdered([], _, 0).
getOrdered([Head|Tail], Week, N):-
	N > 0,
	NextN is N - 1,
	getOrdered(Tail, Week, NextN), % recursively, get N - 1 teams, first.
	findall(Team, isBiggest(Team, Week, Tail), BigTeams), % get next Biggest Teams. 
	% (BigTeams is a list since more than one team can have the same next biggest average.
%	write('Big Teams: '), write(BigTeams), write('  N: '), write(N), nl,
	member(Head, BigTeams). % get one team from the BigTeams.

% a sorted list and another list of same elements but without duplicates
% only use with sorted list
removeDuplicates([],[]).
removeDuplicates([Head|Tail], Unique):-
	Tail = [Head|_],
	removeDuplicates(Tail, Unique).
removeDuplicates([Head|Tail], [Head|Unique]):-
	Tail \= [Head|_],
	removeDuplicates(Tail, Unique).

% get an available week. (one with matches)
% get that week for once (no duplicate week)
getWeek(Week):-
	findall(W, match(W,_,_,_,_),AllWeeks),
	sort(AllWeeks, SortedWeeks),
	removeDuplicates(SortedWeeks, UniqueWeeks),
%	write(UniqueWeeks),
	member(Week, UniqueWeeks).

% get the ordered list of teams (L) by their averages on week W.
order(L, W):-
	getWeek(W),
	findall(X, team(X, _), AllTeams), % get the number of all teams
	length(AllTeams, N), % N is the number of all teams
	getOrdered(ReversedList, W, N), % get N teams ordered by their average
	reverse(ReversedList, L). % reverse it to get the highest-to-lowest list

% get the ordered list of top three teams (L) by their averages on week W.
topThree(L, W):-
	getWeek(W),
	findall(X, team(X, _), AllTeams), % get the number of all teams
	length(AllTeams, MaxN), % MaxN is the number of all teams
	N is min(MaxN, 3), % return all teams if there are less then 3 teams
	getOrdered(ReversedList, W, N), % get N teams ordered by their average
	reverse(ReversedList, L). % reverse it to get the highest-to-lowest list
	


