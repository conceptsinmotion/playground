:- ['$HOME/3rdparty/thea2/thea'].
:- use_module(library(thea2/owl2_manchester_parser)).

load :-
    retract_all_axioms,
    owl2_model_init,
    catch(owl_parse_manchester_syntax_file('../ontoTextProv/manchester.owl'),
          E,
          (   print_message(error, E),
              fail
          )).

validate :-
    forall(axiom(X), validate(X)).

validate(X) :-
    valid_axiom(X),
    !.
validate(X) :-
    format(user_error, 'Invalid: ~p~n', [X]).


l :-
    owl_parse_manchester_syntax_file('test1.owl').
