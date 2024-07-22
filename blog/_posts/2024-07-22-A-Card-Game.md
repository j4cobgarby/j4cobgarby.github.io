---
layout: post
author: Jacob Garby
---

This post explains the rules of a card game that I used to play at school with my friends. We called it Blackjack,
although it seems most people call [a different game](https://en.wikipedia.org/wiki/Blackjack) by this name.

I'm not sure where the game came from originally -- probably it was based on some other game, but we added several
of our own rules to it over time. I think it's a little like Uno, conceptually, although I've never played Uno.

I've tried to write the rules in an unambiguous format, a little like pseudocode. I couldn't think of a simpler
structure to explain the rules. The _Setup_ section makes several definitions, and then you simply have
to understand the structure in the following section, in addition to the effects and conditions of a handful of
special Power Cards.

## Brief Overview

The aim of the game is to be the first to get rid of all of your cards. In one
turn, you may play some cards, according to the rules listed below. You can
chain many cards together in one turn, and you can cause other players to pick
up cards.

## Setup 

Each player is dealt cards from a shuffled deck, until there are no cards left.

An arbitrary player goes first.

Let `pickup` be a global variable := 0
Let `discard` be an empty pile of cards
Let `move offset` := 1

## General Structure of a Turn

 1. Reset `move offset` := sign(`move offset`)
 2. Let `buffer` be a temporary, empty pile of cards.
    - Note for playing: this distinction between `buffer` and `discard`
        provides a simpler psuedocode, but in practice you may place your cards
        directly on `discard` as you take your turn.
 3. If first card played in step 4 will not be Ace, 2, or Jack,
    then draw `pickup` new cards from the deck, and set `pickup` := 0.
    - This means that if you can continue adding to `pickup`, you don't have to
        pick up cards yourself.
    - If you picked up cards due to this step, proceed to step 8.
 4. Play a card which matches either the suit or value on top of `buffer`.
    - If `buffer` is empty (i.e. first card in turn), match instead the card on
        top of `discard`.
        - If `discard` is empty (i.e. the first turn), any card may be played.
    - If you cannot play, then draw one card from the deck and proceed to
        step 7.
    - If the card played isn't a 2 or a Jack, then set `pickup` := 0.
        - i.e., sequences of pickup cards are only effective as the end of a
            turn.
 5. You may now play 0 or more cards of the same _value_ as the card played in
    step 2, on top of `buffer`.
    - If a card is played that isn't a 2 or a Jack, set `pickup` := 0 at that
        moment.
 6. If any cards were played in step 5, then goto step 4.
    - **Unless** the last card played was a 2 or a Jack, in which case you _may_
        proceed to step 7, _or_ goto step 4 if you wish. Pick-up cards do not
        _need_ to be "capped off".
 7. Place `buffer` on top of `discard`.
 8. If you now have no cards left, you win!
    - **Unless** the last card played was a Power Card. In this case, draw one
        card from the deck.
 9. Your turn is done. The next player is determined by counting `move offset` 
    people to the left.

## Power Cards

Some cards act differently when played. They're known as Power Cards. They are:
Ace, 2, 3, 8, J, Q, K.

For each Power Card, the corresponding operation occurs at the moment that it's
played (during a turn). Some Power Cards have additional rules about when they
may be played.

### Ace (Change suit)

 - Can be played on top of _any card_.
 - Player specifies any suit. This card now acts as if it _is_ that suit.
 - If played first in a turn, then step 3 (picking up cards) is skipped.

### Two (Pick up 2)

 - `pickup` := `pickup` + 2.

### Three (Must play something)

 - Goto step 4 (i.e. you're forced to play another valid card, else pick up 1).

### Eight (Skip a person)

 - `move offset` := `move offset` + sign(`move offset`)

### Jack (Pick up)

 - If it's a red Jack, `pickup` := `pickup` + 3
 - If it's a black Jack, `pickup` := `pickup` + 5

### Queen (Must play anything)

 - Goto step 4, except you may play _any card_.

### King (Reverse direction)

 - `move offset` := `move offset` × -1

## Notes for Playing

### Moving Cards from `discard` to the Deck

At the start of the game, there is no deck from which to draw new cards, since
all of the cards are in the players' hands. Of course, at some point, such a
deck will be necessary, so that players can pick up cards when they are
required to.

To facilitate this, it's necessary to occasionally remove all but the top card
of the `discard` pile and shuffle it into the deck.

Still, there could be a situation where a player must pick up more cards than
are in the deck _and_ that are available to move into the deck from the
`discard` pile. In this case, you can either:

 1) Pick up as many cards as possible, exhausting the deck and `discard`, or
 2) Do as in option 1, but remember how many cards you still need "in debt",
    and pick them up as and when they become available.

I can't remember which option we used when we played. Probably 1, since 2
sounds like a hassle...

### Example Turns

If I'm playing first in a game (i.e. `discard` is empty), then here are some
simple turns which do not result in the player having to pick up any extra
cards themselves.

```
Example 1. 9h (9 of hearts) ...... trivial case
Example 2. 9h 9c 4c     .......... due to the goto in step 6
Example 3. 9h 9c 3c 4c  .......... due to 3's special power
Example 4. Js Jc Jh     .......... due to special case in step 6
```
And here are some examples which, due to not "capping off" the turn, the player
must pick up one card from the deck after playing.
```
Example 5. ø (no cards played) ... due to the "if you cannot play" clause in step 4.
Example 6. 9h 9c   ............... >= 2 cards of same value _resets_ turn (due to step 6),
                            making this effectively equivalent to example 5.
```

Here are some moves which utilise power cards, showing how different ones interact with
prior pick-up cards. In the following set of examples, the previous turn was `9c 9h Jh`,
hence `pickup` = 3, and `Jh` is at the top of `discard`.

```
Example 7. <pick up three cards from deck> ....... due to not having any cards to cancel pick-up
Example 8. Ac            ......................... Ace cancels pick-up, and player now chooses next suit freely
Example 9. Jc            ......................... Pick-up avoids pick-up, and `pickup` now = 8 for the next person!
```
