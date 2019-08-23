# Concepts in motion playground

This repository contains some simple code  to   see  whether  we can get
reasoning to work with Thea.  To use it:

  - Get the development version of SWI-Prolog (for the tabling)
  - Download:

    ```
    git clone git@github.com:conceptsinmotion/playground
    git submodule update --init
    ```
  - Run
    ```
    swipl playground.pl
    ?- initialize_reasoner.
    ?- reasoner_ask(subClassOf(Sub,Super)).
    ```

Test on Linux (Ubuntu 19.04). Should work   on any platform where Prolog
and Java work. On some platform some  environment setup may be needed to
get JPL (the Prolog <-> Java interface) to run.
