:- ['$HOME/3rdparty/thea2/thea'].
:- use_module(library(thea2/owl2_manchester_parser)).

load :-
    owl_parse_manchester_syntax_file('../ontoTextProv/manchester.owl').
