- [x] fix bug of weapon display not updating after using last of durability ✅ 2026-01-14
- [x] chain hit button ✅ 2026-01-14
- [x] secondary attack button + weapon passive effects ✅ 2026-01-18
- [x] health bar connection ✅ 2026-01-17
- [x] Visually communicate enemy will attack first or player will attack first ✅ 2026-01-17
- [x] Visually communicate player has run out of weapons, enemy attacks ✅ 2026-01-21
- [x] Fix cut/socket/display buttons ✅ 2026-02-05
- [x] fix _on_weapon_display_update, group into function ✅ 2026-02-05
- [x] test 1,2 weapons. Fix twin mark disappearing ✅ 2026-02-05
- [x] twin mark breaks chaining ✅ 2026-02-05
- [x] new weapons ✅ 2026-02-21
- [x] filter base weapons from journal ✅ 2026-03-14
- [x] save file ✅ 2026-03-21
- [x] In between player sitting at campfire. Will be where they edit their memory and recallable weapons. Player daydreaming at the sky, available weapons circling their head ✅ 2026-03-28
	- [x] Click campfire to sleep the night and enter spread again. Gain a little health back ✅ 2026-03-28
	- [ ] Chance encounters in dusk of shop with king, queen, jack of diamonds. Provide player weapons/upgrades
	- [x] consult notebook with weapon recipes written in it. That is how the player swaps out their "learned" weapons with what is in their limited memory ✅ 2026-02-24📅 
- [x] King of Diamonds ✅ 2026-03-28
	- [x] Global script tracking if has met during run ✅ 2026-03-28
	- [x] player inventory. Gives player random weapon. If has ✅ 2026-03-28
	- [ ] She is found surveying fallen ally, gives player personal weapons of these cards to use
	- [x] Also increases player's memory capacity ✅ 2026-03-28
- [ ] Choose encounter scene. Three slots, make node2d for each encounter that fits into slots. Chooses encounter randomly if encounter is valid for gamestate
- [ ] Queen of diamonds
	- [ ] mapping battlefield, planning next move. Unlocks standard issue card weapons for the player
- [ ] Jack of diamonds
	- [ ] Offers player weapon upgrades. More durability, more equip slots, more actions, more draw_amt, increaesed max hp, max crits. Takes card Tatters as currency
	- [ ] Gamble minigame, three cups
- [ ] "Forever" save_file for tracking if player has done tutorial.
- [ ] enemy spawn pool in globals
- [ ] Show somewhere the enemies max health. Should be apparent so player remembers their power even if their health lowers. 
- [ ] boss encounter
- [ ] Joker Reaction Corner.  Ultra kill. Mega Kill. Ludacrious kill. Holy SHIT (ALLBL4CK)
- [ ] 3 boss encounters
- [ ] Find difficult but satisfying execution of player weapon order. Make more satsifying by adding joker reaction + possible enemy damage/effect (joker blasts screen as reward)
- [ ] Drawback of memorizing too many cards is lowered health? Curse of amnesia
- [ ] Visually communicate you have space to draw so unequipping. Armory with physically empty slots?

# before releasing
- [ ] Save file, settings, and game encryption

Create satisfying player attack system first, ignore enemies, just have dummy hit system  
* Drawing random weapon  
* Chipping and sharpening, 5 total durability  
* Weapon explodes on break? Resonance? Extra effect (damage, leads to combo multiplier)  
* Light-Heavy Weapon system? Light (ace-4) weapons setup for heavy (6-10) weapons  

Enemies
* Benefits ranks as health
* Benefits:
	* Easy understandability/implementation

Outside Combat:  
* Deck alterations/Pool weighting Removing weapons from weapon pool. "I don't need to remember this recipe. I've got more important things"  
* Ramping weapon pool. Memory unlocks for red joker "Ah yes, one of my favorites"


Normal Enemy Combat Framing
  ![[Pasted image 20251106192550.png]]

Boss Combat Framing

![[Pasted image 20251106192754.png]]
