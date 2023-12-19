# generator.nix

This file is used to generate modules.

## Problem 
Boring and repetitive parts of the module definitions.
By those parts I mean
```nix
_file = ./xxx.nix
options = lib.mkOption { ... };
config = lib.mkIf XXX { ... };
```
This repetition is not only boring but also error prone. And it can lead to inconsistent style.
And you then still have to somehow import the module.

## Solution
Generate modules based on the file path.

## How it works
The generator.nix file is a function that these arguments: [ prefix mainDir ignorePrefix ]
- prefix: The prefix of the module name. (e.g. [ `generated` ] or [ `generated` `home` ]), this is needed to overcome collisions with other modules. And also to make it clear that the module is generated.
- mainDir: The directory that contains the file structure used to generate the modules.
- ignorePrefix: file prefix that if found IN ANY PART OF THE PATH will cause the file to be ignored. As if it was not there.

The generator will generate option for each file and each folder in the structure.

### Files:
For files, it's pretty straight forward. The file name is used as the option name. With the suffix `.nix` removed. And `.enable` is appended to the name.

### Folders:
Folders are a bit more complicated, Same as for files option will be created for each folder. But if the folder is enabled it will enable every file/folder that is inside of it.
recursively **unless** the folder contains a file named **`default.nix`** in which case only that file will be enabled.
If **`default.nix`** is present then additional virtual suboption named `folder_name.all` will be generated enabling this option will override the **`default.nix`** behavior for the current folder.
And it will enable all sub options for each file and folder under the current one (sub options with `default.nix` will behave normally)
If you enable the `documentation.nixos.includeAllModules` you can then check the generated documentation to see what files will be enabled by the folder using the nixos-help command.

# Advantages
- Super easy to add new modules. Just create a new file/folder and it will generate the module for you.
- You can easily enable/disable modules by just changing the option value.
- You can enable modules based on the rest of the configuration


<span id="nixos-default" ></span>
# NixOs default
By default, the generator is used for nixosModules that can be found under the `modules/generated/nixos` folder. With the prefix `generated`.

# Home-manager default
By default, the generator is used for home-managerModules that can be found under the `modules/generated/home-manager` folder. With the prefix `generated.home`.
