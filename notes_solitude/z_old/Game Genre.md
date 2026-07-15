# Requirements

* conducive to multiplayer
* sequential bosses, queen & kings of each suit, red joker at the end

# Game Loop

* Player draws cards, diamonds are their weapons, maybe different weapon depending on ranking of the diamond. Kite from HxH style
* Monsters are clubs, spades, hearts
* Monsters that the player will fight are also chosen at random, similar to weapon
	* How can I make drawing lower level monsters still feel impactful and drawing higher level ones not so detrimental
	* Maybe that should just be in the game? luck of the draw? I want strategy in it as well though
* Problem I am expressing above is that there is too much randomness and not enough strategy. I feel to incorporate luck into a game and have it still be satisfying, you must have a way for the player to react to as situation to help with their luck
* COOL IDEA: What if the player can spend a turn "sharpening" or "chipping" their diamond card weapon. This brings it up or down a rank.
	* Not sure if I want to stick with the idea that the higher the rank corelates with a much better card. Maybe there are situations where a lower rank card does better against some enemies
	* I think I want to restrict the ranks of cards available at the beginning of the game. The players only have weapons 1-4 when fighting the first suit. 1-8 when on the second suit. 1-13 when fighting the third. 
	* Ace is used as a one in beginning levels. Once you unlock the whole rank, ace can be both High and Low
* 3 actions during a turn? Draw, sharpen, chip,
	* maybe you have a slot which is your attack slot and auto happens after your turn ends? that way there is an incentive to draw and fill up hand instead of focusing on attacking
	* this or add action which is attack
	* 
	![[test_game_screen.gif]]
* What if I go back to having diamonds and hearts be on your side
	* Downside is less boss variety. Initially would have 9 bosses in pool before joker final. 3 suits x (Jack, Queen, King)
	* Upside is hearts can be used for health regain mechanic. Though theoretically I could use one of the 13 ranks for health regen mechanic
# Combat 

* To make lower rank cards still interesting, I could include mechanic where matching the rank of a card to the enemy is very effective
* I could also scrap that all together and then just make each rank of diamond simply do something unique?
	* comes with issue of coming up with 13 unique weapon interactions against enemies
* Durability on each of the cards. Can only be sharpened, chipped (maybe attacked with?) a certain number of times

## Other ideas

* What if the player had multiple slots where they place their attack cards? Would maybe allow for combo gameplay, but lessens the impact of the sharpening and chipping of their diamond
# Card Abilities

* Keep in mind that 1-4 gameplay should feel complete, same goes for 1-8 and 1-13

* **Ace**: Will do something cool at 13, but does something minimal as rank 1. Player will be able to choose which one they do. Use at rank one is a minor heal
* Two: Does bonus damage to evens
* Three: Does bonus damage to odds
* Four:  Shields the player for some damage