:- include(thea2/thea).
:- use_module(thea2/owl2_manchester_parser).
:- [reason].

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
