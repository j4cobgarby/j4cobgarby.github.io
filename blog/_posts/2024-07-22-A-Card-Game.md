---
layout: post
author: Jacob Garby
---

This post explains the rules of a card game that I used to play at school with my friends. We called it Blackjack,
although it's not at all like the [game usually called Blackjack](https://en.wikipedia.org/wiki/Blackjack).

I'm not sure where the game came from originally -- probably it was based on some other game, but we added several
of our own rules to it over time. I think it's a little like Uno, conceptually, although I've never played Uno.

## Brief Overview

The aim of the game is to be the first to get rid of all of your cards. 

In one turn you may play some cards according to the rules listed below. In a turn you can
play a potentially large number of cards, and can also do things that cause other
players to pick up new cards.

## Setup 

Each player is dealt cards from a shuffled deck, until there are no cards left.

Like most card games, the players should sit in a circle-like formation around a table.

An arbitrary player goes first. It doesn't matter at all, but it's common to pick whoever is
to the left hand side of the dealer.

To begin with, turns proceed clockwise around the circle. Note that this direction can change 
later in the game.

## Structure of a Turn

### Picking up cards

At the start of your turn, first consider whether the last player's turn caused you
to pick up some cards. This can be the case if they ended their turn by playing a
pick-up card (a 2 or a Jack). If you don't, simply skip this step.

If you do have to pick up some cards, you can play an Ace to cancel this, thereafter playing
your turn as usual as if starting normally with this Ace.
Alternatively, you can play one or more other pick-up cards (following the normal rules of playing cards)
to prevent picking up anything yourself, but adding to the amount of cards to pick up for
the next player.

Failing either of these, you must pick up the correct number of cards. Your turn ends
immediately after doing so.

### Playing Cards

This subsection describes the basic rules of playing cards. It ignores most special
cases caused by playing [power cards](#power-cards), which are described later.

 1. Play a card which matches the suit _or_ rank of the last card played. If you can't,
    you have to pick up a new card and end your turn now.
 2. You may end your turn here, or play more cards. If you want to play more cards,
    you have to start by playing one or more cards of the same _rank_ as the card
    you played in step 1.
 3. If you decided to play more cards, you must now go back to step 1 in order to
    play at least one more card. This is called "capping off".
  - Capping off your turn is not required after playing Jacks or 2's. This is to facilitate ending your
    turn on pick-up cards, since they otherwise have no effect.
  - Notice that this allows you to loop potentially many times, playing lots of cards. Importantly,
    it also means that you cannot end a turn playing exactly two of some rank (without picking up a new card), but _can_
    with three or more (because the third, etc., can count as the additional card played in step 1 after looping.)

### Winning

To win the game, you have to get rid of all your cards so that you have an empty hand.

You **cannot** win by playing a power card as your final card. In this case, you have to
pick up one new card.

### Power Cards

Some cards act differently when played. They're known as Power Cards. They are:
Ace, 2, 3, 8, J, Q, K.

For each Power Card, the corresponding operation occurs at the moment that it's
played (during a turn). Some Power Cards have additional rules about when they
may be played.

#### Ace (Choose new suit)

 - Can be played on top of _any card_ in step one of [the instructions](#playing-cards).
   - It _cannot_ act as just any rank, when it comes to step two. This means that you couldn't play `3h Ah Ac` as a turn.
 - When played, you can specify any suit. This card now acts as if it _is_ that suit, for the purposes of cards being played on it in step one.
 - As mentioned previously, if played first in a turn it can negate picking up cards from previous pick-up cards.

#### Two (Pick up 2)

 - Add two to the number of cards that the next player must pick up.
 - As with all pick-up cards, it's only effective if played as part of a consecutive run of pick-up cards at the end of a turn.

#### Three (Must play something valid)

 - You must immediately play any matching (suit _or_ rank) card on top of it.
   - (Or pick up one)
 - You can think of this as resetting the turn back to step 1.

#### Eight (Skip a person)

 - Skip the next person who would have had a turn, this round.
 - Multiple eights can be played in one turn, in which case several people can be skipped.
   - You can skip so many people that it's your turn next. This can lead to interesting scenarios.

#### Jack (Pick up)

 - Add something to the number of cards that the next player must pick up.
   - If it's a red Jack, add 3.
   - If it's a black jack, add 5.
 - As with all pick-up cards, it's only effective if played as part of a consecutive run of pick-up cards at the end of a turn.

#### Queen (Must play anything)

 - You must play some card on top of it. You're allowed to play anything.
 - Similar to the [Three](#three-must-play-something), it effectively jumps to step 1. The difference
    between the Three is that you can play any card on top of the Queen.

#### King (Reverse direction)

 - Reverse the direction at which turns progress, flipping between clockwise and
    counter-clockwise.
   - This can interact with Eights in a strange way. Eights skip in the _current_
     turn direction, which can change during the course of a turn.

## Notes for Playing

### Moving Cards from the play pile to the deck

At the start of the game, there is no deck from which to draw new cards, since
all of the cards are in the players' hands. Of course, at some point, such a
deck will be necessary, so that players can pick up cards when they are
required to.

To facilitate this, it's necessary to occasionally remove all but the top card
of the play pile and shuffle it into the deck.

Still, there could be a situation where a player must pick up more cards than
are in the deck _and_ that are available to move into the deck from the
play pile. In this case, you can either:

 1. Pick up as many cards as possible, exhausting the deck and play pile or
 2. Do as in option 1, but remember how many cards you still need "in debt",
    and pick them up as and when they become available.

I can't remember which option we used when we played. Probably 1, since 2
sounds like a hassle...

### Example Turns

If I'm playing first in a game (i.e. the play pile is empty), then here are some
simple turns which do not result in the player having to pick up any extra
cards themselves.

```
Example 1. 9h (9 of hearts)
Example 2. 9h 9c 4c
Example 3. 9h 9c 3c 4c
Example 4. Js Jc Jh
```
And here are some examples which, due to not "capping off" the turn, the player
must pick up one card from the deck after playing.
```
Example 5. ø (no cards played)
Example 6. 9h 9c
```
Here are some moves which utilise power cards, showing how different ones interact with
prior pick-up cards. In the following set of examples, the previous turn was `9c 9h Jh`,
hence three cards are to be picked up, and `Jh` is at the top of `discard`.
```
Example 7. ø <pick up three cards from deck>
Example 8. Ac
Example 9. Jc
```

Here's an example of a particularly long turn.

```
Example 10. Ks Kc 6c 6h 6d 6s Qs 8h 8d 3d 4d 4h As Ac Ad Ah Jh Jd Jc Js
```

To clarify some points about example 10:

 - Two kings are played at first. This switches next-turn direction twice, so it's unchanged.
 - Two 8's are played, thereby skipping the next two players. This takes effect after this turn.
 - Four Jacks are played at the end, forcing the next player whose turn it is to pick up 3+3+5+5=16
    cards if they're unable to cancel it with Aces (which they can't, since all the Aces were played
    in this turn), and unable to add to the pick-up with at least a 2 of spades.
