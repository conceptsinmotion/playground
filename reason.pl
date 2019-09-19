%!  validate
%
%   Check that all axioms are valid. This   implies they have the proper
%   data shape and all referenced objects are available.

validate :-
    forall(axiom(X), validate(X)).

validate(X) :-
    valid_axiom(X),
    !.
validate(X) :-
    format(user_error, 'Invalid: ~p~n', [X]).

%!  initialize_reasoner
%
%   Initialise the reasoner and send it our ontology. After this we can
%   use e.g.
%
%   ```
%   ?- reasoner_ask(subClassOf(Sub,Super)).
%   ?- reasoner_ask(unsatisfiable(Class)).
%   ```

initialize_reasoner :-
%   debug(owl2),
    load,
    initialize_reasoner(pellet, _Reasoner).
