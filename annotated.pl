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

load_lemon :-
    rdf_load('ontoTextProv/caseStudy/BolzSymbolicIdeaLemon.ttl').

manchester_fragment(S,P,Man) :-
    rdf(S,P,Man^^dt:'OWL_Manchester').

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

write_ontology_header(Stream) :-
    forall(rdf_current_prefix(Prefix, URL),
           format(Stream, 'Prefix: ~w: <~w>~n', [Prefix, URL])),
    format(Stream, '~nOntology: <http://example.org/ontologies>~n~n', []).

save_results :-
    save_results('results.omn').

save_results(File) :-
    owl_generate_manchester(
        File,
        [ prefix('https://conceptsinmotion.org/e-ideas/lexicon/bolzano#')
        ]).
