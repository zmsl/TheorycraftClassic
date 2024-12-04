# TheorycraftClassic
This is a fix of the old Theorycraft addon to work with WoW Classic. I've began to maintain my own version of this fork separate from the Boothin repository because it was not actively being updated or fixed.

Use /tc to open the options window.

It is a work in progress and very incomplete. I am going to document a roadmap to bring it back to it's original glory.

# zmsl Edit
Anniversary Era realm GetTalentInfo is returning data that differs from the TheoryCraft_Talents table in spelldata.lua. I have provided a raw extract from the client under util/rawspelldata.json, but have only adjusted the mapping for Druid. If you want other classes to function correctly, you'll need to correct the tree and number values in the talents map.