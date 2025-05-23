![image](https://github.com/JoeSzymkowiczFiveM/js5m_gunrack/assets/70592880/2bf98aaa-6a64-4bad-b905-38d7dad4d09f)
# 🔫 js5m_gunrack - Gang System V2 Fork

This is a fork of the original [js5m_gunrack](https://github.com/JoeSzymkowiczFiveM/js5m_gunrack) script for FiveM, modified to support integration with the **Gang System V2** script.

> ⚠️ **Important:** You must start the `gangsystem_gunracks` script **AFTER** the `cb-gangsystem` resource to ensure correct functionality.

---

## ✨ Description

This script allows players to place a gun rack in the world and use it for storing and retrieving weapons. This fork adds support for **Gang System V2**, enabling gang members to utilize gun racks within their system framework.
---

## 👀 Usage

1. Execute the included SQL script to create the necessary database table.
2. Add the `gunrack` item to your inventory using the configuration below.
3. In-game, use the `gunrack` item to begin placement.
4. After placement, you can target the rack to store or retrieve weapons.
5. Optional: Set a passcode to control access.

---

## 📚 Item Configuration

Add this to your inventory items list (for use with `ox_inventory`):

```lua
['gunrack'] = {
  label = 'Gun Rack',
  weight = 10000,
  stack = false,
  consume = 0,
  client = {
    export = 'js5m_gunrack.placeGunRack',
  },
},
```

## 🔗 Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [oxmysql](https://github.com/overextended/oxmysql)
- **Gang System V2**

---

## 🧑‍🤝‍🧑 Gang System Integration

This fork enables the following features when used with **Gang System V2**:

- Racks can be limited to gang members
- Ownership and access managed through gang system logic
- Placement can be tied to gang turf *(planned)*

---

## ✅ TODO

- [ ] Add gang territory-based placement rules
- [ ] Gang-rank-specific weapon access
- [ ] Support for `prop_cs_gunrack` model
- [ ] UI improvements for gang-based rack management

---

## 🙏 Credits

- **Original Script**: [JoeSzymkowicz](https://github.com/JoeSzymkowiczFiveM)
- **Weapon Component Research**: [FjamZoo](https://github.com/FjamZoo)
- **MySQL Module**: [Snipe](https://github.com/pushkart2)
- **ox Resources**: [Overextended](https://github.com/overextended)

---

## 🎥 Preview

**Rack Placement**  
[https://streamable.com/c98cv3](https://streamable.com/c98cv3)

**Store and Take Weapons**  
[https://streamable.com/86msx5](https://streamable.com/86msx5)

---
For issues or questions about this fork, please open an issue on this repo or contact me directly.