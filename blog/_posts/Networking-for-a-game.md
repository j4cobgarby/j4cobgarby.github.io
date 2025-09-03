---
layout: post
author: Jacob Garby
title: Networking for a Game
---

[Sid Meier's Civilization VI](https://en.wikipedia.org/wiki/Civilization_VI) is a very good game, with some problems. Whenever I play online multiplayer sessions with my friends, we tend to encounter lots of glitches: slow re-syncs, freezes, incompatabilities, etc... For this reason, plus the fact that I just enjoy trying to make little games, I thought it would be fun to design and write a real-time strategy game a little bit like Civ 6, but with some nice differences:

 - Although my game will still be turn-based, within a turn it should feel more fluid.
 - Movement and building should be continuous, not locked to hexagons.
 - There will be tech trees and stuff like that, but I'm not too interested in progressing through historical ages.

There's a lot still to work out. I have no idea whatsoever how I want combat to work. Anyway, I'm starting by trying to implement a fairly solid networking framework. I briefly considered a peer-to-peer networking protocol, and while I still think that would have been cool, I settled on a client-server model for simplicity. So, it will work just like many games: if you want to play with your friends, one of you has to start a game server program, and then everyone can connect their clients to it.

> By the way, this whole post is going to be a whole lot of rambling and side-notes, and is really just so that I can put my thoughts somewhere to help develop the game. If it is interesting or useful, that's incidental.

## The Server

The server maintains _the_ definitive state of the game. Clients may do some kind of interpolation to make the gameplay appear smoother to the player, but they need to make sure not to deviate from what the server says.

The server should be able to stop and start, resuming the game state from a save file. Although I will implement this properly much later, thinking about it early leads to certain design decisions, for example separating actual socket connections from player representations. This means that when resuming, a client can connect and play as whichever player they like (subject to, perhaps, a password).

The main (only?) way that the server and clients communicate is through a well-defined message interface. This means that the protocol can be changed and extended easily in the future, and also lends itself better to debugging (since the messages all go through one of two messages queues on the server it's a lot easier to examine them and reason about them). Due to the client-server model, clients never send messages directly between each other, always using the server as a relay.

The question is, what are the most important messages to send? Let's say the game is already established and running, and we're in the middle of a turn. Clients need to be able to perform actions in the world, and the server needs to update its internal state and let all the connected clients know about it.

In terms of server-side game state updates, lets divide real-time into a bunch of _ticks_. A tick is just a certain moment in time during which the whole game state is progressed. It makes sense to time these ticks to a fixed rate, which for now we'll set as 20 ticks per second. By the way, this means that any server-side processing for one tick needs to complete entirely within 50 milliseconds, otherwise 20ticks/sec won't be maintable.

At the end of every tick, once the server has a new game state, it needs to tell all the clients about this. The simplest way to do this is construct a message which is literally an enumeration of descriptions of every object in the world at the moment. More on what exactly these objects are later, but basically, units (which move around, like soldiers or whatever), and buildings, are the two main types of object. So, the server _could_ package up precise descriptions of every object's state at the end of every tick, and send this information to every client. The issue is once the game gets complicated and there are (say) thousands of objects, these messages would get very large, which would both congest the network (I'm using TCP, by the way), and lead to high latency.

The important observation is that many objects will not change at all in a given tick. For example imagine we have a building which is just, like, a house. This is a pretty static entity. In fact -- though I haven't yet planned exactly what buildings will exist -- a house will probably do nothing at all other than provide a boost to a city's population cap. But also, many units may not move every single tick. In this case, it doesn't make sense to send updates for them, since the client is not getting any information that it didn't already have. Well, I guess technically "nothing happened" is real information, but that can be conveyed by sending no data, right?

So, okay, we could just send the objects which have changed during the last tick. This would probably be good enough, and save a lot of bandwidth, but there is a further optimisation. First, though: to actually implement this we can give every object a boolean field called _dirty_, which tracks whether it's been modified. At the end of a tick we loop through all the objects and package up descriptions of all of them where _dirty_ is set, subsequently resetting _dirty_ for the next tick.

And the other optimisation? Many units will spend a number of ticks moving somewhere. If a unit is travelling from A to B in a straight line, with no other change, it's a lot more efficient to only send the unit's _target location_ whenever _that_ changes, rather than sending its current position every tick. The client can then reconstruct where it thinks the client should be based on where it _was_, where it's _going_, and its speed. This actually has the added advantage that the client can more easily extrapolate a unit's position following on from the tick, up until the next tick arrives.

With this technique there is the worry that everything could go out of sync. I'm using TCP for these messages (for ordering and delivery guarantees at the expense of latency), but somehow it is probably possible that small errors can establish, accumulating and giving clients differing views of the game. This would be bad, so every now and then we should force-synchronise all the units positions. Since the game is logically split into "turns", and within one turn a unit cannot move _that_ far, it seems natural to send these sync messages at the start of every turn.

To summarise all that, we have the following types of message:


