---
layout: post
author: Jacob Garby
title: Card Game Notation and "Compiler"
---

In order to easily make digital playable versions of any card game I want, I thought it would be nice
to design some sort of notation (like a programming language) which can describe how any (or at least
most) feasible card games are played. The idea is that various compilers can be made to take this
notation and produce a playable version of the game using different backends, e.g. a simple CLI version,
an online multiplayer web version, and a script for playing the game in tabletop simulator.

So, the notation should be generic enough that it can describe most reasonable card games, but concise
enough that you're not basically writing the game in a normal programming language: it should provide
a lot of structures that are common in card games.

The main concepts in card games are:

 - Cards
   - Different games may use different cards. Each card class would more or less be a structure with a few fields, defined
     by the class. For a standard playing card, the fields would be Rank and Suit, and they'd be
     restricted to certain values. 
   - Some standard library could be provided so that standard types of card are readily available.
 - Hands
   - A hand is a set of cards owned by a player (or set of players, in certain cases).
 - Piles
   - A pile is a set of cards not owned by anyone in particular, e.g. the deck from which cards are dealt, or a discard pile
     on the table.
   - A distinction is made between a pile and a hand because this distinction exists in many games, and may make
     the notation more concise.
 - Moves
   - A move is an action that a player makes.
 - Rounds
   - Most games can be seen as consisting of a number of rounds, so this can be built into the engine.
   - Operations for "next round", etc.

Concept for how an implementation of "Sevens" could look:

```
// Pull in the standard 52 card playing cards class from the standard library.
// It consists of a definition for Standard52, which defines Standard52.suit
// and Standard52.rank, which are both enums.
from cards import Standard52, Standard52.Suit, Standard52.Rank

// Global variable for the current trump suit. In this case, it's initialised to
// a random member of the Suit enum (Spades, Clubs, Hearts, or Diamonds).
trump : Suit = Suit.pick_random()

// An empty discard pile, which is where people will play cards.
discard : Pile<Standard52>

// The deck from which cards are drawn. It's initialised to the full deck, which
// is defined in the standard library.
deck : Pile<Standard52> = Standard52.full_deck // Copy initialise

@cards.init
def start():
    cards.message_all(f"Trump is {trump}")

@cards.pre_round
```
