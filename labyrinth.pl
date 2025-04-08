% СТРУКТУРА ЛАБІРИНТУ

% СТІНИ (7x7)

wall(1,1). wall(1,2). wall(1,3). wall(1,4). wall(1,5). wall(1,6). wall(1,7).
wall(2,1). wall(2,4). wall(2,7).
wall(3,1). wall(3,2). wall(3,4). wall(3,6). wall(3,7).
wall(4,1). wall(4,7).
wall(5,1). wall(5,3). wall(5,4). wall(5,7).
wall(6,1). wall(6,4). wall(6,5). wall(6,7).
wall(7,1). wall(7,2). wall(7,3). wall(7,4). wall(7,5). wall(7,6). wall(7,7).

% СТАРТ І ВИХІД
start(2,2).
end(6,6).

% НАПРЯМКИ РУХУ

% Напрями: up, right, down, left
delta(up,    -1,  0).
delta(down,   1,  0).
delta(left,   0, -1).
delta(right,  0,  1).

% Напрям праворуч від поточного
right_of(up,    right).
right_of(right, down).
right_of(down,  left).
right_of(left,  up).

% Напрям ліворуч від поточного
left_of(up,    left).
left_of(left,  down).
left_of(down,  right).
left_of(right, up).

% ПЕРЕВІРКИ І РУХ

% Чи комірка в межах поля і не стіна
free(X,Y) :-
    \+ wall(X,Y),
    X > 0, X =< 7,
    Y > 0, Y =< 7.

% Перевірка, що комірка не була відвідана
free_cell((X,Y), Visited) :-
    free(X,Y),
    \+ member((X,Y), Visited).

% Отримати нову координату за напрямом
move((X,Y), Dir, (NX,NY)) :-
    delta(Dir, DX, DY),
    NX is X + DX,
    NY is Y + DY.

% ГОЛОВНИЙ АЛГОРИТМ

% Перетворення (X,Y) у [X,Y]
pair_to_list((X,Y), [X,Y]).

% Старт — виклик алгоритму зі стартової точки
wall_follower(Path) :-
    start(SX,SY),
    walk((SX,SY), right, [], Path).

% Базовий випадок — досягли фінішу
walk((X,Y), _, _, [(X,Y)]) :-
    end(X,Y), !.

% Основний крок: пробуємо йти з поточної позиції
walk((X,Y), Dir, Visited, [(X,Y)|Path]) :-
    right_of(Dir, TryDir),
    try_directions((X,Y), TryDir, Visited, Path).

% Спробувати напрями в порядку: право, прямо, ліво, назад
try_directions(Pos, Dir, Visited, Path) :-
    move(Pos, Dir, Next),
    free_cell(Next, Visited),
    walk(Next, Dir, [Pos|Visited], Path), !.

try_directions(Pos, Dir, Visited, Path) :-
    left_of(Dir, D1),
    move(Pos, D1, Next1),
    free_cell(Next1, Visited),
    walk(Next1, D1, [Pos|Visited], Path), !.

try_directions(Pos, Dir, Visited, Path) :-
    left_of(Dir, D1),
    left_of(D1, D2),
    move(Pos, D2, Next2),
    free_cell(Next2, Visited),
    walk(Next2, D2, [Pos|Visited], Path), !.

try_directions(Pos, Dir, Visited, Path) :-
    right_of(Dir, D1),
    right_of(D1, D2),
    move(Pos, D2, Next3),
    free_cell(Next3, Visited),
    walk(Next3, D2, [Pos|Visited], Path), !.

% Якщо жоден напрям не підходить — завершення
try_directions(_, _, _, _) :- fail.


% ЕКСПОРТ JSON

export_maze :-
    wall_follower(OrigPath),
    maplist(pair_to_list, OrigPath, Path),
    findall([X,Y], wall(X,Y), Walls),
    format('{"walls":~w, "path":~w, "start":[2,2], "end":[6,6]}~n', [Walls, Path]).