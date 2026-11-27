# ModList 1.4.1 compatibility update

原作者 / Original author: **obfy**. This is a compatibility patch to the supplied ModList 1.3 source, not an independently authored replacement.

修复独立 Playtest v46353.45（Steam Build 26971878）中旧字体资源消失造成的启动报错，并在标签测量结束后恢复绘图字体，防止影响原生 Scribble 和 JEI。保留原作者署名、脚本 Key/ID、16 个备用物品及原有模组管理逻辑。十个空语言 JSON 继续保留，游戏的缺失语言对象问题尚未修复。

Fixes startup errors caused by removed font assets and restores the drawing font after measuring labels, preventing subsequent native Scribble/JEI errors. Preserves the original attribution, script key/ID, 16 spare items and mod-management behavior. The ten empty language JSON files remain necessary for the current native language loader.

Download [Modlist_v1.4.1.zip](https://github.com/2686808092/Tinkerlands-mods/releases/tag/modlist-v1.4.1), place it in the game's `mods` directory without extracting, and remove the previous ModList ZIP. Build from this directory using `python build.py`.

Verification: 85 ten-language/coexistence assertions passed. Existing-save entry, region changes, native save, menu reload and independent-process disk reload completed alongside all installed mods. See [the verification record](verification/playtest-26971878.json). Storage was not loaded; no user save files are included.
