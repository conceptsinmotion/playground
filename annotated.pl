:- include(thea2/thea).
:- use_module(thea2/owl2_manchester_parser).
:- use_module(thea2/owl2_export_manchester).
:- use_module(library(semweb/rdf11)).
:- [reason].

:- rdf_register_prefix(dt,
                       'https://conceptsinmotion.org/e-ideas/datatype/').
:- rdf_register_prefix(oa,
                       'https://www.w3.org/TR/annotation-vocab/#').
:- rdf_register_prefix(lemon,
                       'http://lemon-model.net/lemon#').
:- rdf_register_prefix(blz_ont,
                       'https://conceptsinmotion.org/e-ideas/ontologies/bolzano#').
:- rdf_register_prefix(blz_lex,
                       'https://conceptsinmotion.org/e-ideas/lexicon/bolzano#').
:- rdf_register_prefix(vocab,
                       'https://conceptsinmotion.org/e-ideas/vocabulary/').


load_lemon :-
    rdf_load('ontoTextProv/caseStudy/BolzSymbolicIdeaLemon.ttl').

manchester_fragment(S,P,Man) :-
    rdf(S,P,Man^^dt:'OWL_Manchester').

manchester_ontology_theory_of(Theory,SenseDefinition,Predicate,Man) :-
    rdf(Theory, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 'https://conceptsinmotion.org/e-ideas/vocabulary/Theory'),
    rdf(Theory,'http://lemon-model.net/lemon#condition',SenseDefinition),
    rdf(SenseDefinition,Predicate,Man^^dt:'OWL_Manchester').

manchester_axioms_theory_of(Theory,SenseDefinition,Predicate,Man) :-
    rdf(Theory,'https://conceptsinmotion.org/e-ideas/vocabulary/is_composed_of',Sense),
    rdf(Sense,'http://lemon-model.net/lemon#condition',SenseDefinition),
    rdf(SenseDefinition,Predicate,Man^^dt:'OWL_Manchester').

load_manchester :-
    setup_call_cleanup(
        tmp_file_stream(FileName, Stream, [encoding(utf8),extension(omn)]),
        ( write_ontology_header(Stream),
          forall(manchester_fragment(S,P,Man),
                 format(Stream, '# From ~p ~p~n~s~n~n', [S, P, Man]))
        ),
        close(Stream)),
    retract_all_axioms,
    owl2_model_init,
    catch(owl_parse_manchester_syntax_file(FileName),
          E,
          (   print_message(error, E),
              fail
          )),
    delete_file(FileName).

load_manchester(Theory) :-
    setup_call_cleanup(
        tmp_file_stream(FileName, Stream, [encoding(utf8),extension(omn)]),
        ( write_ontology_prefix(Stream),
          forall(manchester_ontology_theory_of(Theory,S,P,Man),
                 format(Stream, '# From ~p ~p~n~s~n~n', [S, P, Man])),
          forall(manchester_axioms_theory_of(Theory,S,P,Man),
                 format(Stream, '# From ~p ~p~n~s~n~n', [S, P, Man]))
        ),
        close(Stream)),
    retract_all_axioms,
    owl2_model_init,
    catch(owl_parse_manchester_syntax_file(FileName),
          E,
          (   print_message(error, E),
              fail
          )),
    delete_file(FileName).

write_ontology_prefix(Stream) :-
    forall(rdf_current_prefix(Prefix, URL),
           format(Stream, 'Prefix: ~w: <~w>~n', [Prefix, URL])).

write_ontology_header(Stream) :-
    forall(rdf_current_prefix(Prefix, URL),
           format(Stream, 'Prefix: ~w: <~w>~n', [Prefix, URL])).

save_results :-
    save_results('results.omn').

save_results(File) :-
    owl_generate_manchester(
        File,
        [ prefix('https://conceptsinmotion.org/e-ideas/lexicon/bolzano#')
        ]).

reason :-
    load_lemon,
    load_manchester('https://conceptsinmotion.org/e-ideas/lexicon/bolzano#interp_of_bolzano_theory_of_ideas'),
    initialize_reasoner,
    forall( (reasoner_ask(subClassOf(Sub,Super)),
             \+ axiom(subClassOf(Sub,Super))),
           assert_axiom(subClassOf(Sub,Super))),
    save_results.

resultsSubClassOf(Sub,Super) :-
    reasoner_ask(subClassOf(Sub,Super_)),
    Super_ \= 'http://www.w3.org/2002/07/owl#Thing',
    atom(Super_),
    re_replace('http://foo.org#', '', Super_, Super),
    atom_string(String, Super),
    \+ axiom(subClassOf(Sub,String)).
% Need to find the following consequence:
% resultsSubClassOf('Symbolic_Idea',Super)
% Sub = SYMBOLIC_IDEA
% Super = OBJECTUAL_IDEA

writeResultsManchesterToFile :-
    setup_call_cleanup(
    open('results.omn', write, Stream, [encoding(utf8)]),
    (forall(resultsSubClassOf(Sub,Super),
           format(Stream, 'Class: ~w~n   SubClassOf: ~w~n~n', [Sub,Super]))),
    close(Stream)).


writeResultsLemonToFile(Theory) :-
    setup_call_cleanup(
    open('results.ttl', write, Stream, [encoding(utf8)]),
    (forall(resultsToAnnotate(Theory,Sense,_Sub,Super),
           format(Stream, '<~w_inferred>   a vocab:InferredSense ;
              vocab:partOf  <~w> ;
              lemon:condition
                  [ a lemon:SenseDefinition ;
                    lemon:value """
                    SubClassOf: ~w """^^dt:OWL_Manchester
                  ] .~n~n', [Sense,Sense,Super])
          )),
    close(Stream)).


%provisory
resultsToAnnotate(Theory,Sense,Sub,Super) :-
    % find the sense that contains the original defition for Sub
    rdf(Theory,'https://conceptsinmotion.org/e-ideas/vocabulary/is_composed_of',Sense),
    rdf(Sense,'http://lemon-model.net/lemon#condition',SenseDefinition),
    rdf(SenseDefinition,_,Man^^dt:'OWL_Manchester'),
    resultsSubClassOf(Sub,Super),
    format(atom(S), 'Class: ~w', [Sub]),
    sub_string(Man, _, _, _, S).
    % create a revised sense that mentions the inferred SuperClass.


load_reason :-
    load_lemon,
    load_manchester('https://conceptsinmotion.org/e-ideas/lexicon/bolzano#interp_of_bolzano_theory_of_ideas'),
    initialize_reasoner,
    writeResultsManchesterToFile,
    writeResultsLemonToFile('https://conceptsinmotion.org/e-ideas/lexicon/bolzano#interp_of_bolzano_theory_of_ideas').


% :- load_reason.
