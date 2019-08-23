:- include(thea2/thea).
:- use_module(thea2/owl2_manchester_parser).

%!  load
%
%   Load the `manchester.owl` file into Thea axioms.

load :-
    retract_all_axioms,
    owl2_model_init,
    catch(owl_parse_manchester_syntax_file('ontoTextProv/manchester.owl'),
          E,
          (   print_message(error, E),
              fail
          )).

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

